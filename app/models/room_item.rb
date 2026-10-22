class RoomItem < ApplicationRecord
  belongs_to :room

  enum :item_type,
    {
        furniture: 'furniture',
        other: 'other'
    }
end
