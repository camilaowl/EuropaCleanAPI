# frozen_string_literal: true

class RoomPolicy < ApplicationPolicy
  def index? = user.present?
  def create? = user.present?
  def show? = owner?
  def update? = owner?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      @scope.joins(:space).where(spaces: { user_id: user.id })
    end
  end

  private

  def owner?
    user.present? && record.space.user_id == user.id
  end
end
