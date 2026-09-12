class SessionsController < ApiController
  before_action :require_login, only: :show

  resource_description do
    short "Sesión / autenticación"
    description "El login deja una cookie httpOnly encriptada con el JWT (exp 24h). El resto de rutas la leen de ahí (o de Authorization: Bearer)."
  end

  api :POST, "/session", "Iniciar sesión"
  param :email, String, required: true, desc: "Correo del usuario"
  param :password, String, required: true, desc: "Contraseña"
  returns code: 200, desc: "Login correcto: { message, user }. Deja la cookie de sesión."
  error code: 401, desc: "Correo o contraseña inválidos"
  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      @user = user
      set_session_cookie(JsonWebToken.encode(user_id: user.id))
      render :create, status: :ok
    else
      render json: { error: "Correo o contraseña inválidos" }, status: :unauthorized
    end
  end

  api :GET, "/session", "Usuario de la sesión actual (según la cookie)"
  returns code: 200, desc: "{ user }"
  error code: 401, desc: "Sin sesión válida"
  def show
    @user = current_user
    render :show, status: :ok
  end

  api :DELETE, "/session", "Cerrar sesión (borra la cookie)"
  returns code: 200, desc: "{ message }"
  def destroy
    clear_session_cookie
    render json: { message: "Sesión cerrada" }, status: :ok
  end
end
