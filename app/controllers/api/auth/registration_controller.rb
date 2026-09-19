module Api
  module Auth
    class RegistrationController < Api::BaseController
      skip_before_action :authenticate_user!

      def create
        user = User.new(sign_up_params)

        if user.save
          render json: { user: user_payload(user) }, status: :created
        else
          render_errors(user)
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
