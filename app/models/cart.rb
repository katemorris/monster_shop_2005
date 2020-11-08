class Cart
  attr_reader :contents, :item_prices

  def initialize(contents, prices)
    @contents = contents
    @item_prices = prices
  end

  def add_item(item)
    self.get_price(item)
    @contents[item.id.to_s] = 0 if !@contents[item.id.to_s]
    @contents[item.id.to_s] += 1
  end

  def get_price(item)
    @item_prices[item.id.to_s] = 0 if !@item_prices[item.id.to_s]
    @item_prices[item.id.to_s] = item.price
  end

  def remove_one(item)
    @contents[item.id.to_s] -= 1
    if @contents[item.id.to_s] == 0
      @contents.delete(item.id.to_s)
    end
    if find_discount(item.id.to_s).count == 0
      get_price(item)
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
    @item_prices[item.id.to_s] * @contents[item.id.to_s]
  end

  def total
    @contents.sum do |item_id,quantity|
      @item_prices[item_id] * quantity
    end
  end

  def inventory_check(item)
    @contents[item.id.to_s] < item.inventory
  end

  def find_discount(item_id)
    item = Item.find(item_id)
    starters = BulkDiscount.where("bulk_discounts.merchant_id = #{item.merchant_id}")
    starters.select { |potential| potential.min_amount <= @contents[item_id] }
  end

  def find_discounts
    @discounts = []
    @contents.each do |item_id, _quantity|
      @discounts << find_discount(item_id)
    end
    @discounts.flatten!
  end

  def has_discounts?
    find_discounts.count > 0 if @contents.count > 0
  end

  def get_max_discount(set)
    if set.count > 1
      set.max_by { |potential| potential.percent_off }
    else
      set.first
    end
  end

  def apply_discounts
    @item_prices.map do |item_id, price|
      starters = find_discount(item_id)
      if !starters.empty?
        discount = get_max_discount(starters).percent_off
        @item_prices[item_id] = (price -= ((discount * 0.01) * price))
      end
    end
    @item_prices
  end
end
