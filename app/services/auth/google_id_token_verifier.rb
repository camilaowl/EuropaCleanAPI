require 'googleauth/id_tokens'

module Auth
  class GoogleIdTokenVerifier
    class InvalidToken < StandardError; end

    class << self
      def call(id_token)
        payload = Google::Auth::IDTokens.verify_oidc(id_token, aud: client_ids)

        unless payload['sub'].present? && payload['email'].present? && payload['email_verified'] == true
          raise InvalidToken
        end

        payload.slice('sub', 'email')
      rescue Google::Auth::IDTokens::VerificationError
        raise InvalidToken
      end

      private

      def client_ids
        ids = ENV.fetch('GOOGLE_CLIENT_IDS').split(',').map(&:strip).compact_blank
        raise KeyError, 'GOOGLE_CLIENT_IDS must contain at least one client ID' if ids.empty?

        ids
      end
    end
  end
end
