require "rails_helper"

RSpec.describe Team do
  it "rejects a move to another Tenant" do
    team = create(:team)

    expect { team.tenant = create(:tenant) }.to raise_error(ActiveRecord::ReadonlyAttributeError)
  end

  it "rejects a move to another Tenant written past the model" do
    team = create(:team)

    expect { Team.where(id: team).update_all(tenant_id: create(:tenant).id) }.to raise_error(ActiveRecord::StatementInvalid, /Tenant/)
  end
end
