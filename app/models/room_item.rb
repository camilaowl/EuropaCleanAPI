class RoomItem < ApplicationRecord
  belongs_to :room
  belongs_to :item_type, optional: true
end
