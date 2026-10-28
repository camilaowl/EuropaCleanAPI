# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomItems::RoomItemsDeleteForm do
  subject(:form) { described_class.new(user, id: room_item.id.to_s) }

  let(:user) { create(:user) }
  let(:room_item) do
    create(:room_item, room: create(:room, space: create(:space, user: user)))
  end

  context 'when the user owns the item' do
    it 'deletes the item and exposes the deleted model' do
      room_item

      expect { form.save }.to change(RoomItem, :count).by(-1)
      expect(form.model).to eq(room_item)
      expect(form.model).to be_destroyed
    end
  end

  context 'when the item belongs to another user' do
    let(:room_item) { create(:room_item) }

    it 'does not allow the item to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
      expect(room_item.reload).to be_persisted
    end
  end
end
