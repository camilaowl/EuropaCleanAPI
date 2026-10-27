class Room < ApplicationRecord
  belongs_to :space
  belongs_to :room_type, optional: true
  has_many :room_items, dependent: :destroy
end
