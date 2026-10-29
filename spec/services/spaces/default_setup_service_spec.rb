# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::DefaultSetupService do
  subject(:setup_default_space) { described_class.new(user).call }

  let(:user) { create(:user) }

  describe '#call' do
    it 'creates the default space and rooms' do
      space = setup_default_space

      expect(space).to have_attributes(user: user, name: 'My Home', space_type: 'home')
      expect(space.rooms.pluck(:name)).to contain_exactly(
        'Kitchen', 'Bathroom', 'Toilet', 'Bedroom', 'Hallway'
      )
    end

    it 'associates rooms with matching room types when they exist' do
      kitchen_type = create(:room_type, room_type_key: 'kitchen')

      space = setup_default_space

      expect(space.rooms.find_by!(name: 'Kitchen').room_type).to eq(kitchen_type)
    end

    it 'returns the existing space without creating another setup' do
      existing_space = create(:space, user: user, name: 'Existing Home')

      expect { setup_default_space }
        .not_to change { [Space.count, Room.count] }
      expect(setup_default_space).to eq(existing_space)
    end
  end
end
