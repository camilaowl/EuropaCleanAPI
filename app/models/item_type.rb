class ItemType < ApplicationRecord
    has_many :room_items, dependent: :restrict_with_error
end
