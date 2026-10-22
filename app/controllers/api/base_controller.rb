module Api
  class BaseController < ApplicationController
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

    before_action :authenticate_user!

    rescue_from ActionController::ParameterMissing do |exception|
      render json: { error: exception.message }, status: :bad_request
    end

    private

    def user_payload(user)
      {
        id: user.id,
        email: user.email
      }
    end

    def render_authenticated_user(user)
      token, = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      response.set_header('Authorization', "Bearer #{token}")
      render json: { user: user_payload(user) }, status: :ok
    end

    def render_forbidden
      render json: { error: 'forbidden' }, status: :forbidden
    end

    def render_errors(record)
      render json: { errors: record.errors.full_messages }, status: :unprocessable_content
    end
  end
end
