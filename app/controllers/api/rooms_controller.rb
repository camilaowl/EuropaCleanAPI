# frozen_string_literal: true

class Api::RoomsController < Api::BaseController
  before_action :set_room, only: [:show, :update, :destroy]
  before_action :set_space, only: :index

  after_action :verify_authorized

  def index
    render json: ArraySerializer.new(
      @space.rooms,
      each_serializer: RoomsSerializer
    ).to_json, status: :ok
  end

  def show
    render json: Serializer.new(
      @room,
      serializer: RoomsSerializer
    ).to_json, status: :ok
  end

  def create
    authorize Room

    form = Rooms::RoomsCreateForm.new(current_user, room_create_params)
    if form.save
      render json: Serializer.new(
        form.model,
        serializer: RoomsSerializer
      ).to_json, status: :created
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def update
    form = Rooms::RoomsUpdateForm.new(current_user, room_update_params.merge(id: params[:id]))
    if form.save
      render json: Serializer.new(
        form.model,
        serializer: RoomsSerializer
      ).to_json, status: :ok
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    form = Rooms::RoomsDeleteForm.new(current_user, id: params[:id])
    if form.save
      head :no_content
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_space
    @space = Space.where(user_id: current_user.id).find(params[:space_id])
    authorize @space
  end

  def set_room
    @room = Room.where(space_id: current_user.spaces.select(:id)).find(params[:id])
    authorize @room
  end

  def room_create_params
    required_object_param(:room).permit(:space_id, :name, :room_type)
  end

  def room_update_params
    required_object_param(:room).permit(:space_id, :name, :room_type)
  end
end
