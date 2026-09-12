class DashboardsController < ApiController
  before_action :require_login

  resource_description do
    short "Métricas del panel"
    description "Contenido distinto según el rol: métricas globales para admin, personales para user."
  end

  api :GET, "/dashboard", "Métricas del panel para el usuario autenticado"
  header "Authorization", "Bearer <token>", required: true
  error code: 401, desc: "No autenticado (falta token o cookie de sesión)"
  returns code: 200, desc: "{ role, user, metrics } — métricas varían según role"
  def show
    if current_user.admin?
      render :index_admin, status: :ok
    else
      render :index_user, status: :ok
    end
  end
end
