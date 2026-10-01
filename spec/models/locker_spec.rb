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
end
