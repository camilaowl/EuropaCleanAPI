# frozen_string_literal: true

class Rooms::RoomsDeleteContract < ApplicationContract
  params do
    required(:id).filled(:string)
  end
end
