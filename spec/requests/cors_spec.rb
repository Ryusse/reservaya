require "rails_helper"

RSpec.describe "CORS", type: :request do
  def preflight(origin)
    process :options, "/spaces/1", headers: { "Origin" => origin, "Access-Control-Request-Method" => "GET" }
  end

  it "allows the production frontend origin by default" do
    preflight("https://reservaya.up.railway.app")

    expect(response.headers["Access-Control-Allow-Origin"]).to eq("https://reservaya.up.railway.app")
    expect(response.headers["Access-Control-Allow-Credentials"]).to eq("true")
  end

  it "allows localhost for development" do
    preflight("http://localhost:3000")

    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:3000")
  end

  it "does not allow unknown origins" do
    preflight("https://evil.example.com")

    expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
  end
end
