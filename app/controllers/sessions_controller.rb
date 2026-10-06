class SessionsController < ApplicationController
  before_action :require_login, only: [ :show, :destroy ]

  def show
    @user = current_user
    render :show, status: :ok
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      @user = user
      token = JsonWebToken.encode(user_id: user.id)
      set_session_cookie(token)
      render :create, status: :ok
    else
      render json: { error: "Correo o contraseña inválidos" }, status: :unauthorized
    end
  end

  def destroy
    clear_session_cookie
    render json: { message: "Sesión cerrada" }, status: :ok
  end
end
