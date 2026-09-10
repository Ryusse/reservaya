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

  test "PATCH /spaces/:id updates a space as admin" do
    space = spaces(:sala_a)

    patch space_url(space), headers: auth_headers(@admin), params: { space: { name: "Sala A renombrada", capacity: 25 } }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "Sala A renombrada", body["name"]
    assert_equal 25, body["capacity"]
    assert_equal "Sala A renombrada", space.reload.name
  end

  test "PATCH /spaces/:id with invalid data returns 422 and keeps the record" do
    space = spaces(:sala_a)

    patch space_url(space), headers: auth_headers(@admin), params: { space: { capacity: 0 } }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].present?
    assert_equal 10, space.reload.capacity
  end

  test "PATCH /spaces/:id with end_time before start_time returns 422" do
    space = spaces(:sala_a)

    patch space_url(space), headers: auth_headers(@admin), params: { space: { start_time: "20:00", end_time: "08:00" } }

    assert_response :unprocessable_entity
  end

  test "PATCH /spaces/:id on a missing space returns 404" do
    patch space_url(id: 999_999), headers: auth_headers(@admin), params: { space: { name: "x" } }

    assert_response :not_found
    assert JSON.parse(response.body)["error"].present?
  end

  test "PATCH /spaces/:id as non-admin is forbidden" do
    patch space_url(spaces(:sala_a)), headers: auth_headers(@member), params: { space: { name: "x" } }

    assert_response :forbidden
  end

  test "PATCH /spaces/:id without token is unauthorized" do
    patch space_url(spaces(:sala_a)), headers: JSON_HEADERS, params: { space: { name: "x" } }

    assert_response :unauthorized
  end

  test "DELETE /spaces/:id deactivates the space without deleting it" do
    space = spaces(:sala_a)

    assert_no_difference "Space.count" do
      delete space_url(space), headers: auth_headers(@admin)
    end

    assert_response :success
    assert_equal "inactive", space.reload.status
  end

  test "a deactivated space no longer appears in GET /spaces" do
    space = spaces(:sala_a)
    delete space_url(space), headers: auth_headers(@admin)

    get spaces_url, headers: auth_headers(@member)

    ids = JSON.parse(response.body).map { |entry| entry["id"] }
    assert_not_includes ids, space.id
  end

  test "DELETE /spaces/:id on a missing space returns 404" do
    delete space_url(id: 999_999), headers: auth_headers(@admin)

    assert_response :not_found
  end

  test "DELETE /spaces/:id as non-admin is forbidden" do
    delete space_url(spaces(:sala_a)), headers: auth_headers(@member)

    assert_response :forbidden
  end

  test "DELETE /spaces/:id without token is unauthorized" do
    delete space_url(spaces(:sala_a)), headers: JSON_HEADERS

    assert_response :unauthorized
  end
end
