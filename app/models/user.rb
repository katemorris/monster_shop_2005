class User < ApplicationRecord
  has_secure_password
  has_many :orders
  has_many :addresses, dependent: :destroy
  validates_presence_of :name, :street_address, :city, :state, :zip, :email
  validates_presence_of :password, if: :password
  validates :email, uniqueness: true, presence: true
  belongs_to :merchant, optional: true

  enum role: ['default', 'merchant', 'admin']
end
