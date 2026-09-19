class AddDefaultToSpacesStatus < ActiveRecord::Migration[8.1]
  def up
    change_column_default :spaces, :status, 0
    change_column_null :spaces, :status, false, 0
  end

  def down
    change_column_null :spaces, :status, true
    change_column_default :spaces, :status, nil
  end
end
