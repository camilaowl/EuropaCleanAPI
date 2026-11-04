# frozen_string_literal: true

class Spaces::DefaultSetupService
  DEFAULT_SPACE_NAME = 'My Home'.freeze

  DEFAULT_ROOMS = {
    kitchen: 'Kitchen',
    bathroom: 'Bathroom',
    toilet: 'Toilet',
    bedroom: 'Bedroom',
    hallway: 'Hallway'
  }.freeze

  def initialize(user)
    @user = user
  end

  def call
    Space.transaction do
      existing_space = @user.spaces.first
      return existing_space if existing_space.present?

      space = default_space
      default_rooms(space)
      space
    end
  end

  private

  def default_space = @user.spaces.create!(name: DEFAULT_SPACE_NAME)

  def default_rooms(space)
    DEFAULT_ROOMS.each do |key, name|
      room_type = RoomType.find_by(room_type_key: key)
      space.rooms.create!(name: name, room_type: room_type)
    end
  end
end
