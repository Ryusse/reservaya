class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :space, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :reservations, [:space_id, :date, :start_time], unique: true, name: "index_reservations_no_overlap"
  end
end
