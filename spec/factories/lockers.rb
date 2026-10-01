FactoryBot.define do
  factory :locker do
    tenant
    sequence(:name) { |n| "LCK-#{n}" }
    location { Faker::Address.street_address }
    state { :closed }
  end
end
