class LockerAssignment < ApplicationRecord
  belongs_to :team
  belongs_to :locker
  belongs_to :tenant

  # tenant_id only exists for the composite foreign keys (ADR 0001), so it always follows the Locker.
  before_validation { self.tenant = locker&.tenant }

  validate :locker_belongs_to_teams_tenant

  private

  def locker_belongs_to_teams_tenant
    return if team.nil? || locker.nil? || team.tenant_id == locker.tenant_id

    errors.add(:locker, "must belong to the Team's Tenant")
  end
end
