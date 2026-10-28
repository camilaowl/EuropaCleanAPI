# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomItem, type: :model do
  describe 'room membership' do
    it 'is invalid without a room' do
      room_item = build(:room_item, room: nil)

      expect(room_item).not_to be_valid
      expect(room_item.errors.of_kind?(:room, :blank)).to be(true)
    end
  end

  describe 'item type membership' do
    it 'can reference an item type' do
      item_type = create(:item_type)
      room_item = create(:room_item, item_type: item_type)

      expect(room_item.reload.item_type).to eq(item_type)
      expect(item_type.room_items).to contain_exactly(room_item)
    end

    it 'is valid without an item type' do
      expect(build(:room_item, item_type: nil)).to be_valid
    end
  end
end
