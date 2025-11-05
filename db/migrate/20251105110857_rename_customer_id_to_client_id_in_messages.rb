class RenameCustomerIdToClientIdInMessages < ActiveRecord::Migration[8.1]
  def change
    rename_column :messages, :customer_id, :client_id
  end
end
