class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user
      user.set_reset_password_token
      UserMailer.reset_password(user.id).deliver_later
      redirect_to root_url, notice: 'Please check your email'
    else
      redirect_to new_password_reset_url, alert: 'Email not found in our system'
    end
  end

  def edit
    @user = User.find_by(reset_password_token: params[:token]) if params[:token]

    redirect_to root_url,
      alert: 'You have invalid token, please redo the process' unless @user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      @user.update_attribute(:reset_password_token, nil)
      redirect_to sign_in_url, notice: 'Please login with your new password'
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
