# frozen_string_literal: true

class RoomItems::RoomItemsCreateContract < ApplicationContract
  params do
    required(:room_id).filled(:integer)
    required(:name).filled(:string)
    required(:item_type).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 3 characters long') if value.length < 3
  end

  rule(:item_type) do
    key.failure('is not included in the list') unless ItemType.exists?(item_type_key: value)
  end
end
