require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @member = users(:member)
  end

  test "GET /dashboard as admin returns admin metrics" do
    get dashboard_url, headers: auth_headers(@admin)

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "admin", body["role"]
    assert body["metrics"].key?("reservations_this_month")
  end

  test "GET /dashboard as regular user returns user metrics" do
    get dashboard_url, headers: auth_headers(@member)

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "user", body["role"]
    assert body["metrics"].key?("my_active_reservations")
  end

  test "GET /dashboard without token is unauthorized" do
    get dashboard_url, headers: JSON_HEADERS

    assert_response :unauthorized
  end
end
