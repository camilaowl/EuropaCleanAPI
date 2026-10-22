# frozen_string_literal: true

class Spaces::SpacesCreateContract < ApplicationContract
  params do
    required(:name).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 3 characters long') if value.length < 3
  end
end
