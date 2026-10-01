require "rails_helper"

RSpec.describe Locker do
  it "rejects a Locker State other than Open or Closed" do
    locker = build(:locker, state: "maintenance")

    expect(locker).not_to be_valid
    expect(locker.errors[:state]).to be_present
  end

  it "rejects a Locker State other than Open or Closed written past the model" do
    locker = create(:locker)

    expect { locker.update_column(:state, "maintenance") }.to raise_error(ActiveRecord::StatementInvalid, /CHECK/)
  end

  it "rejects an open through a stale Locker, because the lock re-reads the Locker State" do
    locker = create(:locker, state: :closed)
    user = create(:user, :support_engineer)
    first, second = Locker.find(locker.id), Locker.find(locker.id)

    expect(first.operate("open", user)).to be_persisted
    expect(second.operate("open", user).errors[:base]).to eq [ "#{locker.name} is already open." ]
    expect(locker.locker_actions.count).to eq 1
  end
end
