class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @merchant = Merchant.find(current_user.merchant_id)
    @discounts = @merchant.bulk_discounts
  end
end
