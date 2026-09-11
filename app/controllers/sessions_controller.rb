class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      @user = user
      @token = JsonWebToken.encode(user_id: user.id)
      render :create, status: :ok
    else
      render json: { error: "Correo o contraseña inválidos" }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: "Sesión cerrada" }, status: :ok
  end
end