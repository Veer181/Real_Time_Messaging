class AddUrgentToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :urgent, :boolean, default: false
  end
end
