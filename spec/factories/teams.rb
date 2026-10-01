FactoryBot.define do
  factory :team do
    tenant
    name { "#{Faker::Address.city} Team" }
  end
end
