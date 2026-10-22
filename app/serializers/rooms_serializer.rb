# frozen_string_literal: true

class RoomsSerializer < Panko::Serializer
  attributes :id, :name, :room_type, :created_at, :updated_at
  has_many :room_items, serializer: RoomItemsSerializer

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end
end
