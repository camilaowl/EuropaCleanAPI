# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpacesSerializer do
  let(:space) { create(:space, name: 'Family Home') }

  it 'serializes space fields and its owner' do
    result = Serializer.new(space, serializer: described_class).to_h.fetch('space')

    expect(result).to include(
      'id' => space.id,
      'name' => 'Family Home',
      'space_type' => 'home',
      'created_at' => space.created_at.iso8601,
      'updated_at' => space.updated_at.iso8601
    )
    expect(result.fetch('user')).to include('id' => space.user.id, 'email' => space.user.email)
    expect(result.dig('user', 'created_at')).to eq(space.user.created_at.iso8601)
  end

  it 'serializes nested rooms and items' do
    room = create(:room, space: space, name: 'Kitchen', room_type: :kitchen)
    item = create(:room_item, room: room, name: 'Table')

    result = Serializer.new(space, serializer: described_class).to_h.fetch('space')

    serialized_room = result.fetch('rooms').sole
    expect(serialized_room).to include(
      'id' => room.id,
      'name' => 'Kitchen',
      'room_type' => 'kitchen',
      'created_at' => room.created_at.iso8601,
      'updated_at' => room.updated_at.iso8601
    )

    expect(serialized_room.fetch('room_items')).to eq([{
      'id' => item.id,
      'name' => 'Table',
      'item_type' => 'furniture',
      'created_at' => item.created_at.iso8601,
      'updated_at' => item.updated_at.iso8601
    }])
  end

  it 'serializes empty associations as arrays' do
    result = Serializer.new(space, serializer: described_class).to_h.fetch('space')

    expect(result.fetch('rooms')).to eq([])
  end
end
