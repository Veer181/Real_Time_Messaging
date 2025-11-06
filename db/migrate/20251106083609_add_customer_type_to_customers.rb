class AddCustomerTypeToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :customer_type, :integer
  end
end
