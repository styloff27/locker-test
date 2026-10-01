module UserSwitching
  def switch_to(user)
    patch session_path, params: { user_id: user.id }
  end
end

RSpec.configure do |config|
  config.include UserSwitching, type: :request
end
