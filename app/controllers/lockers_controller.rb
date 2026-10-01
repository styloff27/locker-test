class LockersController < ApplicationController
  def index
    @lockers = accessible_lockers.includes(:tenant).order(:name)
  end

  def show
    @locker = accessible_lockers.find(params[:id])
    @team_names = @locker.teams.order(:name).pluck(:name)
    @pagy, @locker_actions = pagy(@locker.locker_actions.newest_first.includes(:user, locker: :tenant))
  end
end
