# frozen_string_literal: true

class Rooms::RoomsDeleteForm < BaseForm
  attr_reader :user

  def initialize(user, params)
    super(params)
    @user = user
    @contract = Rooms::RoomsDeleteContract.new
  end

  private

  def persist!
    @model = user_rooms.find(@validated_params.fetch(:id))
    @model.destroy!
  end

  def user_rooms
    Room.where(space_id: user.spaces.select(:id))
  end
end
