class ReservationsController < ApplicationController
  before_action :require_login
  before_action :set_reservation, only: [:show, :cancel]
  before_action :authorize_owner_or_admin, only: [:show, :cancel]

  def index
    @reservations =
      if current_user.admin?
        Reservation.includes(:space, :user).order(date: :desc, start_time: :desc)
      else
        current_user.reservations.includes(:space).order(date: :desc, start_time: :desc)
      end
  end

  def show
    render :show, status: :ok
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)

    if @reservation.save
      render :create, status: :created
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def cancel
    if @reservation.update(status: :cancelled)
      render :cancel, status: :ok
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def authorize_owner_or_admin
    return if current_user.admin?
    return if @reservation.user_id == current_user.id

    render json: { error: "No autorizado" }, status: :forbidden
  end

  def reservation_params
    params.require(:reservation).permit(:space_id, :date, :start_time, :end_time, :seats_reserved)
  end
end