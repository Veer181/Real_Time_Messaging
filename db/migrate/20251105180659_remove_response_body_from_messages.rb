class RemoveResponseBodyFromMessages < ActiveRecord::Migration[8.1]
  def change
    remove_column :messages, :response_body, :text
  end
end
