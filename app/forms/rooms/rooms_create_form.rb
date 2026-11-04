# frozen_string_literal: true

class Rooms::RoomsCreateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Rooms::RoomsCreateContract.new
  end

  private

  def persist!
    space = user.spaces.find(@validated_params.fetch(:space_id))
    room_type = RoomType.find_by!(room_type_key: @validated_params.fetch(:room_type))
    attributes = @validated_params.except(:space_id, :room_type).merge(room_type: room_type)

    @model = space.rooms.create!(attributes)
  end
end
