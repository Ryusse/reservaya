class UsersController < ApplicationController
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