class AddTenantReadonlyTriggers < ActiveRecord::Migration[8.1]
  # A Locker or Team never moves to another Tenant (ADR 0003). A Locker's history would move with it.
  TABLES = %w[lockers teams]

  def up
    TABLES.each do |table|
      execute <<~SQL
        CREATE TRIGGER #{table}_tenant_readonly
        BEFORE UPDATE OF tenant_id ON #{table}
        WHEN NEW.tenant_id != OLD.tenant_id
        BEGIN
          SELECT RAISE(ABORT, '#{table.classify}: the Tenant cannot change');
        END
      SQL
    end
  end

  def down
    TABLES.each { |table| execute "DROP TRIGGER #{table}_tenant_readonly" }
  end
end
