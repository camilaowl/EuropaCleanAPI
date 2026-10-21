# frozen_string_literal: true

class SpacesDeleteContract < ApplicationContract
  params do
    required(:id).filled(:string)
  end
end