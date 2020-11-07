class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents
    @discounts = []
  end

  def add_item(item)
    @contents[item] = 0 if !@contents[item]
    @contents[item] += 1
  end

  def remove_one(item)
    @contents[item] -= 1
    if @contents[item] == 0
      @contents.delete(item)
    end
  end

  def total_items
    @contents.values.sum
  end

  def items
    item_quantity = {}
    @contents.each do |item_id,quantity|
      item_quantity[Item.find(item_id)] = quantity
    end
    item_quantity
  end

  def subtotal(item)
    item.price * @contents[item.id.to_s]
  end

  def total
    @contents.sum do |item_id,quantity|
      Item.find(item_id).price * quantity
    end
  end

  def inventory_check(item)
    @contents[item.id.to_s] < item.inventory
  end

  def find_discounts
    @contents.each do |item_id, quantity|
      item = Item.find(item_id)
      starters = BulkDiscount.where("bulk_discounts.merchant_id = #{item.merchant_id}")
      @discounts << starters.select { |potential| potential.min_amount <= quantity }
    end
    @discounts.flatten!
  end

  def has_discounts?
    find_discounts.count > 0
  end
end
