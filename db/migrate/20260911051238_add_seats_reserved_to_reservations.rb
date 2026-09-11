class AddSeatsReservedToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :seats_reserved, :integer, null: false, default: 1
  end
end
