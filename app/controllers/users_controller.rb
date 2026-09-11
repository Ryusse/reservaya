class UsersController < ApiController
  before_action :require_login
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :require_admin, only: [:index, :create, :destroy]
  before_action :authorize_show, only: [:show]
  before_action :authorize_update, only: [:update]

  def index
    @users = User.order(:id)
    render :index, status: :ok
  end

  def show
    render :show, status: :ok
  end

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
    @user = User.new(admin_user_params)
    @user.role ||= :user

    if @user.save
      render :create, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if current_user.admin?
      success = @user.update(admin_update_user_params)
    else
      success = @user.update(user_password_params)
    end

    if success
      render :show, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      render json: { message: "Usuario eliminado correctamente" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_show
    return if current_user.admin?
    return if current_user.id == @user.id

    render json: { error: "No autorizado" }, status: :forbidden
  end

  def authorize_update
    return if current_user.admin?
    return if current_user.id == @user.id

    render json: { error: "No autorizado" }, status: :forbidden
  end

  def admin_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def admin_update_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
