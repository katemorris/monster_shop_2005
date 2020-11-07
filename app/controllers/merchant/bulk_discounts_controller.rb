class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @merchant = Merchant.find(current_user.merchant_id)
    @discounts = @merchant.bulk_discounts
  end

  def new
    @merchant = Merchant.find(current_user.merchant_id)
    @discount = BulkDiscount.new
  end

  def create
    @merchant = Merchant.find(current_user.merchant_id)
    @discount = @merchant.bulk_discounts.new(discount_params)
    if @discount.save
      flash[:success] = "Discount created successfully!"
      redirect_to merchant_bulk_discounts_path
    else
      flash[:error] = @discount.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def discount_params
    params.require(:bulk_discount).permit(:name, :percent_off, :min_amount)
  end
end
