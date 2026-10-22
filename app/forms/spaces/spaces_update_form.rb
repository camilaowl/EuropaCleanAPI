# frozen_string_literal: true

class SpacesUpdateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = SpacesUpdateContract.new
  end

  private

  def persist!
    @model = user.spaces.find(@validated_params.fetch(:id))
    @model.update!(@validated_params.except(:id))
  end
end