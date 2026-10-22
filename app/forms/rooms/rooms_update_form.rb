# frozen_string_literal: true

class Rooms::RoomsUpdateForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Rooms::RoomsUpdateContract.new
  end

  private

  def persist!
    @model = user_rooms.find(@validated_params.fetch(:id))
    @model.update!(@validated_params.except(:id))
  end

  def user_rooms
    Room.where(space_id: user.spaces.select(:id))
  end
end
