class UsersController < ApiController
  before_action :require_login
  before_action :require_admin

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