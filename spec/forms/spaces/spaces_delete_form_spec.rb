# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::SpacesDeleteForm do
  subject(:form) { described_class.new(user, id: space.id.to_s) }

  let(:user) { create(:user) }
  let(:space) { create(:space, user: user) }

  context 'when the user owns the space' do
    it 'deletes the space and exposes the deleted model' do
      space

      expect { form.save }.to change(Space, :count).by(-1)
      expect(form.model).to eq(space)
      expect(form.model).to be_destroyed
    end
  end

  context 'when the space belongs to another user' do
    let(:space) { create(:space) }

    it 'does not allow the record to be accessed' do
      expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
      expect(space.reload).to be_persisted
    end
  end
end
