FactoryBot.define do
  factory :locker_action do
    locker
    user { association :user, team: association(:team, tenant: locker.tenant) }
    kind { :open }
  end
end
