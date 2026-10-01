class Locker < ApplicationRecord
  belongs_to :tenant

  enum :state, { open: "open", closed: "closed" }, validate: true

  # Accessible Lockers. ponytail: Employees get none until Teams and Locker Assignments exist (#4).
  scope :accessible_by, ->(user) { user&.support_engineer? ? all : none }
end
