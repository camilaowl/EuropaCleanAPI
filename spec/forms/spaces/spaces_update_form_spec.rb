# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::SpacesUpdateForm do
  subject(:form) { described_class.new(user, params) }

  let(:user) { create(:user) }
  let(:space) { create(:space, user: user, name: 'Old Name') }
  let(:params) { { id: space.id.to_s, name: name } }
  let(:name) { 'New Name' }

  context 'with valid parameters' do
    it 'updates the user-owned space' do
      expect(form.save).to be(true)

      expect(form.model).to eq(space)
      expect(space.reload.name).to eq('New Name')
    end
  end

  context 'when the name is too short' do
    let(:name) { 'ab' }

    it 'does not update the space' do
      expect(form.save).to be(false)

      expect(space.reload.name).to eq('Old Name')
      expect(form.errors.fetch(:name)).to include('must be at least 3 characters long')
    end
  end

  context 'when the space belongs to another user' do
    let(:space) { create(:space) }

    it 'does not allow the record to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
