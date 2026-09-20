# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::GoogleIdTokenVerifier do
  subject(:verify) { described_class.call(id_token) }

  let(:id_token) { 'google-id-token' }
  let(:client_ids) { %w[web-client-id mobile-client-id] }
  let(:payload) do
    {
      'sub' => 'google-subject-123',
      'email' => 'person@example.com',
      'email_verified' => true,
      'name' => 'Ignored Profile Name'
    }
  end

  before do
    allow(ENV).to receive(:fetch).with('GOOGLE_CLIENT_IDS').and_return(client_ids.join(','))
  end

  it 'verifies the token audience and returns identity claims' do
    allow(Google::Auth::IDTokens).to receive(:verify_oidc)
      .with(id_token, aud: client_ids)
      .and_return(payload)

    expect(verify).to eq(
      'sub' => 'google-subject-123',
      'email' => 'person@example.com'
    )
  end

  context 'when Google rejects the token' do
    before do
      allow(Google::Auth::IDTokens).to receive(:verify_oidc)
        .and_raise(Google::Auth::IDTokens::VerificationError)
    end

    it 'raises an application-level invalid token error' do
      expect { verify }.to raise_error(described_class::InvalidToken)
    end
  end

  context 'when the email is not verified' do
    before do
      allow(Google::Auth::IDTokens).to receive(:verify_oidc)
        .and_return(payload.merge('email_verified' => false))
    end

    it 'rejects the token' do
      expect { verify }.to raise_error(described_class::InvalidToken)
    end
  end
end
