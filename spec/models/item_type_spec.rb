# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ItemType, type: :model do
  describe 'room item membership' do
    it 'collects room items that use the type' do
      item_type = create(:item_type)
      room_item = create(:room_item, item_type: item_type)

      expect(item_type.room_items).to contain_exactly(room_item)
    end
  end

  describe 'destroying an item type' do
    it 'is restricted while a room item uses the type' do
      item_type = create(:item_type)
      create(:room_item, item_type: item_type)

      expect(item_type.destroy).to be(false)
      expect(item_type.errors[:base]).to be_present
      expect(item_type.reload).to be_persisted
    end

    it 'succeeds when no room item uses the type' do
      item_type = create(:item_type)

      expect { item_type.destroy! }.to change(described_class, :count).by(-1)
    end
  end
end
