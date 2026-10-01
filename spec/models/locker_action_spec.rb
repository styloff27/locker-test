require "rails_helper"

RSpec.describe LockerAction do
  it "rejects a kind other than open or close written past the model" do
    action = create(:locker_action)

    expect { action.update_column(:kind, "unlock") }.to raise_error(ActiveRecord::StatementInvalid, /CHECK/)
  end
end
