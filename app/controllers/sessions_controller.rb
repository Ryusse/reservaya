class SessionsController < ApiController
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

  private

  def user_json(user)
    { id: user.id, name: user.name, email: user.email, role: user.role }
  end
end