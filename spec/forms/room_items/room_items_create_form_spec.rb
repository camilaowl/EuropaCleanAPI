# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomItems::RoomItemsCreateForm do
  subject(:form) { described_class.new(user, params) }

  let(:user) { create(:user) }
  let(:room) { create(:room, space: create(:space, user: user)) }
  let(:item_type) { create(:item_type, item_type_key: 'furniture') }
  let(:params) { { room_id: room.id, name: 'Table', item_type: item_type.item_type_key } }

  context 'with valid parameters' do
    it 'creates an item in the user-owned room' do
      expect { form.save }.to change(room.room_items, :count).by(1)

      expect(form.model).to have_attributes(name: 'Table', item_type: item_type, room: room)
      expect(form.errors).to eq({})
    end
  end

  context 'with an unsupported item type' do
    let(:params) { super().merge(item_type: 'unknown') }

    it 'does not create an item and exposes validation errors' do
      expect { form.save }.not_to change(RoomItem, :count)

      expect(form.model).to be_nil
      expect(form.errors.fetch(:item_type)).to include('is not included in the list')
    end
  end

  context 'when the room belongs to another user' do
    let(:room) { create(:room) }

    it 'does not allow the room to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
