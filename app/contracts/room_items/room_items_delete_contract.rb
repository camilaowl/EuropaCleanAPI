# frozen_string_literal: true

class RoomItems::RoomItemsDeleteContract < ApplicationContract
  params do
    required(:id).filled(:string)
  end
end
