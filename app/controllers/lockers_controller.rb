class LockersController < ApplicationController
  def index
    @lockers = accessible_lockers.includes(:tenant).order(:name)
  end

  def show
    @locker = accessible_lockers.find(params[:id])
    @team_names = @locker.teams.order(:name).pluck(:name)
  end

  private

  def accessible_lockers
    Locker.accessible_by(Current.user)
  end
end
