# frozen_string_literal: true

class Api::RoomItemsController < Api::BaseController
  before_action :set_room_item, only: [:show, :update, :destroy]
  before_action :set_room, only: :index

  after_action :verify_authorized

  def index
    render json: ArraySerializer.new(
      @room.room_items,
      each_serializer: RoomItemsSerializer
    ).to_json, status: :ok
  end

  def show
    render json: Serializer.new(
      @room_item,
      serializer: RoomItemsSerializer
    ).to_json, status: :ok
  end

  def create
    authorize RoomItem

    form = RoomItems::RoomItemsCreateForm.new(current_user, room_item_create_params)
    if form.save
      render json: Serializer.new(
        form.model,
        serializer: RoomItemsSerializer
      ).to_json, status: :created
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def update
    form = RoomItems::RoomItemsUpdateForm.new(
      current_user,
      room_item_update_params.merge(id: params[:id])
    )
    if form.save
      render json: Serializer.new(
        form.model,
        serializer: RoomItemsSerializer
      ).to_json, status: :ok
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    form = RoomItems::RoomItemsDeleteForm.new(current_user, id: params[:id])
    if form.save
      head :no_content
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_room
    @room = user_rooms.find(params[:room_id])
    authorize @room
  end

  def set_room_item
    @room_item = RoomItem.where(room_id: user_rooms.select(:id)).find(params[:id])
    authorize @room_item
  end

  def user_rooms
    Room.where(space_id: current_user.spaces.select(:id))
  end

  def room_item_create_params
    required_object_param(:room_item).permit(:room_id, :name, :item_type)
  end

  def room_item_update_params
    required_object_param(:room_item).permit(:room_id, :name, :item_type)
  end
end
