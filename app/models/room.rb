class Room < ApplicationRecord
  belongs_to :space
  has_many :room_items, dependent: :destroy

    enum :room_type,
    {
        bedroom: 'bedroom',
        bathroom: 'bathroom',
        kitchen: 'kitchen',
        living_room: 'living_room',
        dining_room: 'dining_room',
        office: 'office',
        garage: 'garage',
        basement: 'basement',
        attic: 'attic',
        other: 'other'
    }
end
