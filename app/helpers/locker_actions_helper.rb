module LockerActionsHelper
  # Employees never learn which Support Engineer acted.
  def actor_name(locker_action)
    if Current.user.employee? && locker_action.user.support_engineer?
      "eLocker Support"
    else
      locker_action.user.name
    end
  end
end
