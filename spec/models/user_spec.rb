require "rails_helper"

RSpec.describe User do
  it "rejects a role other than employee or support_engineer" do
    user = build(:user, role: "admin")

    expect(user).not_to be_valid
    expect(user.errors[:role]).to be_present
  end

  it "rejects a role other than employee or support_engineer written past the model" do
    user = create(:user)

    expect { user.update_column(:role, "admin") }.to raise_error(ActiveRecord::StatementInvalid, /CHECK/)
  end
end
