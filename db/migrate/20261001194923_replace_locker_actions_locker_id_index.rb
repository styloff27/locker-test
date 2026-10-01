class ReplaceLockerActionsLockerIdIndex < ActiveRecord::Migration[8.1]
  # Lets a Locker's history be read newest first straight from the index, without sorting.
  # The old locker_id index is a prefix of this one, so it goes.
  def change
    add_index :locker_actions, [ :locker_id, :created_at, :id ]
    remove_index :locker_actions, :locker_id
  end
end
