# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space, type: :model do
  describe '.space_types' do
    it 'exposes the supported space types' do
      expect(described_class.space_types).to eq(
        'home' => 'home',
        'office' => 'office',
        'warehouse' => 'warehouse',
        'car' => 'car',
        'other' => 'other'
      )
    end
  end

  describe 'defaults' do
    it 'defaults the space type to home' do
      expect(described_class.new.space_type).to eq('home')
    end
  end

  describe 'user ownership' do
    it 'is invalid without a user' do
      space = build(:space, user: nil)

      expect(space).not_to be_valid
      expect(space.errors.of_kind?(:user, :blank)).to be(true)
    end
  end

  describe 'destroying a space' do
    it 'destroys its rooms and their items' do
      space = create(:space)
      room = create(:room, space: space)
      room_item = create(:room_item, room: room)

      space.destroy!

      expect(described_class.exists?(space.id)).to be(false)
      expect(Room.exists?(room.id)).to be(false)
      expect(RoomItem.exists?(room_item.id)).to be(false)
    end
  end
end
