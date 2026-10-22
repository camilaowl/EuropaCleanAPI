# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomItem, type: :model do
  describe '.item_types' do
    it 'exposes the supported item types' do
      expect(described_class.item_types).to eq(
        'furniture' => 'furniture',
        'other' => 'other'
      )
    end
  end

  describe 'room membership' do
    it 'is invalid without a room' do
      room_item = build(:room_item, room: nil)

      expect(room_item).not_to be_valid
      expect(room_item.errors.of_kind?(:room, :blank)).to be(true)
    end
  end
end
