# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rooms::RoomsDeleteForm do
  subject(:form) { described_class.new(user, id: room.id.to_s) }

  let(:user) { create(:user) }
  let(:room) { create(:room, space: create(:space, user: user)) }

  context 'when the user owns the room' do
    it 'deletes the room and exposes the deleted model' do
      room

      expect { form.save }.to change(Room, :count).by(-1)
      expect(form.model).to eq(room)
      expect(form.model).to be_destroyed
    end
  end

  context 'when the room belongs to another user' do
    let(:room) { create(:room) }

    it 'does not allow the room to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
      expect(room.reload).to be_persisted
    end
  end
end
