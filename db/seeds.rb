# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# seeds.rb

# First, ensure all clients have a corresponding customer record.
Client.find_each do |client|
  Customer.find_or_create_by(user_id: client.user_id)
end

# Now, assign a random type to each customer.
customer_types = Customer::CUSTOMER_TYPES.keys

Customer.find_each do |customer|
  customer.update(customer_type: customer_types.sample)
end

puts "Seeded #{Customer.count} customers with random types."
