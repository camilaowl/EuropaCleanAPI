# frozen_string_literal: true

class Spaces::SpacesDeleteContract < ApplicationContract
  params do
    required(:id).filled(:string)
  end
end
