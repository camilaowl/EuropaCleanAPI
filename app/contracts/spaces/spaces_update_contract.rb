# frozen_string_literal: true

class SpacesUpdateContract < ApplicationContract
  params do
    required(:id).filled(:string)
    optional(:name).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 3 characters long') if value.length < 3
  end
end