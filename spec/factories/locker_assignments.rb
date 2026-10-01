FactoryBot.define do
  factory :locker_assignment do
    team
    locker { association :locker, tenant: team.tenant }
  end
end
