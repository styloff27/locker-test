require "rails_helper"

RSpec.describe LockerAssignment do
  let(:team) { create(:team) }
  let(:other_tenants_locker) { create(:locker) }

  it "assigns a Team a Locker of its own Tenant" do
    assignment = create(:locker_assignment, team:)

    expect(assignment.tenant).to eq team.tenant
  end

  it "rejects a Team and a Locker of different Tenants" do
    assignment = build(:locker_assignment, team:, locker: other_tenants_locker)

    expect(assignment).not_to be_valid
    expect(assignment.errors[:locker]).to be_present
  end

  it "rejects a Team and a Locker of different Tenants written past the model" do
    [ team.tenant_id, other_tenants_locker.tenant_id ].each do |tenant_id|
      expect {
        LockerAssignment.insert_all!([ { team_id: team.id, locker_id: other_tenants_locker.id, tenant_id: } ])
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end
end
