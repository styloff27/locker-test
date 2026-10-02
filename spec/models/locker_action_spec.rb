require "rails_helper"

RSpec.describe LockerAction do
  it "can't be changed or destroyed once recorded" do
    action = create(:locker_action)

    expect { action.update(kind: :close) }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { action.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it "rejects a kind other than open or close written past the model" do
    action = create(:locker_action)

    expect { LockerAction.where(id: action).update_all(kind: "unlock") }.to raise_error(ActiveRecord::StatementInvalid, /CHECK/)
  end

  describe "Tenant consistency written past the model" do
    let(:locker) { create(:locker) }

    def insert_action(user)
      LockerAction.insert_all([ { locker_id: locker.id, user_id: user.id, kind: "open" } ])
    end

    it "rejects an Employee acting on another Tenant's Locker" do
      expect { insert_action(create(:user)) }.to raise_error(ActiveRecord::StatementInvalid, /tenant/)
    end

    it "accepts an Employee acting on their own Tenant's Locker" do
      expect { insert_action(create(:user, team: create(:team, tenant: locker.tenant))) }.to change(LockerAction, :count).by(1)
    end

    it "accepts a Support Engineer acting on any Locker" do
      expect { insert_action(create(:user, :support_engineer)) }.to change(LockerAction, :count).by(1)
    end
  end
end
