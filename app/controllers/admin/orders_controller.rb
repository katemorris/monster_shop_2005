class Admin::OrdersController < Admin::BaseController
  def update
    order = Order.find(params[:order_id])
    order.update(status: 2)
    order.save
    redirect_to admin_path
  end
end
