class CreateLockerActions < ActiveRecord::Migration[8.1]
  def change
    create_table :locker_actions do |t|
      t.references :locker, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false

      t.timestamps

      t.check_constraint "kind IN ('open', 'close')", name: "locker_actions_kind_check"
    end
  end
end
