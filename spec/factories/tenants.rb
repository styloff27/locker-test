FactoryBot.define do
  factory :tenant do
    name { Faker::Company.unique.name }
  end
end
