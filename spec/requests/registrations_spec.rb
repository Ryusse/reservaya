require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "POST /register" do
    let(:valid_attributes) do
      {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "Password123"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new User and returns a cookie" do
        expect {
          post "/register", params: valid_attributes, as: :json
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["user"]["name"]).to eq("Test User")
        expect(response.parsed_body["user"]["role"]).to eq("user")
        
        # Check cookie
        expect(response.cookies["reservaya_session"]).to be_present
      end

      it "ignores role in params and sets user role" do
        malicious_attributes = valid_attributes.deep_dup
        malicious_attributes[:user][:role] = "admin"

        post "/register", params: malicious_attributes, as: :json
        expect(response).to have_http_status(:created)
        expect(User.last.role).to eq("user")
      end
    end

    context "with invalid parameters" do
      it "does not create a new User and returns errors" do
        expect {
          post "/register", params: { user: { name: "", email: "" } }, as: :json
        }.to change(User, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to be_present
      end
    end
  end
end
