class Address < ApplicationRecord
  belongs_to :user
  has_many :order_addresses
  has_many :orders, through: :order_addresses

  validates_presence_of :nickname, :name, :street_address, :city, :state, :zip

  def has_no_orders?
    orders.count == 0
  end
end
