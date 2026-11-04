# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomType, type: :model do
  describe 'room membership' do
    it 'collects rooms that use the type' do
      room_type = create(:room_type)
      room = create(:room, room_type: room_type)

      expect(room_type.rooms).to contain_exactly(room)
    end
  end

  describe 'destroying a room type' do
    it 'is restricted while a room uses the type' do
      room_type = create(:room_type)
      create(:room, room_type: room_type)

      expect(room_type.destroy).to be(false)
      expect(room_type.errors[:base]).to be_present
      expect(room_type.reload).to be_persisted
    end

    it 'succeeds when no room uses the type' do
      room_type = create(:room_type)

      expect { room_type.destroy! }.to change(described_class, :count).by(-1)
    end
  end
end
