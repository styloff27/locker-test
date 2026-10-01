FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    role { :employee }
    team

    trait :support_engineer do
      role { :support_engineer }
      team { nil }
    end
  end
end
