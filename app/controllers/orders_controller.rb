class OrdersController <ApplicationController

  def new
    @address = Address.find(session[:address].first["id"]) if session[:address]
  end

  def show
    @order = Order.find(params[:id])
  end

  def create
    user = User.find(session[:user_id])
    map_address(session[:address].first)
    order = user.orders.create(order_params)
    build_item_orders(order)
    session.delete(:address)
    session.delete(:cart)
    session[:order_id] = order.id
    flash[:success] = "Your order was successfully created!"
    redirect_to "/profile/orders"
  end


  private

  def order_params
    params.permit(:name, :address, :city, :state, :zip, :user_id)
  end

  def build_item_orders(order)
    cart.items.each do |item,quantity|
      order.item_orders.create({
        item: item,
        quantity: quantity,
        price: cart.item_prices[item.id.to_s]
        })
    end
  end

  def map_address(address)
    params[:name] = address["name"]
    params[:address] = address["street_address"]
    params[:city] = address["city"]
    params[:state] = address["state"]
    params[:zip] = address["zip"]
    params[:user_id] = address["user_id"]
  end
end
