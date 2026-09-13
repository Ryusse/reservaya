require "rails_helper"

RSpec.describe Space, type: :model do
  subject(:space) { build(:space) }

  it "has a valid factory" do
    expect(space).to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }

    it { is_expected.to validate_presence_of(:capacity) }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }

    it "is invalid when end_time is before start_time" do
      space.start_time = "18:00"
      space.end_time = "08:00"
      expect(space).not_to be_valid
      expect(space.errors[:end_time]).to include("Debe ser después de la hora de inicio")
    end

    it "is invalid when end_time equals start_time" do
      space.start_time = "08:00"
      space.end_time = "08:00"
      expect(space).not_to be_valid
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
    it { is_expected.to define_enum_for(:space_type).with_values(private_space: 0, shared_space: 1) }
  end

  describe "associations" do
    it { is_expected.to have_many(:reservations).dependent(:restrict_with_error) }
  end
end
