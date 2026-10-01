class CreateLockers < ActiveRecord::Migration[8.1]
  def change
    create_table :lockers do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :location, null: false
      t.string :state, null: false

      t.timestamps
    end
  end
end
