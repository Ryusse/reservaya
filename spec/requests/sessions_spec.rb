require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { User.create!(name: "Session User", email: "session@example.com", password: "Password123", role: :user) }

  describe "POST /session" do
    context "with valid credentials" do
      it "returns user data and sets a cookie" do
        post "/session", params: { email: user.email, password: "Password123" }, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["user"]["email"]).to eq(user.email)
        expect(response.cookies["reservaya_session"]).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized" do
        post "/session", params: { email: user.email, password: "wrong" }, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.cookies["reservaya_session"]).to be_nil
      end
    end
  end

  describe "GET /session" do
    it "returns the current user when authenticated via cookie" do
      post "/session", params: { email: user.email, password: "Password123" }, as: :json
      cookie = response.headers["Set-Cookie"]

      get "/session", headers: { "Cookie" => cookie }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["user"]["email"]).to eq(user.email)
    end

    it "returns the current user when authenticated via Bearer token" do
      token = JsonWebToken.encode(user_id: user.id)
      get "/session", headers: { "Authorization" => "Bearer #{token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["user"]["email"]).to eq(user.email)
    end

    it "returns unauthorized when not authenticated" do
      get "/session", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /session" do
    it "clears the session cookie" do
      post "/session", params: { email: user.email, password: "Password123" }, as: :json
      cookie = response.headers["Set-Cookie"]

      delete "/session", headers: { "Cookie" => cookie }, as: :json
      expect(response).to have_http_status(:ok)
      # In Rails, deleting a cookie sets it to empty and sets expiry in the past
      set_cookie = response.headers["Set-Cookie"]
      expect(set_cookie).to include("reservaya_session=;")
    end
  end
end
