class Address < ApplicationRecord
  belongs_to :user
  has_many :order_addresses
  has_many :orders, through: :order_addresses
end
