class CreateLockerAssignments < ActiveRecord::Migration[8.1]
  def change
    # Target of the composite foreign key from locker_assignments (ADR 0001).
    add_index :lockers, [ :id, :tenant_id ], unique: true

    create_table :locker_assignments do |t|
      t.references :team, null: false, index: false
      t.references :locker, null: false
      t.references :tenant, null: false, index: false

      t.timestamps

      t.index [ :team_id, :locker_id ], unique: true
      t.foreign_key :teams, column: [ :team_id, :tenant_id ], primary_key: [ :id, :tenant_id ]
      t.foreign_key :lockers, column: [ :locker_id, :tenant_id ], primary_key: [ :id, :tenant_id ]
    end
  end
end
