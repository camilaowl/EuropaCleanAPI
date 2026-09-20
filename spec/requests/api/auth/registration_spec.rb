# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/auth/sign_up', type: :request do
  subject(:sign_up_request) { post '/api/auth/sign_up', params: params, as: :json }

  let(:email) { 'new-user@example.com' }
  let(:password) { 'password123' }
  let(:password_confirmation) { password }
  let(:params) do
    {
      user: attributes_for(
        :user,
        email: email,
        password: password,
        password_confirmation: password_confirmation
      )
    }
  end

  context 'when parameters are valid' do
    it 'creates a user and returns its public data' do
      expect { sign_up_request }.to change(User, :count).by(1)

      user = User.find_by!(email: email)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq(
        'user' => { 'id' => user.id, 'email' => user.email }
      )
    end
  end

  context 'when password confirmation does not match' do
    let(:password_confirmation) { 'different-password' }

    it 'does not create a user and returns validation errors' do
      expect { sign_up_request }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.fetch('errors'))
        .to include("Password confirmation doesn't match Password")
    end
  end

  context 'when the email is already registered' do
    before { create(:user, email: email) }

    it 'does not create another user and returns validation errors' do
      expect { sign_up_request }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.fetch('errors')).to include('Email has already been taken')
    end
  end

  context 'when user parameters are missing' do
    let(:params) { {} }

    it 'does not create a user and returns bad request' do
      expect { sign_up_request }.not_to change(User, :count)

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.fetch('error')).to match(/param is missing.*user/)
    end
  end
end
