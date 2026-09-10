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
class Reservation < ApplicationRecord
  belongs_to :space
  belongs_to :user

  enum :status, { confirmed: 0, cancelled: 1 }

  validates :date, :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :date_not_in_the_past, on: :create
  validate :space_is_active, on: :create
  validate :no_overlap, on: :create   

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "Debe ser después de la hora de inicio") if end_time <= start_time
  end

  def date_not_in_the_past
    errors.add(:date, "No puede estar en el pasado") if date.present? && date < Date.current
  end

  def space_is_active
    errors.add(:space, "No está activo") if space.present? && !space.active?
  end

  def no_overlap
    return if space_id.blank? || date.blank? || start_time.blank? || end_time.blank?

    conflict = Reservation.where(space_id: space_id, date: date, status: :confirmed)
                           .where.not(id: id)
                           .where("start_time < ? AND end_time > ?", end_time, start_time)
                           .exists?
    errors.add(:base, "Este espacio ya está reservado para ese intervalo de tiempo") if conflict
  end
end