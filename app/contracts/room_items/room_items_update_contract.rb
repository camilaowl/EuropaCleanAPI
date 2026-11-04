# frozen_string_literal: true

class RoomItems::RoomItemsUpdateContract < ApplicationContract
  params do
    required(:id).filled(:string)
    optional(:name).filled(:string)
    optional(:item_type).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 3 characters long') if key? && value.length < 3
  end

  rule(:item_type) do
    key.failure('is not included in the list') if key? && !ItemType.exists?(item_type_key: value)
  end

  rule do
    base.failure('must include name or item_type') if values.keys.intersection(%i[name item_type]).empty?
  end
end
