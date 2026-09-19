# frozen_string_literal: true

class Auth::RegistrationCreateContract < ApplicationContract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
    required(:password).filled(:string)
    required(:password_confirmation).filled(:string)
  end

  rule(:email) do
    key.failure('must be a valid email address') unless /\A[^@\s]+@[^@\s]+\z/.match?(value)
  end

  rule(:password_confirmation, :password) do
    key.failure('must match password') unless values[:password_confirmation] == values[:password]
  end
end