class AddAvailabilityIndexToReservations < ActiveRecord::Migration[8.1]
  def change
    add_index :reservations, [ :space_id, :date, :status ]
  end
end
