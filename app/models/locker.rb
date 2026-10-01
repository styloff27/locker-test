class Locker < ApplicationRecord
  belongs_to :tenant
  has_many :locker_assignments

  enum :state, { open: "open", closed: "closed" }, validate: true

  # Accessible Lockers: every Locker for a Support Engineer, the Team's assigned Lockers for an Employee.
  scope :accessible_by, ->(user) {
    if user&.support_engineer?
      all
    else
      joins(:locker_assignments).where(locker_assignments: { team_id: user&.team_id })
    end
  }
end
