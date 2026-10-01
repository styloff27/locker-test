class LockerAction < ApplicationRecord
  belongs_to :locker
  belongs_to :user

  enum :kind, { open: "open", close: "close" }, validate: { message: "This action is not included" }

  validate :changes_locker_state, on: :create

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  # The Locker State this Locker Action leaves its Locker in, nil for an unknown kind.
  def resulting_state
    { "open" => "open", "close" => "closed" }[kind]
  end

  private

  def changes_locker_state
    errors.add(:base, "#{locker.name} is already #{locker.state}.") if locker&.state == resulting_state
  end
end
