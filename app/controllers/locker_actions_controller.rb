class LockerActionsController < ApplicationController
  def create
    locker = accessible_lockers.find(params[:locker_id])
    locker_action = locker.operate(params[:kind], Current.user)

    if locker_action.persisted?
      redirect_back_or_to locker, status: :see_other, notice: "#{locker.name} is now #{locker.state}."
    else
      redirect_back_or_to locker, status: :see_other, alert: locker_action.errors.map(&:message).to_sentence
    end
  end
end
