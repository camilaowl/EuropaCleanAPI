# frozen_string_literal: true

class SpacePolicy < ApplicationPolicy
    def index? = user.present?
    def create? = user.present?

    def show? = owner?
    def update? = owner?
    def destroy? = owner?

    class Scope < ApplicationPolicy::Scope
      def resolve
        @scope.where(user_id: user.id)
      end
    end

  private

  def owner?
    user.present? && record.user_id == user.id
  end
end
