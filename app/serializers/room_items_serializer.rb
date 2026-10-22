# frozen_string_literal: true

class RoomItemsSerializer < Panko::Serializer
  attributes :id, :name, :item_type, :created_at, :updated_at

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end
end
