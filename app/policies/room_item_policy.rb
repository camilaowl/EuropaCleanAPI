# frozen_string_literal: true

class RoomItemPolicy < ApplicationPolicy
  def index? = user.present?
  def create? = user.present?
  def show? = owner?
  def update? = owner?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(room: :space).where(spaces: { user_id: user.id })
    end
  end

  private

  def owner?
    user.present? && record.room.space.user_id == user.id
  end
end
