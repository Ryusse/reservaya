class ReservationsController < ApiController
  before_action :require_login
  before_action :set_reservation, only: [:update, :cancel]
  before_action :authorize_owner, only: [:update, :cancel]

  resource_description do
    short "Reservas"
    description "Cada reserva pertenece al usuario del token. update y cancel solo los puede hacer el dueño."
  end

  api :GET, "/reservations", "Lista las reservas del usuario autenticado"
  header "Authorization", "Bearer <token>", required: true
  def index
    @reservations = current_user.reservations.order(date: :desc, start_time: :desc)
  end

  api :POST, "/reservations", "Crear una reserva"
  header "Authorization", "Bearer <token>", required: true
  param :reservation, Hash, required: true do
    param :space_id, :number, required: true
    param :date, String, required: true, desc: "YYYY-MM-DD, no puede ser pasada"
    param :start_time, String, required: true, desc: "HH:MM"
    param :end_time, String, required: true, desc: "HH:MM, debe ser posterior a start_time"
  end
  returns code: 201, desc: "{ id, space_id, date, start_time, end_time, status }"
  error code: 422, desc: "Fecha pasada, espacio inactivo, solapamiento u otros errores de validación"
  def create
    @reservation = current_user.reservations.new(reservation_params)
    if @reservation.save
      render :create, status: :created
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :PATCH, "/reservations/:id", "Actualizar una reserva (solo el dueño)"
  api :PUT, "/reservations/:id"
  header "Authorization", "Bearer <token>", required: true
  param :id, :number, required: true
  param :reservation, Hash, required: true do
    param :space_id, :number
    param :date, String
    param :start_time, String
    param :end_time, String
  end
  error code: 403, desc: "No autorizado (no es el dueño)"
  error code: 422, desc: "Errores de validación"
  def update
    if @reservation.update(reservation_params)
      render :update, status: :ok
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :PATCH, "/reservations/:id/cancel", "Cancelar una reserva (solo el dueño)"
  header "Authorization", "Bearer <token>", required: true
  param :id, :number, required: true
  returns code: 200, desc: "La reserva con status = cancelled"
  error code: 403, desc: "No autorizado (no es el dueño)"
  def cancel
    @reservation.update(status: :cancelled)
    render :cancel, status: :ok
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def authorize_owner
    render json: { error: "No autorizado" }, status: :forbidden unless @reservation.user_id == current_user.id
  end

  def reservation_params
    params.require(:reservation).permit(:space_id, :date, :start_time, :end_time)
  end
end
