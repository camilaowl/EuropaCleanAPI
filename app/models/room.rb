class Room < ApplicationRecord
  belongs_to :space
  has_many :room_items, dependent: :destroy
end
