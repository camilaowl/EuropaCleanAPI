# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject(:user) do
      build(
        :user,
        email: email,
        password: password,
        password_confirmation: password_confirmation
      )
    end

    let(:email) { 'person@example.com' }
    let(:password) { 'password123' }
    let(:password_confirmation) { password }

    context 'when all attributes are valid' do
      it { is_expected.to be_valid }
    end

    context 'when email is missing' do
      let(:email) { nil }

      it 'adds a blank error to email' do
        expect(user).not_to be_valid
        expect(user.errors.of_kind?(:email, :blank)).to be(true)
      end
    end

    context 'when email has an invalid format' do
      let(:email) { 'not-an-email' }

      it 'adds an invalid error to email' do
        expect(user).not_to be_valid
        expect(user.errors.of_kind?(:email, :invalid)).to be(true)
      end
    end

    context 'when email is already registered with different casing' do
      let(:email) { 'PERSON@example.com' }

      before { create(:user, email: 'person@example.com') }

      it 'adds a taken error to email' do
        expect(user).not_to be_valid
        expect(user.errors.of_kind?(:email, :taken)).to be(true)
      end
    end

    context 'when password is too short' do
      let(:password) { 'short' }

      it 'adds a too-short error to password' do
        expect(user).not_to be_valid
        expect(user.errors.of_kind?(:password, :too_short)).to be(true)
      end
    end

    context 'when password confirmation does not match' do
      let(:password_confirmation) { 'different-password' }

      it 'adds a confirmation error' do
        expect(user).not_to be_valid
        expect(user.errors.of_kind?(:password_confirmation, :confirmation)).to be(true)
      end
    end
  end

  describe '#valid_password?' do
    let(:password) { 'password123' }
    let(:user) { create(:user, password: password, password_confirmation: password) }

    context 'when the password is correct' do
      it 'returns true' do
        expect(user.valid_password?(password)).to be(true)
      end
    end

    context 'when the password is incorrect' do
      it 'returns false' do
        expect(user.valid_password?('wrong-password')).to be(false)
      end
    end
  end

  describe 'JWT revocation' do
    let(:user) { create(:user) }
    let(:payload) { user.jwt_payload }

    it 'assigns a JTI and includes it in the JWT payload' do
      expect(user.jti).to be_present
      expect(payload).to eq('jti' => user.jti)
    end

    it 'accepts a token whose JTI matches the user' do
      expect(described_class.jwt_revoked?(payload, user)).to be(false)
    end

    it 'rotates the JTI and rejects the previous token when revoked' do
      previous_jti = user.jti

      described_class.revoke_jwt(payload, user)

      expect(user.reload.jti).not_to eq(previous_jti)
      expect(described_class.jwt_revoked?(payload, user)).to be(true)
    end
  end
end
