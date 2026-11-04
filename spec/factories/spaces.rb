FactoryBot.define do
  factory :space do
    name { 'My Space' }
    space_type { :home }
    association :user
  end
end
