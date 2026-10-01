FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    role { :employee }

    trait :support_engineer do
      role { :support_engineer }
    end
  end
end
