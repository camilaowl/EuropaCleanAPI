# frozen_string_literal: true

class Rooms::RoomsUpdateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Rooms::RoomsUpdateContract.new
  end

  private

  def persist!
    @model = user_rooms.find(@validated_params.fetch(:id))
    attributes = @validated_params.except(:id)
    room_type_key = attributes.delete(:room_type)
    attributes[:room_type] = RoomType.find_by!(room_type_key: room_type_key) if room_type_key

    @model.update!(attributes)
  end

  def user_rooms
    Room.where(space_id: user.spaces.select(:id))
  end
end
