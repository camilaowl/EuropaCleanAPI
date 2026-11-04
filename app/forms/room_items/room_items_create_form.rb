# frozen_string_literal: true

class RoomItems::RoomItemsCreateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = RoomItems::RoomItemsCreateContract.new
  end

  private

  def persist!
    room = user_rooms.find(@validated_params.fetch(:room_id))
    item_type = ItemType.find_by!(item_type_key: @validated_params.fetch(:item_type))
    attributes = @validated_params.except(:room_id, :item_type).merge(item_type: item_type)

    @model = room.room_items.create!(attributes)
  end

  def user_rooms
    Room.where(space_id: user.spaces.select(:id))
  end
end
