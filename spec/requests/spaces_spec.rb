require "rails_helper"

RSpec.describe "Spaces", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:admin_headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: admin.id)}" } }

  describe "POST /spaces" do
    it "defaults to an active status when the request does not send status or space_type" do
      payload = { name: "Sala 1", capacity: 5, location: "Piso 2", start_time: "08:00", end_time: "18:00" }

      post "/spaces", params: { space: payload }, headers: admin_headers, as: :json

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["status"]).to eq("active")
    end
  end

  describe "GET /spaces/:id" do
    let(:space) { create(:space, start_time: "08:00", end_time: "18:00", capacity: 10, space_type: :shared_space) }

    it "returns the space details and availability blocks" do
      create(:reservation, space: space, date: Date.tomorrow, start_time: "10:00", end_time: "12:00", seats_reserved: 4)

      get "/spaces/#{space.id}.json", params: { date: Date.tomorrow.to_s }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["id"]).to eq(space.id)
      expect(json["date"]).to eq(Date.tomorrow.to_s)
      expect(json["available"]).to be(true)
      expect(json["availability"].length).to eq(3)
      expect(json["availability"][1]["status"]).to eq("partial")
    end
  end
end
