class SpacesController < ApiController
  before_action :require_login
  before_action :require_admin, only: [:create, :update, :destroy]
  before_action :set_space, only: [:show, :update, :destroy]

  resource_description do
    short "Espacios reservables"
    description "Lectura: cualquier usuario con token. Escritura: solo admin."
  end

  def_param_group :space do
    param :space, Hash, required: true do
      param :name, String, required: true
      param :capacity, :number, required: true, desc: "Debe ser > 0"
      param :location, String, required: true
      param :start_time, String, required: true, desc: "Hora de apertura (HH:MM)"
      param :end_time, String, required: true, desc: "Hora de cierre (HH:MM), posterior a start_time"
      param :status, ["active", "inactive"], desc: "Por defecto: active"
    end
  end

  api :GET, "/spaces", "Lista los espacios activos"
  header "Authorization", "Bearer <token>", required: true
  def index
    @spaces = Space.active
  end

  api :GET, "/spaces/:id", "Detalle de un espacio y sus reservas confirmadas de una fecha"
  header "Authorization", "Bearer <token>", required: true
  param :id, :number, required: true
  param :date, String, desc: "Fecha YYYY-MM-DD (por defecto: hoy)"
  def show
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @reservations = @space.reservations.confirmed.where(date: @date).order(:start_time)
  end

  api :POST, "/spaces", "Crear un espacio (solo admin)"
  header "Authorization", "Bearer <token>", required: true
  param_group :space
  error code: 401, desc: "No autenticado (falta token)"
  error code: 403, desc: "No autorizado (no es admin)"
  error code: 422, desc: "Errores de validación"
  def create
    @space = Space.new(space_params)
    if @space.save
      render :create, status: :created
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :PATCH, "/spaces/:id", "Actualizar un espacio (solo admin)"
  api :PUT, "/spaces/:id"
  header "Authorization", "Bearer <token>", required: true
  param :id, :number, required: true
  param_group :space
  error code: 403, desc: "No autorizado (no es admin)"
  error code: 422, desc: "Errores de validación"
  def update
    if @space.update(space_params)
      render :update, status: :ok
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :DELETE, "/spaces/:id", "Desactivar un espacio (soft delete, solo admin)"
  header "Authorization", "Bearer <token>", required: true
  param :id, :number, required: true
  returns code: 200, desc: "{ message }"
  def destroy
    @space.update(status: :inactive)
    render json: { message: "Espacio desactivado" }, status: :ok
  end

  private

  def set_space
    @space = Space.find(params[:id])
  end

  def space_params
    params.require(:space).permit(:name, :capacity, :location, :start_time, :end_time, :status)
  end
end
