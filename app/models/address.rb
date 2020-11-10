class Address < ApplicationRecord
  belongs_to :user
  has_many :order_addresses
  has_many :orders, through: :order_addresses

  def has_no_orders?
    orders.count == 0
  end
end
