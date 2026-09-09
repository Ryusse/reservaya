require "test_helper"

# == Schema Information
#
# Table name: spaces
#
#  id         :bigint           not null, primary key
#  capacity   :integer
#  end_time   :time
#  location   :string
#  name       :string
#  start_time :time
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SpaceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
