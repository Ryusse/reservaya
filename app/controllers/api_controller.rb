class ApiController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { error: "Recurso no encontrado" }, status: :not_found
  end

  def require_login
    token = request.headers["Authorization"]&.split(" ")&.last

    return render json: { error: "No autenticado" }, status: :unauthorized unless token

    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Token inválido" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def require_admin
    return if current_user&.admin?

    render json: { error: "No autorizado" }, status: :forbidden
  end
end
