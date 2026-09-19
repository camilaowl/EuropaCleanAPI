module Api
  module Auth
    class SessionController < Api::BaseController
      skip_before_action :authenticate_user!, only: :create

      def create
        user = User.find_by(email: sign_in_params[:email])

        unless user&.valid_password?(sign_in_params[:password])
          render json: { error: "Invalid email or password" }, status: :unauthorized
          return
        end

        token, = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
        render json: { user: user_payload(user), token: token }, status: :ok
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
