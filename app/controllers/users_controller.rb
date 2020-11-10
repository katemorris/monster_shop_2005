class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      @user.save
      @user.addresses.create!(address_params)
      flash[:success] = 'You are now registered and logged in!'
      session[:user_id] = @user.id
      redirect_to "/profile"
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
    render file: "public/404" unless current_user
    @user = current_user
  end

  def edit
    if params[:request] == "profile"
      @render = 'edit_profile'
    else
      @render = 'edit_password'
    end
  end

  def update
    @user = current_user
    @user.update(update_params) if profile_update?
    @user.update(password_params) if password_update?
    if @user.save
      flash[:success] = "Your profile is updated" if profile_update?
      flash[:success] = "Your password is updated" if password_update?
      redirect_to profile_path
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      return redirect_to "/profile/edit?request=profile" if profile_update?
      redirect_to profile_edit_path
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :street_address,
      :city,
      :state,
      :zip,
      :email,
      :password,
      :password_confirmation
    )
  end

  def update_params
    params.permit(
      :name,
      :street_address,
      :city,
      :state,
      :zip,
      :email)
  end

  def address_params
    params.require(:user).permit(
      :name,
      :street_address,
      :city,
      :state,
      :zip,
      :nickname
    )
  end

  def password_params
    params.permit(
      :password,
      :password_confirmation
    )
  end

  def profile_update?
    params[:commit] == "Update Profile"
  end

  def password_update?
    params[:commit] == "Update Password"
  end

end
