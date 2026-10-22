# frozen_string_literal: true

class Rooms::RoomsCreateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Rooms::RoomsCreateContract.new
  end

  private

  def persist!
    space = user.spaces.find(@validated_params.fetch(:space_id))
    @model = space.rooms.create!(@validated_params.except(:space_id))
  end
end
