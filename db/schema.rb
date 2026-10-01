# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_01_185042) do
  create_table "locker_actions", force: :cascade do |t|
    t.integer "locker_id", null: false
    t.integer "user_id", null: false
    t.string "kind", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locker_id"], name: "index_locker_actions_on_locker_id"
    t.index ["user_id"], name: "index_locker_actions_on_user_id"
    t.check_constraint "kind IN ('open', 'close')", name: "locker_actions_kind_check"
  end

  create_table "locker_assignments", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "locker_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locker_id"], name: "index_locker_assignments_on_locker_id"
    t.index ["team_id", "locker_id"], name: "index_locker_assignments_on_team_id_and_locker_id", unique: true
  end

  create_table "lockers", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "name", null: false
    t.string "location", null: false
    t.string "state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "tenant_id"], name: "index_lockers_on_id_and_tenant_id", unique: true
    t.index ["tenant_id"], name: "index_lockers_on_tenant_id"
    t.check_constraint "state IN ('open', 'closed')", name: "lockers_state_check"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "tenant_id"], name: "index_teams_on_id_and_tenant_id", unique: true
    t.index ["tenant_id"], name: "index_teams_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.index ["team_id"], name: "index_users_on_team_id"
    t.check_constraint "(role = 'employee' AND team_id IS NOT NULL) OR (role = 'support_engineer' AND team_id IS NULL)", name: "users_team_check"
    t.check_constraint "role IN ('employee', 'support_engineer')", name: "users_role_check"
  end

  add_foreign_key "locker_actions", "lockers"
  add_foreign_key "locker_actions", "users"
  add_foreign_key "locker_assignments", "lockers", column: ["locker_id", "tenant_id"], primary_key: ["id", "tenant_id"]
  add_foreign_key "locker_assignments", "teams", column: ["team_id", "tenant_id"], primary_key: ["id", "tenant_id"]
  add_foreign_key "lockers", "tenants"
  add_foreign_key "teams", "tenants"
  add_foreign_key "users", "teams"
end
