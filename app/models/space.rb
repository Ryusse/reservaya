# == Schema Information
#
# Table name: spaces
#
#  id         :bigint           not null, primary key
#  capacity   :integer
#  end_time   :time
#  location   :string
#  name       :string
#  space_type :integer          default(0), not null
#  start_time :time
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Space < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error

  enum :status, { active: 0, inactive: 1 }, default: :active
  enum :space_type, { private_space: 0, shared_space: 1 }

  validates :name, :location, :start_time, :end_time, :space_type, :status, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "Debe ser después de la hora de inicio") if end_time <= start_time
  end
end