FactoryBot.define do
  factory :reservation do
    space
    user
    date { Date.current + 1.day }
    start_time { "09:00" }
    end_time { "10:00" }
    seats_reserved { 1 }
    status { :confirmed }
  end
end
