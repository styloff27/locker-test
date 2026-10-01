class AddStateAndRoleCheckConstraints < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :lockers, "state IN ('open', 'closed')", name: "lockers_state_check"
    add_check_constraint :users, "role IN ('employee', 'support_engineer')", name: "users_role_check"
  end
end
