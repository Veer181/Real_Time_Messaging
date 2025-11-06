class AddDetailsToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :name, :string
    add_column :customers, :email, :string
    add_column :customers, :phone, :string
    add_column :customers, :notes, :text
  end
end
