# frozen_string_literal: true

class UserSerializer < Panko::Serializer
  attributes :id, :email, :created_at, :updated_at

  def created_at
    object.created_at.iso8601
  end
end
