class LockersController < ApplicationController
  def index
    @lockers = Locker.accessible_by(Current.user).includes(:tenant).order(:name)
  end
end
