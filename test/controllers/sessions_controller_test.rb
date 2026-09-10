require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  def login(user = @admin, password: "secret123")
    post session_url, headers: JSON_HEADERS, params: { email: user.email, password: password }
  end

  test "POST /session with valid credentials opens a session cookie" do
    login

    assert_response :success
    body = JSON.parse(response.body)
    assert_nil body["token"]
    assert_equal @admin.email, body["user"]["email"]
    assert response.cookies["reservaya_session"].present?
  end

  test "POST /session with invalid credentials returns 401 and no cookie" do
    login(password: "wrong")

    assert_response :unauthorized
    assert_nil response.cookies["reservaya_session"]
  end

  test "the session cookie authorizes a protected endpoint without a bearer header" do
    login
    get spaces_url, headers: JSON_HEADERS

    assert_response :success
  end

  test "GET /session returns the current user when the cookie is valid" do
    login
    get session_url, headers: JSON_HEADERS

    assert_response :success
    assert_equal @admin.email, JSON.parse(response.body)["user"]["email"]
  end

  test "GET /session without a session returns 401" do
    get session_url, headers: JSON_HEADERS

    assert_response :unauthorized
  end

  test "DELETE /session clears the cookie and drops access" do
    login
    delete session_url, headers: JSON_HEADERS
    assert_response :success

    get session_url, headers: JSON_HEADERS
    assert_response :unauthorized
  end

  test "a bearer token still works as a fallback" do
    get spaces_url, headers: auth_headers(@admin)

    assert_response :success
  end
end
