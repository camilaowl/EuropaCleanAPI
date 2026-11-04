# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    name { 'Bedroom' }
    association :room_type
    association :space
  end
end
