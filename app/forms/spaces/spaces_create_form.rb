# frozen_string_literal: true

class Spaces::SpacesCreateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Spaces::SpacesCreateContract.new
  end

  private

  def persist!
    @model = user.spaces.create!(@validated_params)
  end
end
