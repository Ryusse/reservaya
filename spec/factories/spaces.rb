FactoryBot.define do
  factory :space do
    sequence(:name) { |n| "Space #{n}" }
    location { "Building A, Floor 1" }
    capacity { 10 }
    start_time { "08:00" }
    end_time { "18:00" }
    status { :active }
    space_type { :shared_space }
  end
end
