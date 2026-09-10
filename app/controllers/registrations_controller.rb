class RegistrationsController < ApiController
  resource_description do
    short "Registro público"
    description "Alta de una cuenta institucional. No requiere token; el rol siempre es 'user'."
  end

  api :POST, "/register", "Registrar una cuenta nueva (rol user)"
  param :user, Hash, required: true do
    param :name, String, required: true
    param :email, String, required: true
    param :password, String, required: true, desc: "Mínimo 6 caracteres"
  end
  returns code: 201, desc: "{ message, user }. Deja la cookie de sesión."
  error code: 422, desc: "Errores de validación (incluye email ya registrado)"
  def create
    @user = User.new(user_params)
    @user.role = :user

    if @user.save
      set_session_cookie(JsonWebToken.encode(user_id: @user.id))
      render :create, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
