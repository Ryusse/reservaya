class SpacesController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [:create, :update, :destroy]
  before_action :set_space, only: [:show, :update, :destroy]

  def index
    @spaces = Space.active
  end

  def show
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @reservations = @space.reservations.confirmed.where(date: @date).order(:start_time)
  end

  def create
    @space = Space.new(space_params)

    if @space.save
      render :create, status: :created
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @space.update(space_params)
      render :update, status: :ok
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    unless @space.inactive?
      return render json: { error: "Solo se pueden eliminar espacios inactivos" }, status: :unprocessable_entity
    end

    if @space.destroy
      render json: { message: "Espacio eliminado correctamente" }, status: :ok
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_space
    @space = Space.find(params[:id])
  end

  def space_params
    params.require(:space).permit(:name, :capacity, :location, :start_time, :end_time, :status, :space_type)
  end
end