# frozen_string_literal: true

class Rooms::RoomsUpdateContract < ApplicationContract
  params do
    required(:id).filled(:string)
    optional(:name).filled(:string)
    optional(:room_type).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 3 characters long') if key? && value.length < 3
  end

  rule(:room_type) do
    key.failure('is not included in the list') if key? && !RoomType.exists?(room_type_key: value)
  end

  rule do
    base.failure('must include name or room_type') if values.keys.intersection(%i[name room_type]).empty?
  end
end
