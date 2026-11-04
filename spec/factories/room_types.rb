# frozen_string_literal: true

FactoryBot.define do
  factory :room_type do
    sequence(:room_type_key) { |number| "room_type_#{number}" }
    sequence(:default_display_name) { |number| "Room Type #{number}" }
    sequence(:icon_asset_key) { |number| "room_type_#{number}" }
  end
end
