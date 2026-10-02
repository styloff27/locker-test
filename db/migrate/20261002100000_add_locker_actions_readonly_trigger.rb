class AddLockerActionsReadonlyTrigger < ActiveRecord::Migration[8.1]
  # A Locker Action never changes once recorded (ADR 0003). Moved to another Locker, it could reach another Tenant.
  def up
    execute <<~SQL
      CREATE TRIGGER locker_actions_readonly
      BEFORE UPDATE ON locker_actions
      BEGIN
        SELECT RAISE(ABORT, 'Locker Action: a recorded Locker Action is read-only');
      END
    SQL
  end

  def down
    execute "DROP TRIGGER locker_actions_readonly"
  end
end
