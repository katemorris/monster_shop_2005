class CartController < ApplicationController
  def create
    item = Item.find(params[:item_id])
    cart.add_item(item.id.to_s)
    flash[:success] = "#{item.name} was successfully added to your cart"
    redirect_to "/items"
  end

  def update
    item = Item.find(params[:item_id])
    if params[:type] == 'up'
      cart.add_item(item.id.to_s)
    elsif params[:type] == 'down'
      cart.remove_one(item.id.to_s)
    end
    flash.now[:success] = "#{item.name} was successfully updated"
    redirect_to '/cart'
  end

  def show
    render file: "public/404" if current_admin?
    @items = cart.items
    if cart.has_discounts?
      flash.now[:success] = "Discounts applied!"
    end
  end

  def destroy
    if params[:item_id]
      session[:cart].delete(params[:item_id])
      redirect_to '/cart'
    else
      session.delete(:cart)
      redirect_to '/cart'
    end
  end
end
