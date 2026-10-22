# frozen_string_literal: true

class Rooms::RoomsCreateContract < ApplicationContract
  params do
    required(:space_id).filled(:integer)
    required(:name).filled(:string)
    required(:room_type).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 3 characters long') if value.length < 3
  end

  rule(:room_type) do
    key.failure('is not included in the list') unless Room.room_types.key?(value)
  end
end
