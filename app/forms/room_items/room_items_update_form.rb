# frozen_string_literal: true

class RoomItems::RoomItemsUpdateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = RoomItems::RoomItemsUpdateContract.new
  end

  private

  def persist!
    @model = user_room_items.find(@validated_params.fetch(:id))
    attributes = @validated_params.except(:id)
    item_type_key = attributes.delete(:item_type)
    attributes[:item_type] = ItemType.find_by!(item_type_key: item_type_key) if item_type_key

    @model.update!(attributes)
  end

  def user_room_items
    RoomItem.where(room_id: user_rooms.select(:id))
  end

  def user_rooms
    Room.where(space_id: user.spaces.select(:id))
  end
end
