class Profile::OrdersController < Profile::BaseController

  def index
    @user = User.find(session[:user_id])
  end

  def show
    @order = Order.find(params[:id])
  end

  def edit
    @user = User.find(current_user.id)
    @order = Order.find(params[:id])
    render file: 'public/404' if @order.status != 'pending'
  end

  def update
    order = Order.find(params[:id])
    user = User.find(current_user.id)
    if params[:address]
      address = user.addresses.find_by(nickname: params["address"])
      map_address(address)
      order.update(address_params)
      order.save
      flash[:success] = "Order #{order.id} has an updated shipping address."
      redirect_to "/profile/orders/#{order.id}"
    else
      order.status = "cancelled"
      order.save
      flash[:notice] = "Order #{order.id} has been cancelled."
      redirect_to "/profile"
    end
  end

  private

  def address_params
    params.permit(:name, :address, :city, :state, :zip)
  end

  def map_address(address)
    params[:name] = address.name
    params[:address] = address.street_address
    params[:city] = address.city
    params[:state] = address.state
    params[:zip] = address.zip
  end
end
