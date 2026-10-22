# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::SpacesCreateForm do
  subject(:form) { described_class.new(user, params) }

  let(:user) { create(:user) }
  let(:params) { { name: name } }
  let(:name) { 'Family Home' }

  context 'with valid parameters' do
    it 'creates a space owned by the user' do
      expect { form.save }.to change(user.spaces, :count).by(1)

      expect(form.model).to have_attributes(name: name, user: user, space_type: 'home')
      expect(form.errors).to eq({})
    end
  end

  context 'when the name is too short' do
    let(:name) { 'ab' }

    it 'does not create a space and exposes validation errors' do
      expect { form.save }.not_to change(Space, :count)

      expect(form.model).to be_nil
      expect(form.errors.fetch(:name)).to include('must be at least 3 characters long')
    end
  end
end
