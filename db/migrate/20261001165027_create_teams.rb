class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
    # Target of the composite foreign key from locker_assignments (ADR 0001).
    add_index :teams, [ :id, :tenant_id ], unique: true
  end
end
