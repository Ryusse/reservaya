class RemoveUniqueIndexFromReservations < ActiveRecord::Migration[8.1]
  def change
    remove_index :reservations, name: "index_reservations_no_overlap"
  end
end
