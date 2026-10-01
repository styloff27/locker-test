class LockerActionsController < ApplicationController
  def create
    locker = accessible_lockers.find(params[:locker_id])
    locker_action = locker.operate(params[:kind], Current.user)

    if locker_action.persisted?
      redirect_back_or_to locker, status: :see_other, notice: "#{locker.name} #{locker_action.open? ? "opened" : "closed"}."
    else
      redirect_back_or_to locker, status: :see_other, alert: locker_action.errors.full_messages.to_sentence
    end
  end
end
