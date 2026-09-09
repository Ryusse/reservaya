require "test_helper"

# == Schema Information
#
# Table name: reservations
#
#  id         :bigint           not null, primary key
#  date       :date             not null
#  end_time   :time             not null
#  start_time :time             not null
#  status     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  space_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_reservations_no_overlap   (space_id,date,start_time) UNIQUE
#  index_reservations_on_space_id  (space_id)
#  index_reservations_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
class ReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
