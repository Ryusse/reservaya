require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def registration_params(overrides = {})
    { user: { name: "Nueva Persona", email: "nueva@example.com", password: "secret123" }.merge(overrides) }
  end

  test "POST /register creates a user with role user and opens a session" do
    assert_difference "User.count", 1 do
      post register_url, headers: JSON_HEADERS, params: registration_params
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_nil body["token"]
    assert response.cookies["reservaya_session"].present?
    assert_equal "nueva@example.com", body["user"]["email"]
    assert_equal "user", body["user"]["role"]
    assert_equal "user", User.find_by(email: "nueva@example.com").role

    get session_url, headers: JSON_HEADERS
    assert_response :success
    assert_equal "nueva@example.com", JSON.parse(response.body)["user"]["email"]
  end

  test "POST /register ignores an admin role in the payload" do
    post register_url, headers: JSON_HEADERS, params: registration_params(role: "admin")

    assert_response :created
    assert_equal "user", User.find_by(email: "nueva@example.com").role
  end

  test "POST /register with invalid data returns 422" do
    assert_no_difference "User.count" do
      post register_url, headers: JSON_HEADERS, params: registration_params(name: "", password: "123")
    end

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].present?
  end

  test "POST /register with a duplicate email returns 422 with a clear message" do
    existing = users(:member).email

    assert_no_difference "User.count" do
      post register_url, headers: JSON_HEADERS, params: registration_params(email: existing)
    end

    assert_response :unprocessable_entity
    assert_match(/ya está registrado/i, JSON.parse(response.body)["errors"].join(" "))
  end

  test "POST /register is public (no token required)" do
    post register_url, headers: JSON_HEADERS, params: registration_params

    assert_response :created
  end
end
