class Client < ApplicationRecord
  has_one :customer, foreign_key: :user_id, primary_key: :user_id
end
