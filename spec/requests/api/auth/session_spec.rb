# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API auth sessions', type: :request do
  describe 'POST /api/auth/sign_in' do
    subject(:sign_in_request) { post '/api/auth/sign_in', params: params, as: :json }

    let(:password) { 'password123' }
    let(:user) { create(:user, password: password, password_confirmation: password) }
    let(:email) { user.email }
    let(:submitted_password) { password }
    let(:params) { { user: { email: email, password: submitted_password } } }

    context 'when credentials are valid' do
      it 'returns the user and a JWT in the authorization header' do
        sign_in_request

        authorization_header = response.headers.fetch('Authorization')

        expect(response).to have_http_status(:ok)
        expect(authorization_header).to match(/\ABearer \S+\z/)
        expect(response.parsed_body).to eq(
          'user' => { 'id' => user.id, 'email' => user.email }
        )
      end
    end

    context 'when the password is incorrect' do
      let(:submitted_password) { 'wrong-password' }

      it 'returns unauthorized with a generic error' do
        sign_in_request

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq('error' => 'Invalid email or password')
      end
    end

    context 'when the email is not registered' do
      let(:email) { 'missing-user@example.com' }

      it 'returns the same generic unauthorized error' do
        sign_in_request

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq('error' => 'Invalid email or password')
      end
    end

    context 'when user parameters are missing' do
      let(:params) { {} }

      it 'returns bad request' do
        sign_in_request

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.fetch('error')).to match(/param is missing.*user/)
      end
    end
  end

  describe 'DELETE /api/auth/sign_out' do
    subject(:sign_out_request) do
      delete '/api/auth/sign_out', headers: authorization_headers, as: :json
    end

    let(:password) { 'password123' }
    let(:user) { create(:user, password: password, password_confirmation: password) }
    let(:sign_in_params) { { user: { email: user.email, password: password } } }
    let(:authorization_header) do
      post '/api/auth/sign_in', params: sign_in_params, as: :json
      response.headers.fetch('Authorization')
    end
    let(:authorization_headers) { { 'Authorization' => authorization_header } }

    context 'when the token is valid' do
      it 'revokes the token and returns no content' do
        previous_jti = user.jti

        sign_out_request

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
        expect(user.reload.jti).not_to eq(previous_jti)
      end

      it 'rejects the token after it has been revoked' do
        sign_out_request

        delete '/api/auth/sign_out', headers: authorization_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the authorization header is missing' do
      let(:authorization_headers) { {} }

      it 'returns unauthorized' do
        sign_out_request

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the token is invalid' do
      let(:authorization_header) { 'Bearer invalid-token' }

      it 'returns unauthorized' do
        sign_out_request

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
