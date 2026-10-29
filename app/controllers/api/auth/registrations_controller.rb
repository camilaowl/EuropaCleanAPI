module Api
  module Auth
    class RegistrationsController < Api::BaseController
      skip_before_action :authenticate_user!

      def create
        user = User.new(sign_up_params)

        if register(user)
          render json: { user: user_payload(user) }, status: :created
        else
          render_errors(user)
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def register(user)
        User.transaction do
          next false unless user.save

          Spaces::DefaultSetupService.new(user).call
          true
        end
      end
    end
  end
end
