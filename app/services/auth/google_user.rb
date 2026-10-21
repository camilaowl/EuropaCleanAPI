module Auth
  class GoogleUser
    PROVIDER = 'google'.freeze

    class IdentityConflict < StandardError; end

    class << self
      def call(claims)
        uid = claims.fetch('sub')
        email = claims.fetch('email').downcase

        User.transaction do
          user = User.find_by(provider: PROVIDER, uid: uid)
          return user if user

          user = User.find_by(email: email)
          return link_identity(user, uid) if user

          password = Devise.friendly_token(32)
          User.create!(
            email: email,
            provider: PROVIDER,
            uid: uid,
            password: password,
            password_confirmation: password
          )
        end
      end

      private

      def link_identity(user, uid)
        if user.provider.present? && (user.provider != PROVIDER || user.uid != uid)
          raise IdentityConflict
        end

        user.update!(provider: PROVIDER, uid: uid)
        user
      end
    end
  end
end
