class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :item_orders, through: :items
  has_many :orders, through: :items
  has_many :users, -> { where(role: 1)}
  has_many :bulk_discounts

  validates_presence_of :name, :address, :city, :state, :zip

  def item_count
    items.count
  end

  def average_item_price
    items.average(:price)
  end

  def distinct_cities
    item_orders.distinct.joins(:order).pluck(:city)
  end

  def pending_orders
    self.orders.where(status: 'pending').distinct
  end

  def enabled?
    enabled
  end

  def status
    return 'Disabled' unless enabled?
    'Enabled'
  end

  def disable_items
    items.update_all(active?: false)
  end

  def enable_items
    items.update_all(active?: true)
  end

  def order_item_quantity(order)
    self.items.joins(:item_orders).where('item_orders.order_id = ?', order).count
  end

  def order_total(order)
    self.items.joins(:item_orders).where('item_orders.order_id = ?', order).sum('item_orders.price')
  end

end
