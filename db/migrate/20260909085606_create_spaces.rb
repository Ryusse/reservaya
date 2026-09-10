class CreateSpaces < ActiveRecord::Migration[8.1]
  def change
    create_table :spaces do |t|
      t.string :name
      t.integer :capacity
      t.string :location
      t.time :start_time
      t.time :end_time
      t.integer :status

      t.timestamps
    end
  end
end
