class Merchant::ItemsController < Merchant::BaseController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @items = @merchant.items
    render 'items/index'
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @item = Item.new
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @item = @merchant.items.new(item_params)
    check_default_image(@item)
    if @item.save
      flash[:alert] = 'New item saved successfully!'
      redirect_to "/merchant/#{@merchant.id}/items"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @item.update(item_params) if params[:item]
    if params[:status]
      update_status
    elsif @item.save
      check_default_image(@item)
      flash[:alert] = "Item #{@item.id} has been successfully updated!"
      redirect_to "/merchant/#{@item.merchant_id}/items"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    item = Item.find(params[:id])
    Review.where(item_id: item.id).destroy_all
    item.destroy
    flash[:alert] = 'This item is now deleted.'
    redirect_to "/merchant/#{item.merchant_id}/items"
  end

  def update_status
    @item = Item.find(params[:id])
    if params[:status] == 'deactivate'
      @item.update(:active? => false)
      flash[:alert] = 'This item is no longer for sale.'
    elsif params[:status] == 'activate'
      @item.update(:active? => true)
      flash[:alert] = 'This item is available for sale.'
    end
    redirect_to "/merchant/#{@item.merchant_id}/items"
  end

  private

  def item_params
    params.require(:item).permit(:name,:description,:price,:inventory,:image)
  end

  def check_default_image(item)
    if params[:item][:image] == ''
      item.update(image: '/images/image.png')
      item.save
    end
  end
end