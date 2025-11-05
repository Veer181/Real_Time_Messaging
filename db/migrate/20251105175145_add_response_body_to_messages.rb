class AddResponseBodyToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :response_body, :text
  end
end
