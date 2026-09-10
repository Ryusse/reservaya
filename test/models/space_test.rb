require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  def valid_attrs(overrides = {})
    { name: "Sala", location: "Piso 1", capacity: 10, start_time: "08:00", end_time: "18:00" }.merge(overrides)
  end

  test "valid with all attributes" do
    assert Space.new(valid_attrs).valid?
  end

  test "requires name, location and capacity" do
    space = Space.new
    assert_not space.valid?
    assert space.errors[:name].present?
    assert space.errors[:location].present?
    assert space.errors[:capacity].present?
  end

  test "capacity must be greater than zero" do
    assert_not Space.new(valid_attrs(capacity: 0)).valid?
    assert_not Space.new(valid_attrs(capacity: -3)).valid?
  end

  test "requires start_time and end_time" do
    space = Space.new(valid_attrs(start_time: nil, end_time: nil))
    assert_not space.valid?
    assert space.errors[:start_time].present?
    assert space.errors[:end_time].present?
  end

  test "end_time must be after start_time" do
    space = Space.new(valid_attrs(start_time: "18:00", end_time: "09:00"))
    assert_not space.valid?
    assert space.errors[:end_time].present?
  end

  test "new record defaults to active status" do
    assert_equal "active", Space.new.status
  end
end
