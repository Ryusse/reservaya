require "rails_helper"

RSpec.describe "db/seeds.rb" do
  def run_seeds
    load Rails.root.join("db/seeds.rb")
  end

  it "creates an admin with known credentials" do
    run_seeds

    admin = User.find_by(email: "admin@reservaya.local")
    expect(admin).to be_present
    expect(admin.role).to eq("admin")
    expect(admin.authenticate("password123")).to eq(admin)
  end

  it "creates example spaces covering the main scenarios" do
    run_seeds

    expect(Space.find_by(name: "Sala Privada Demo")).to have_attributes(space_type: "private_space", status: "active")
    expect(Space.find_by(name: "Sala Compartida Demo")).to have_attributes(space_type: "shared_space", status: "active")
    expect(Space.find_by(name: "Sala Inactiva Demo")).to have_attributes(status: "inactive")
  end

  it "is idempotent" do
    run_seeds
    run_seeds

    expect(User.where(email: "admin@reservaya.local").count).to eq(1)
    expect(Space.where(name: "Sala Privada Demo").count).to eq(1)
  end
end
