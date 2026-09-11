class SessionsController < ApiController
  resource_description do
    short "Sesión / autenticación"
  end

  api :POST, "/session", "Iniciar sesión y obtener un token JWT"
  param :email, String, required: true, desc: "Correo del usuario"
  param :password, String, required: true, desc: "Contraseña"
  returns code: 200, desc: "Login correcto: { message, token, user }"
  error code: 401, desc: "Correo o contraseña inválidos"
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

  api :DELETE, "/session", "Cerrar sesión (el token no se invalida en el servidor)"
  header "Authorization", "Bearer <token>", required: true
  returns code: 200, desc: "{ message }"
  def destroy
    render json: { message: "Sesión cerrada" }, status: :ok
  end
end
