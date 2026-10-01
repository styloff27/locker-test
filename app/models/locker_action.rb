class LockerAction < ApplicationRecord
  belongs_to :locker
  belongs_to :user
end
