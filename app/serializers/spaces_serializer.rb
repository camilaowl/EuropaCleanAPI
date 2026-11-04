# frozen_string_literal: true

class SpacesSerializer < Panko::Serializer
  attributes :id, :name, :space_type, :created_at, :updated_at
  has_one :user, serializer: UserSerializer
  has_many :rooms, serializer: RoomsSerializer

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end
end
