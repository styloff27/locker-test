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

  it "rejects an Employee without a Team" do
    user = build(:user, team: nil)

    expect(user).not_to be_valid
    expect(user.errors[:team]).to be_present
  end

  it "rejects an Employee without a Team written past the model" do
    user = create(:user)

    expect { user.update_column(:team_id, nil) }.to raise_error(ActiveRecord::StatementInvalid, /CHECK/)
  end

  it "rejects a Support Engineer with a Team" do
    user = build(:user, :support_engineer, team: build(:team))

    expect(user).not_to be_valid
    expect(user.errors[:team]).to be_present
  end

  it "rejects a Support Engineer with a Team written past the model" do
    user = create(:user, :support_engineer)

    expect { user.update_column(:team_id, create(:team).id) }.to raise_error(ActiveRecord::StatementInvalid, /CHECK/)
  end
end
