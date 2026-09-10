class ReservationsController < ApiController
  before_action :require_login
  before_action :set_reservation, only: [:update, :cancel]
  before_action :authorize_owner, only: [:update, :cancel]

  def index
    @reservations = current_user.reservations.order(date: :desc, start_time: :desc)
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)
    if @reservation.save
      render :create, status: :created
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @reservation.update(reservation_params)
      render :update, status: :ok
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

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