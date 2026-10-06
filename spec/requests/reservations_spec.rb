require "rails_helper"

RSpec.describe "Reservations", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  let(:space) { create(:space, start_time: "08:00", end_time: "18:00", capacity: 10, space_type: :shared_space) }
  let(:payload) do
    { reservation: { space_id: space.id, date: Date.tomorrow.to_s, start_time: "08:00", end_time: "18:00", seats_reserved: 1 } }
  end

  describe "POST /reservations" do
    it "creates the reservation" do
      expect { post "/reservations", params: payload, headers: headers, as: :json }
        .to change(Reservation, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "still responds 201 when the notification email cannot be enqueued" do
      allow(NotificationMailer).to receive(:reservation_created).and_raise(StandardError, "queue down")

      expect { post "/reservations", params: payload, headers: headers, as: :json }
        .to change(Reservation, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "responds 422 with errors for an invalid reservation" do
      post "/reservations", params: payload.deep_merge(reservation: { end_time: "07:00" }), headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).not_to be_empty
    end
  end
end
