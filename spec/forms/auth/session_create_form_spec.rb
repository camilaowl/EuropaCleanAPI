# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::SessionCreateForm do
  subject(:form) { described_class.new(email: email, password: submitted_password) }

  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:email) { user.email }
  let(:submitted_password) { password }

  context 'with valid credentials' do
    it 'finds the authenticated user' do
      expect(form.save).to be(true)
      expect(form.model).to eq(user)
      expect(form.errors).to eq({})
    end
  end

  context 'with an incorrect password' do
    let(:submitted_password) { 'wrong-password' }

    it 'does not expose a user' do
      expect(form.save).to be(false)
      expect(form.model).to be_nil
      expect(form.errors.fetch(:password)).to include('wrong email or password')
    end
  end

  context 'with an unknown email' do
    let(:email) { 'missing-user@example.com' }

    it 'returns the same credential error' do
      expect(form.save).to be(false)
      expect(form.errors.fetch(:password)).to include('wrong email or password')
    end
  end
end
