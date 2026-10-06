require "rails_helper"

RSpec.describe "Reservations", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }

  describe "POST /reservations" do
    let(:space) { create(:space, capacity: 10, start_time: "08:00", end_time: "18:00") }
    let(:payload) do
      { space_id: space.id, date: Date.tomorrow.to_s, start_time: "10:00", end_time: "12:00", seats_reserved: 5 }
    end

    it "creates a new reservation" do
      expect {
        post "/reservations", params: { reservation: payload }, headers: headers, as: :json
      }.to change(Reservation, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "returns unprocessable entity when the space does not exist" do
      post "/reservations", params: { reservation: payload.merge(space_id: 9999) }, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Espacio no encontrado")
    end
  end

  describe "concurrency safety (RNF05)" do
    self.use_transactional_tests = false

    after do
      Reservation.delete_all
      Space.delete_all
      User.delete_all
    end

    it "allows only one of two simultaneous reservations for the same slot to succeed" do
      allow_any_instance_of(Reservation).to receive(:availability_by_space_type).and_wrap_original do |original, *args|
        sleep 0.05
        original.call(*args)
      end
      space = create(:space, space_type: :private_space, capacity: 1, start_time: "08:00", end_time: "18:00")
      users = create_list(:user, 2)
      body = {
        reservation: {
          space_id: space.id,
          date: Date.tomorrow.to_s,
          start_time: "10:00",
          end_time: "12:00",
          seats_reserved: 1
        }
      }.to_json

      statuses = Array.new(2)
      threads = users.each_with_index.map do |competing_user, index|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            session = Rack::Test::Session.new(Rails.application)
            token = JsonWebToken.encode(user_id: competing_user.id)
            session.post "/reservations", body,
              "CONTENT_TYPE" => "application/json",
              "HTTP_ACCEPT" => "application/json",
              "HTTP_AUTHORIZATION" => "Bearer #{token}"
            statuses[index] = session.last_response.status
          end
        end
      end
      threads.each(&:join)

      expect(statuses.sort).to eq([ 201, 422 ])
      expect(Reservation.where(space_id: space.id, status: :confirmed).count).to eq(1)
    end
  end
end
