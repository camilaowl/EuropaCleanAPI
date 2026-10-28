# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomItems::RoomItemsUpdateForm do
  subject(:form) { described_class.new(user, params) }

  let(:user) { create(:user) }
  let(:item_type) { create(:item_type, item_type_key: 'furniture') }
  let(:room_item) do
    create(
      :room_item,
      room: create(:room, space: create(:space, user: user)),
      name: 'Table',
      item_type: item_type
    )
  end
  let(:params) { { id: room_item.id.to_s, name: 'Dining Table' } }

  context 'with valid parameters' do
    it 'partially updates the user-owned item' do
      expect(form.save).to be(true)

      expect(form.model).to eq(room_item)
      expect(room_item.reload).to have_attributes(name: 'Dining Table', item_type: item_type)
    end
  end

  context 'with an unsupported item type' do
    let(:params) { { id: room_item.id.to_s, item_type: 'unknown' } }

    it 'does not update the item' do
      expect(form.save).to be(false)

      expect(room_item.reload.item_type).to eq(item_type)
      expect(form.errors.fetch(:item_type)).to include('is not included in the list')
    end
  end

  context 'without item attributes' do
    let(:params) { { id: room_item.id.to_s } }

    it 'does not perform an empty update' do
      expect(form.save).to be(false)
      expect(form.errors.fetch(nil)).to include('must include name or item_type')
    end
  end

  context 'when the item belongs to another user' do
    let(:room_item) { create(:room_item) }

    it 'does not allow the item to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
