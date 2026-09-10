require "test_helper"

class SpacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @member = users(:member)
  end

  def space_params(overrides = {})
    { space: { name: "Sala Nueva", location: "Piso 5", capacity: 8, start_time: "08:00", end_time: "17:00" }.merge(overrides) }
  end

  test "GET /spaces lists only active spaces for any authenticated user" do
    get spaces_url, headers: auth_headers(@member)

    assert_response :success
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
    assert_equal Space.active.count, body.size
    assert(body.all? { |space| space["status"] == "active" })
  end

  test "GET /spaces without token is unauthorized" do
    get spaces_url, headers: JSON_HEADERS

    assert_response :unauthorized
  end

  test "POST /spaces creates a space as admin" do
    assert_difference "Space.count", 1 do
      post spaces_url, headers: auth_headers(@admin), params: space_params
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Sala Nueva", body["name"]
    assert_equal "active", body["status"]
  end

  test "POST /spaces as non-admin is forbidden" do
    assert_no_difference "Space.count" do
      post spaces_url, headers: auth_headers(@member), params: space_params
    end

    assert_response :forbidden
  end

  test "POST /spaces without token is unauthorized" do
    assert_no_difference "Space.count" do
      post spaces_url, headers: JSON_HEADERS, params: space_params
    end

    assert_response :unauthorized
  end

  test "POST /spaces with missing fields returns 422 and error messages" do
    post spaces_url, headers: auth_headers(@admin), params: { space: { name: "" } }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].present?
  end

  test "POST /spaces with non-positive capacity returns 422" do
    post spaces_url, headers: auth_headers(@admin), params: space_params(capacity: 0)

    assert_response :unprocessable_entity
  end

  test "POST /spaces with end_time before start_time returns 422" do
    post spaces_url, headers: auth_headers(@admin), params: space_params(start_time: "18:00", end_time: "09:00")

    assert_response :unprocessable_entity
    assert_match(/hora de inicio/i, JSON.parse(response.body)["errors"].join(" "))
  end

  test "POST /spaces without schedule returns 422" do
    post spaces_url, headers: auth_headers(@admin), params: space_params(start_time: nil, end_time: nil)

    assert_response :unprocessable_entity
  end
end
