class ChangeUrgentToIntegerInMessages < ActiveRecord::Migration[7.1]
  def up
    change_column_default :messages, :urgent, nil
    change_column :messages, :urgent, "integer USING CASE WHEN urgent = 't' THEN 1 ELSE 0 END"
    change_column_default :messages, :urgent, 0
  end

  def down
    change_column_default :messages, :urgent, nil
    change_column :messages, :urgent, "boolean USING CASE WHEN urgent = 1 THEN 't' ELSE 'f' END"
    change_column_default :messages, :urgent, false
  end
end
