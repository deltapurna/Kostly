class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  helper_method :user_logged_in?, :current_user, :owned_by?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_logged_in?
    current_user
  end

  def owned_by?(user)
    user_logged_in? && current_user == user
  end

  def authorize
    unless user_logged_in?
      redirect_to sign_in_url,
        alert: 'You are not authorized! Please login first!'
    end
  end
  
  def authorize_owner
    place_owner = Place.find(params[:id]).user
    unless user_logged_in? && current_user == place_owner
      redirect_to root_url,
        alert: 'You are not authorized to perform the action!'
    end
  end

  def authorize_profile
    profile_owner = User.find(params[:id])
    unless user_logged_in? && current_user == profile_owner
      redirect_to root_url,
        alert: 'You are not authorized to perform the action!'
    end
  end
end
