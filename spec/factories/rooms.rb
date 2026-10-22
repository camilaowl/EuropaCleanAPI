FactoryBot.define do
  factory :room do
    name { 'Bedroom' }
    room_type { :bedroom }
    association :space
  end
end
