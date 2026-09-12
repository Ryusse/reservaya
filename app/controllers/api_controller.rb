class ApiController < ActionController::API
  include ActionController::Cookies

  SESSION_COOKIE = :reservaya_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  helper_method :current_user

  private

  def not_found
    render json: { error: "Recurso no encontrado" }, status: :not_found
  end

  def require_login
    token = session_token

    return render json: { error: "No autenticado" }, status: :unauthorized unless token

    decoded = JsonWebToken.decode(token)

    return render json: { error: "Token inválido" }, status: :unauthorized unless decoded

    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Token inválido" }, status: :unauthorized
  end

  def session_token
    cookies.encrypted[SESSION_COOKIE].presence ||
      request.headers["Authorization"]&.split(" ")&.last
  end

  def set_session_cookie(token)
    cookies.encrypted[SESSION_COOKIE] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      expires: 24.hours,
    }
  end

  def clear_session_cookie
    cookies.delete(SESSION_COOKIE)
  end

  def current_user
    @current_user
  end

  def require_admin
    return if current_user&.admin?

    render json: { error: "No autorizado" }, status: :forbidden
  end
end
