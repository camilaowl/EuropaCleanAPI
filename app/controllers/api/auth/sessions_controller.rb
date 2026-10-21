module Api
  module Auth
    class SessionsController < Api::BaseController
      skip_before_action :authenticate_user!, only: :create

      def create
        user = User.find_for_database_authentication(email: sign_in_params[:email])

        unless user&.valid_password?(sign_in_params[:password])
          render json: { error: 'Invalid email or password' }, status: :unauthorized
          return
        end

        render_authenticated_user(user)
      end

      def destroy
        current_user.update!(jti: SecureRandom.uuid)
        head :no_content
      end

      private

      def sign_in_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
