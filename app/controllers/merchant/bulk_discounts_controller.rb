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

  def edit
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    @discount = BulkDiscount.find(params[:id])
    @discount.update(discount_params)
    if @discount.save
      flash[:alert] = "Discount has been updated."
      redirect_to merchant_bulk_discounts_path
    else
      flash[:error] = @discount.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    discount = BulkDiscount.find(params[:id])
    discount.destroy
    flash[:alert] = 'Discount has been deleted.'
    redirect_to merchant_bulk_discounts_path
  end

  private

  def discount_params
    params.require(:bulk_discount).permit(:name, :percent_off, :min_amount)
  end
end
