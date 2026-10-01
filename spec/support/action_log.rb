module ActionLog
  def act(locker, user, kind, hour)
    create(:locker_action, locker:, user:, kind:, created_at: Time.zone.local(2026, 10, 1) + hour.hours)
  end

  def log_rows
    css_select("tbody tr").map { |row| row.css("td").map { |cell| cell.text.strip } }
  end
end

RSpec.configure do |config|
  config.include ActionLog, type: :request
end
