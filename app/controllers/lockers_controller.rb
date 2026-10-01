class LockersController < ApplicationController
  def index
    @lockers = Locker.accessible_by(Current.user).includes(:tenant).order(:name)
  end

  def show
    @locker = Locker.accessible_by(Current.user).find(params[:id])
    @team_names = @locker.teams.order(:name).pluck(:name)
  end
end
