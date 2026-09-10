class UsersController < ApiController
  before_action :require_login
  before_action :require_admin

  resource_description do
    short "Usuarios"
    description "Requiere token de un usuario con rol admin."
  end

  api :POST, "/users", "Crear un usuario (solo admin)"
  header "Authorization", "Bearer <token>", required: true
  param :user, Hash, required: true do
    param :name, String, required: true
    param :email, String, required: true
    param :password, String, required: true
    param :password_confirmation, String
  end
  returns code: 201, desc: "{ id, name, email, role }"
  error code: 401, desc: "No autenticado / token inválido"
  error code: 403, desc: "No autorizado (no es admin)"
  error code: 422, desc: "Errores de validación"
  def create
    @user = User.new(user_params)
    @user.role ||= :user

    if @user.save
      render :create, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
