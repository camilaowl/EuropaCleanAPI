# frozen_string_literal: true

class RoomItems::RoomItemsDeleteForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = RoomItems::RoomItemsDeleteContract.new
  end

  private

  def persist!
    @model = user_room_items.find(@validated_params.fetch(:id))
    @model.destroy!
  end

  def user_room_items
    RoomItem.where(room_id: user_rooms.select(:id))
  end

  def user_rooms
    Room.where(space_id: user.spaces.select(:id))
  end
end
