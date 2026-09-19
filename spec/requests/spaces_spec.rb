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
end
