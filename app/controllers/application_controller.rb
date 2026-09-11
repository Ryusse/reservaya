class ApplicationController < ActionController::API
  private

  def current_user
    @current_user
  end

  def require_login
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    decoded = JsonWebToken.decode(token)

    if decoded.present?
      @current_user = User.find_by(id: decoded[:user_id])
    end

    render json: { error: "No autorizado" }, status: :unauthorized unless current_user
  end

  def require_admin
    render json: { error: "Acceso solo para administradores" }, status: :forbidden unless current_user&.admin?
  end
end