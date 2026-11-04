# frozen_string_literal: true

FactoryBot.define do
  factory :item_type do
    sequence(:item_type_key) { |number| "item_type_#{number}" }
    sequence(:default_display_name) { |number| "Item Type #{number}" }
    sequence(:icon_asset_key) { |number| "item_type_#{number}" }
  end
end
