class FixForeignKeyInMessages < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :messages, :customers
    add_foreign_key :messages, :clients
  end
end
