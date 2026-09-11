class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

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
