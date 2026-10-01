require "rails_helper"

RSpec.describe "Locker Actions", type: :request do
  describe "POST /lockers/:locker_id/locker_actions" do
    let(:team) { create(:team) }
    let(:employee) { create(:user, team:) }
    let(:locker) { create(:locker_assignment, team:, locker: create(:locker, tenant: team.tenant, name: "BER-1")).locker }

    before { switch_to employee }

    it "opens a Closed Locker, records the Locker Action and redirects back with a notice" do
      locker.update!(state: :closed)

      expect {
        post locker_locker_actions_path(locker), params: { kind: "open" }, headers: { "HTTP_REFERER" => locker_url(locker) }
      }.to change(LockerAction, :count).by(1)

      expect(locker.reload).to be_open
      expect(LockerAction.last).to have_attributes(locker:, user: employee, kind: "open")
      expect(response).to redirect_to(locker_url(locker))
      follow_redirect!
      assert_select "[role=status]", text: "BER-1 is now open."
    end

    it "closes an Open Locker and redirects to the Locker page without a referrer" do
      locker.update!(state: :open)

      post locker_locker_actions_path(locker), params: { kind: "close" }

      expect(locker.reload).to be_closed
      expect(LockerAction.last).to have_attributes(locker:, user: employee, kind: "close")
      expect(response).to redirect_to(locker_path(locker))
      follow_redirect!
      assert_select "[role=status]", text: "BER-1 is now closed."
    end

    [ [ :open, "open", "BER-1 is already open." ], [ :closed, "close", "BER-1 is already closed." ] ].each do |state, kind, alert|
      it "rejects #{kind} on a Locker that is already #{state} with an alert and records nothing" do
        locker.update!(state:)

        expect {
          post locker_locker_actions_path(locker), params: { kind: }, headers: { "HTTP_REFERER" => root_url }
        }.not_to change(LockerAction, :count)

        expect(locker.reload.state).to eq state.to_s
        expect(response).to redirect_to(root_url)
        follow_redirect!
        assert_select "[role=alert]", text: alert
        assert_select "[role=status]", count: 0
      end
    end

    [ :open, :closed ].each do |state|
      it "rejects an unknown kind on a #{state} Locker and changes nothing" do
        locker.update!(state:)

        expect {
          post locker_locker_actions_path(locker), params: { kind: "unlock" }
        }.not_to change(LockerAction, :count)

        expect(locker.reload.state).to eq state.to_s
        follow_redirect!
        assert_select "[role=alert]", text: "This action is not included"
      end
    end

    it "answers 404 to an Employee for another Tenant's, another Team's and an unassigned Locker, and changes nothing" do
      other_tenants = create(:locker_assignment).locker
      other_teams = create(:locker_assignment, team: create(:team, tenant: team.tenant)).locker
      unassigned = create(:locker, tenant: team.tenant)

      [ other_tenants, other_teams, unassigned ].each do |other|
        expect {
          post locker_locker_actions_path(other), params: { kind: "open" }
        }.not_to change(LockerAction, :count)

        expect(response).to have_http_status(:not_found)
        expect(other.reload).to be_closed
      end
    end

    it "lets a Support Engineer open and close any Locker, assigned or not" do
      support_engineer = create(:user, :support_engineer)
      switch_to support_engineer

      [ locker, create(:locker_assignment).locker, create(:locker) ].each do |any|
        post locker_locker_actions_path(any), params: { kind: "open" }
        expect(any.reload).to be_open
        post locker_locker_actions_path(any), params: { kind: "close" }
        expect(any.reload).to be_closed
        expect(any.locker_actions.order(:id).pluck(:kind, :user_id)).to eq [ [ "open", support_engineer.id ], [ "close", support_engineer.id ] ]
      end
    end
  end
end
