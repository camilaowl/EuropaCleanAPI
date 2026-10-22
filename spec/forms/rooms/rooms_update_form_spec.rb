# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rooms::RoomsUpdateForm do
  subject(:form) { described_class.new(user, params) }

  let(:user) { create(:user) }
  let(:room) { create(:room, space: create(:space, user: user), name: 'Kitchen', room_type: :kitchen) }
  let(:params) { { id: room.id.to_s, name: 'Main Kitchen' } }

  context 'with valid parameters' do
    it 'partially updates the user-owned room' do
      expect(form.save).to be(true)

      expect(form.model).to eq(room)
      expect(room.reload).to have_attributes(name: 'Main Kitchen', room_type: 'kitchen')
    end
  end

  context 'with an unsupported room type' do
    let(:params) { { id: room.id.to_s, room_type: 'garden' } }

    it 'does not update the room' do
      expect(form.save).to be(false)

      expect(room.reload.room_type).to eq('kitchen')
      expect(form.errors.fetch(:room_type)).to include('is not included in the list')
    end
  end

  context 'without room attributes' do
    let(:params) { { id: room.id.to_s } }

    it 'does not perform an empty update' do
      expect(form.save).to be(false)
      expect(form.errors.fetch(nil)).to include('must include name or room_type')
    end
  end

  context 'when the room belongs to another user' do
    let(:room) { create(:room) }

    it 'does not allow the room to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
