FactoryBot.define do
  factory :room_item do
    name { 'Bed' }
    item_type { :furniture }
    room { association :room }
  end
end
