# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rooms::RoomsCreateForm do
  subject(:form) { described_class.new(user, params) }

  let(:user) { create(:user) }
  let(:space) { create(:space, user: user) }
  let(:room_type) { create(:room_type, room_type_key: 'kitchen') }
  let(:params) { { space_id: space.id, name: 'Kitchen', room_type: room_type.room_type_key } }

  context 'with valid parameters' do
    it 'creates a room in the user-owned space' do
      expect { form.save }.to change(space.rooms, :count).by(1)

      expect(form.model).to have_attributes(name: 'Kitchen', room_type: room_type, space: space)
      expect(form.errors).to eq({})
    end
  end

  context 'with an unsupported room type' do
    let(:params) { super().merge(room_type: 'garden') }

    it 'does not create a room and exposes validation errors' do
      expect { form.save }.not_to change(Room, :count)

      expect(form.model).to be_nil
      expect(form.errors.fetch(:room_type)).to include('is not included in the list')
    end
  end

  context 'when the space belongs to another user' do
    let(:space) { create(:space) }

    it 'does not allow the space to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
