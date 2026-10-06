class RegistrationsController < ApplicationController
  def create
    @user = User.new(user_params)
    @user.role = :user

    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      set_session_cookie(token)
      render "sessions/create", status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
