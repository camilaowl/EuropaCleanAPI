# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe '.room_types' do
    it 'exposes the supported room types' do
      expect(described_class.room_types).to eq(
        'bedroom' => 'bedroom',
        'bathroom' => 'bathroom',
        'kitchen' => 'kitchen',
        'living_room' => 'living_room',
        'dining_room' => 'dining_room',
        'office' => 'office',
        'garage' => 'garage',
        'basement' => 'basement',
        'attic' => 'attic',
        'other' => 'other'
      )
    end
  end

  describe 'space membership' do
    it 'is invalid without a space' do
      room = build(:room, space: nil)

      expect(room).not_to be_valid
      expect(room.errors.of_kind?(:space, :blank)).to be(true)
    end
  end

  describe 'destroying a room' do
    it 'destroys its items' do
      room = create(:room)
      room_item = create(:room_item, room: room)

      room.destroy!

      expect(described_class.exists?(room.id)).to be(false)
      expect(RoomItem.exists?(room_item.id)).to be(false)
    end
  end
end
