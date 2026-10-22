# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomsSerializer do
  let(:room) { create(:room, name: 'Kitchen', room_type: :kitchen) }

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
    item = create(:room_item, room: room, name: 'Table')

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
