# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'space membership' do
    it 'is invalid without a space' do
      room = build(:room, space: nil)

      expect(room).not_to be_valid
      expect(room.errors.of_kind?(:space, :blank)).to be(true)
    end
  end

  describe 'room type membership' do
    it 'can reference a room type' do
      room_type = create(:room_type)
      room = create(:room, room_type: room_type)

      expect(room.reload.room_type).to eq(room_type)
      expect(room_type.rooms).to contain_exactly(room)
    end

    it 'is valid without a room type' do
      expect(build(:room, room_type: nil)).to be_valid
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
