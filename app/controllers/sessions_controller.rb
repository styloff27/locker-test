class SessionsController < ApplicationController
  def update
    session[:user_id] = User.find(params[:user_id]).id
    redirect_to root_path, status: :see_other
  end
end
