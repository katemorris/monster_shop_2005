class Profile::AddressesController < Profile::BaseController

  def index
    @user = User.find(session[:user_id])
  end

  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)
  end

  def show
    @address = Address.find(params[:id])
  end

  def update
    address = Address.find(params[:id])
    redirect_to "/profile"
  end

  def destroy
    Address.destroy(params[:id])
    flash[:notice] = "The address has been removed."
    redirect_to profile_addresses_path
  end
end
