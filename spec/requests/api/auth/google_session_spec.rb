# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/auth/google', type: :request do
  subject(:google_sign_in_request) do
    post '/api/auth/google', params: { google: { id_token: id_token } }, as: :json
  end

  let(:id_token) { 'google-id-token' }
  let(:google_uid) { 'google-subject-123' }
  let(:email) { 'google-user@example.com' }
  let(:claims) { { 'sub' => google_uid, 'email' => email } }

  before do
    allow(Auth::GoogleIdTokenVerifier).to receive(:call).with(id_token).and_return(claims)
  end

  context 'when the Google identity is new' do
    it 'creates the user and returns a JWT' do
      expect { google_sign_in_request }.to change(User, :count).by(1)

      user = User.find_by!(provider: 'google', uid: google_uid)

      expect(response).to have_http_status(:ok)
      expect(response.headers.fetch('Authorization')).to match(/\ABearer \S+\z/)
      expect(response.parsed_body).to eq(
        'user' => { 'id' => user.id, 'email' => email }
      )
    end
  end

  context 'when the email already belongs to a password user' do
    let!(:user) { create(:user, email: email) }

    it 'links the Google identity without creating a duplicate user' do
      expect { google_sign_in_request }.not_to change(User, :count)

      expect(response).to have_http_status(:ok)
      expect(user.reload).to have_attributes(provider: 'google', uid: google_uid)
    end
  end

  context 'when the Google identity already exists' do
    let!(:user) { create(:user, email: email, provider: 'google', uid: google_uid) }

    it 'signs in the existing user' do
      expect { google_sign_in_request }.not_to change(User, :count)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('user', 'id')).to eq(user.id)
    end
  end

  context 'when the ID token is invalid' do
    before do
      allow(Auth::GoogleIdTokenVerifier).to receive(:call)
        .and_raise(Auth::GoogleIdTokenVerifier::InvalidToken)
    end

    it 'returns unauthorized without creating a user' do
      expect { google_sign_in_request }.not_to change(User, :count)

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq('error' => 'Invalid Google ID token')
    end
  end

  context 'when the Google parameters are missing' do
    it 'returns bad request' do
      post '/api/auth/google', params: {}, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.fetch('error')).to match(/param is missing.*google/)
    end
  end

  context 'when the ID token is missing' do
    it 'returns bad request' do
      post '/api/auth/google', params: { google: { unexpected: true } }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.fetch('error')).to match(/param is missing.*id_token/)
    end
  end

  context 'when the email is linked to a different Google identity' do
    before { create(:user, email: email, provider: 'google', uid: 'different-subject') }

    it 'returns conflict without changing the link' do
      google_sign_in_request

      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body).to eq(
        'error' => 'Google account is already linked to another user'
      )
    end
  end
end
