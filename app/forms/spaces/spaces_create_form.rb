# frozen_string_literal: true

class SpacesCreateForm < BaseForm

  attr_reader :user

  def initialize(params, user)
    super(params)
    @user = user
    @contract = SpacesCreateContract.new
  end

  private

  def persist!
    @model = user.spaces.create!(@validated_params)
  end
end