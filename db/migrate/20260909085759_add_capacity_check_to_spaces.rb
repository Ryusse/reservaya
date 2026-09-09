class AddCapacityCheckToSpaces < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :spaces, "capacity > 0", name: "capacity_positive"
  end
end
