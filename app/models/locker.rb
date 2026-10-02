class Locker < ApplicationRecord
  belongs_to :tenant
  attr_readonly :tenant_id
  has_many :locker_assignments
  has_many :teams, through: :locker_assignments
  has_many :locker_actions

  enum :state, { open: "open", closed: "closed" }, validate: true

  # Accessible Lockers: every Locker for a Support Engineer, the Team's assigned Lockers for an Employee.
  scope :accessible_by, ->(user) {
    if user&.support_engineer?
      all
    else
      joins(:locker_assignments).where(locker_assignments: { team_id: user&.team_id })
    end
  }

  # Opens or closes the Locker. with_lock re-reads the Locker inside a write transaction (SQLite takes the
  # database write lock), so the State check, State change and Locker Action are atomic.
  def operate(kind, user)
    with_lock do
      locker_actions.create(kind:, user:).tap do |locker_action|
        update!(state: locker_action.resulting_state) if locker_action.persisted?
      end
    end
  end
end
