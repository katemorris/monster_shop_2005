class Profile::AddressesController < Profile::BaseController

  def index
    @user = User.find(session[:user_id])
  end

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.new(address_params)
    if @address.valid?
      @address.save
      flash[:success] = "#{@address.nickname} has been added!"
      redirect_to profile_addresses_path
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @address = Address.find(params[:id])
    render file: 'public/404' if @address.order_addresses.count > 0
  end

  def update
    @address = Address.find(params[:id])
    @address.update(address_params)
    if @address.valid?
      @address.save
      flash[:success] = "The address has been updated!"
      redirect_to profile_addresses_path
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    Address.destroy(params[:id])
    flash[:notice] = "The address has been removed."
    redirect_to profile_addresses_path
  end

  private

  def address_params
    params.require(:address).permit(
      :name,
      :street_address,
      :city,
      :state,
      :zip,
      :nickname
    )
  end
end
