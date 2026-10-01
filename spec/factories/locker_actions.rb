FactoryBot.define do
  factory :locker_action do
    locker
    user
    kind { :open }
  end
end
