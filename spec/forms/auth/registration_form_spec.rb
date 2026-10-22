# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationForm do
  subject(:form) { described_class.new(params) }

  let(:params) do
    {
      email: 'new-user@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  end

  context 'with valid parameters' do
    it 'creates a user and exposes it as the model' do
      expect { form.save }.to change(User, :count).by(1)

      expect(form.model).to be_persisted
      expect(form.model).to have_attributes(email: 'new-user@example.com')
      expect(form.errors).to eq({})
    end
  end

  context 'with an invalid email' do
    before { params[:email] = 'invalid-email' }

    it 'does not create a user and exposes validation errors' do
      expect { form.save }.not_to change(User, :count)

      expect(form.model).to be_nil
      expect(form.errors.fetch(:email)).to include('must be a valid email address')
    end
  end

  context 'when password confirmation does not match' do
    before { params[:password_confirmation] = 'different-password' }

    it 'does not create a user and exposes validation errors' do
      expect { form.save }.not_to change(User, :count)

      expect(form.errors.fetch(:password_confirmation)).to include('must match password')
    end
  end
end
