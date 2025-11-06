class Customer < ApplicationRecord
  CUSTOMER_TYPES = { new_customer: 0, returning_customer: 1, vip_customer: 2 }.freeze

  def customer_type
    CUSTOMER_TYPES.key(read_attribute(:customer_type))
  end

  def customer_type=(value)
    write_attribute(:customer_type, CUSTOMER_TYPES[value.to_sym])
  end

  CUSTOMER_TYPES.keys.each do |type|
    scope type, -> { where(customer_type: CUSTOMER_TYPES[type]) }
  end
end
