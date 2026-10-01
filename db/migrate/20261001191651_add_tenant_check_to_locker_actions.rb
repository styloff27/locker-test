class AddTenantCheckToLockerActions < ActiveRecord::Migration[8.1]
  # An Employee may only act on a Locker of their Team's Tenant (ADR 0002). A Support Engineer has no Team,
  # so the join finds no row and the insert goes through.
  def up
    execute <<~SQL
      CREATE TRIGGER locker_actions_tenant_check
      BEFORE INSERT ON locker_actions
      WHEN EXISTS (
        SELECT 1 FROM users
        JOIN teams ON teams.id = users.team_id
        JOIN lockers ON lockers.id = NEW.locker_id
        WHERE users.id = NEW.user_id
          AND teams.tenant_id != lockers.tenant_id
      )
      BEGIN
        SELECT RAISE(ABORT, 'Locker Action: the Locker and the Employee belong to different tenants');
      END
    SQL
  end

  def down
    execute "DROP TRIGGER locker_actions_tenant_check"
  end
end
