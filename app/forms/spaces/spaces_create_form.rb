# frozen_string_literal: true

class SpacesCreateForm < BaseForm

  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = SpacesCreateContract.new
  end

  private

  def persist!
    @model = user.spaces.create!(@validated_params)
  end
end