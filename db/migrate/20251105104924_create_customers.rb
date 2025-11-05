class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.integer :user_id

      t.timestamps
    end
    add_index :customers, :user_id, unique: true
  end
end
