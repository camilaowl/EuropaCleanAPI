# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomItemsSerializer do
  let(:item_type) { create(:item_type, item_type_key: 'furniture') }
  let(:room_item) { create(:room_item, name: 'Table', item_type: item_type) }

  it 'serializes room item fields' do
    result = Serializer.new(room_item, serializer: described_class).to_h.fetch('room_item')

    expect(result).to eq(
      'id' => room_item.id,
      'name' => 'Table',
      'item_type' => 'furniture',
      'created_at' => room_item.created_at.iso8601,
      'updated_at' => room_item.updated_at.iso8601
    )
  end
end
