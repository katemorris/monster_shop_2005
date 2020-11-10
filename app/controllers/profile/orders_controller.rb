class Profile::OrdersController < Profile::BaseController

  def index
    @user = User.find(session[:user_id])
  end

  def show
    @order = Order.find(params[:id])
  end

  def update
    order = Order.find(params[:id])
    order.status = "cancelled"
    order.save

    redirect_to "/profile"
    flash[:notice] = "Order #{order.id} has been cancelled."
  end
end
