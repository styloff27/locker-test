class LockerActionsController < ApplicationController
  def index
    @pagy, @locker_actions = pagy(LockerAction.where(locker: accessible_lockers).newest_first.includes(:user, locker: :tenant))
  end

  def create
    locker = accessible_lockers.find(params[:locker_id])
    locker_action = locker.operate(params.expect(:kind), Current.user)

    if locker_action.persisted?
      redirect_back_or_to locker, status: :see_other, notice: "#{locker.name} is now #{locker.state}."
    else
      redirect_back_or_to locker, status: :see_other, alert: locker_action.errors.map(&:message).to_sentence
    end
  end
end
