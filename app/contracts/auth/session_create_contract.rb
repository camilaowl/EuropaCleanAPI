# frozen_string_literal: true

class Auth::SessionCreateContract < ApplicationContract
  params do
    required(:email).filled(:string)
    required(:password).filled(:string)
  end

  rule(:email, :password) do
    user = User.find_by(email: values[:email])

    unless user&.valid_password?(values[:password])
      key(:password).failure('wrong email or password')
    end
  end
end
