require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it "rejects an email without a valid format" do
      user.email = "not-an-email"
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "requires a password of at least 6 characters on create" do
      user = build(:user, password: "123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "does not require a password on update when it is not being changed" do
      user.save!
      user.name = "Updated Name"
      expect(user).to be_valid
    end

    it "requires a password of at least 6 characters on update when one is provided" do
      user.save!
      user.password = "123"
      expect(user).not_to be_valid
    end
  end

  describe "enum :role" do
    it { is_expected.to define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe "associations" do
    it { is_expected.to have_many(:reservations).dependent(:destroy) }
  end

  describe "authentication (has_secure_password)" do
    it "authenticates with the correct password" do
      user = create(:user, password: "secret123")
      expect(user.authenticate("secret123")).to eq(user)
    end

    it "does not authenticate with an incorrect password" do
      user = create(:user, password: "secret123")
      expect(user.authenticate("wrong-password")).to be_falsey
    end
  end
end
