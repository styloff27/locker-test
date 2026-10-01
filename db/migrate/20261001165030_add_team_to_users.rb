class AddTeamToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :team, foreign_key: true
    add_check_constraint :users,
      "(role = 'employee' AND team_id IS NOT NULL) OR (role = 'support_engineer' AND team_id IS NULL)",
      name: "users_team_check"
  end
end
