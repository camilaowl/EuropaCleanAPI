# frozen_string_literal: true

FactoryBot.define do
  factory :room_item do
    name { 'Bed' }
    association :item_type
    association :room
  end
end
