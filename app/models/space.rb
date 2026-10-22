class Space < ApplicationRecord
  belongs_to :user
  has_many :rooms, dependent: :destroy

  enum :space_type,
    {
        home: 'home',
        office: 'office',
        warehouse: 'warehouse',
        car: 'car',
        other: 'other'
    },
    default: :home
end
