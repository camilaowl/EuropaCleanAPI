# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomsSerializer do
  let(:room_type) { create(:room_type, room_type_key: 'kitchen') }
  let(:item_type) { create(:item_type, item_type_key: 'furniture') }
  let(:room) { create(:room, name: 'Kitchen', room_type: room_type) }

  it 'serializes room fields' do
    result = Serializer.new(room, serializer: described_class).to_h.fetch('room')

    expect(result).to include(
      'id' => room.id,
      'name' => 'Kitchen',
      'room_type' => 'kitchen',
      'created_at' => room.created_at.iso8601,
      'updated_at' => room.updated_at.iso8601
    )
  end

  it 'serializes nested room items' do
    item = create(:room_item, room: room, name: 'Table', item_type: item_type)

    result = Serializer.new(room, serializer: described_class).to_h.fetch('room')

    expect(result.fetch('room_items')).to eq([{
      'id' => item.id,
      'name' => 'Table',
      'item_type' => 'furniture',
      'created_at' => item.created_at.iso8601,
      'updated_at' => item.updated_at.iso8601
    }])
  end

  it 'serializes an empty item association as an array' do
    result = Serializer.new(room, serializer: described_class).to_h.fetch('room')

    expect(result.fetch('room_items')).to eq([])
  end
end
