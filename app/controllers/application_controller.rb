class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_user

  # A page below 1 or not a number goes to page 1. A page past the last renders empty (pagy's overflow extra).
  rescue_from(Pagy::VariableError) { redirect_to request.path }

  private

  def accessible_lockers
    Locker.accessible_by(Current.user)
  end

  # Reads the page param with to_i like pagy does, 1 when missing. An array or hash becomes 0, which goes to page 1
  # above. A page past 1,000,000 reads as 1,000,000 so the offset fits SQLite's integer.
  # ponytail: a page past 1,000,000 (25M Locker Actions) shows page 1,000,000; raise the cap if a log ever grows that far.
  def pagy_get_page(*)
    [ (params[:page] || 1).to_s.to_i, 1_000_000 ].min
  end

  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) || User.first
  end
end
