# frozen_string_literal: true

class Spaces::SpacesDeleteForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Spaces::SpacesDeleteContract.new
  end

  private

  def persist!
    @model = user.spaces.find(@validated_params.fetch(:id))
    @model.destroy!
  end
end
