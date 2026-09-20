module Api
  module Auth
    class GoogleSessionsController < Api::BaseController
      skip_before_action :authenticate_user!

      rescue_from ::Auth::GoogleIdTokenVerifier::InvalidToken, with: :invalid_google_token
      rescue_from ::Auth::GoogleUser::IdentityConflict, with: :google_identity_conflict

      def create
        claims = ::Auth::GoogleIdTokenVerifier.call(google_id_token)
        user = ::Auth::GoogleUser.call(claims)

        render_authenticated_user(user)
      end

      private

      def google_id_token
        params.require(:google).require(:id_token)
      end

      def invalid_google_token
        render json: { error: 'Invalid Google ID token' }, status: :unauthorized
      end

      def google_identity_conflict
        render json: { error: 'Google account is already linked to another user' }, status: :conflict
      end
    end
  end
end
