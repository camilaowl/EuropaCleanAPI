# frozen_string_literal: true

class RoomItemsSerializer < Panko::Serializer
  attributes :id, :name, :item_type, :created_at, :updated_at

  def item_type
    object.item_type&.item_type_key
  end

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end
end
