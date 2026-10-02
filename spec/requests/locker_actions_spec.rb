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
        assert_select "[role=alert]", text: "Unknown action. Choose Open or Close."
      end
    end

    [ {}, { kind: [ "open" ] }, { kind: { open: "1" } } ].each do |params|
      it "answers 400 to a missing or malformed kind (#{params}) and changes nothing" do
        expect {
          post locker_locker_actions_path(locker), params:
        }.not_to change(LockerAction, :count)

        expect(response).to have_http_status(:bad_request)
        expect(locker.reload).to be_closed
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

  describe "GET /locker_actions" do
    let(:amazon) { create(:tenant, name: "Amazon") }
    let(:morning) { create(:team, tenant: amazon) }
    let(:night) { create(:team, tenant: amazon) }
    let(:alice) { create(:user, name: "Alice", team: morning) }
    let(:bob) { create(:user, name: "Bob", team: night) }
    let(:sam) { create(:user, :support_engineer, name: "Sam") }
    let(:shared) { create(:locker, tenant: amazon, name: "BER-1", state: :open) }
    let(:mornings) { create(:locker, tenant: amazon, name: "BER-2") }

    before do
      create(:locker_assignment, team: morning, locker: shared)
      create(:locker_assignment, team: night, locker: shared)
      create(:locker_assignment, team: morning, locker: mornings)
    end

    context "with Locker Actions across Teams and Tenants" do
      before do
        nights = create(:locker_assignment, team: night, locker: create(:locker, tenant: amazon, name: "BER-3")).locker
        dpd = create(:tenant, name: "DPD")
        hamburg = create(:locker_assignment, team: create(:team, tenant: dpd), locker: create(:locker, tenant: dpd, name: "HAM-1")).locker

        act(shared, sam, "close", 12)
        act(mornings, alice, "open", 10)
        act(nights, bob, "open", 13)
        act(shared, bob, "close", 11)
        act(hamburg, create(:user, name: "Dave", team: hamburg.teams.first), "open", 14)
        act(create(:locker, tenant: amazon, name: "BER-4"), sam, "open", 9)
      end

      it "shows an Employee only their Accessible Lockers' Locker Actions, newest first, with Support Engineers as eLocker Support" do
        switch_to alice

        get locker_actions_path

        expect(response).to have_http_status(:ok)
        expect(log_rows).to eq [
          [ "October 01, 2026 12:00", "BER-1", "Close", "eLocker Support" ],
          [ "October 01, 2026 11:00", "BER-1", "Close", "Bob" ],
          [ "October 01, 2026 10:00", "BER-2", "Open", "Alice" ]
        ]
        assert_select "th", text: "Tenant", count: 0
      end

      it "shows a Support Engineer every Locker Action with real names and the Tenant" do
        switch_to sam

        get locker_actions_path

        assert_select "th", text: "Tenant"
        expect(log_rows).to eq [
          [ "October 01, 2026 14:00", "HAM-1", "DPD", "Open", "Dave" ],
          [ "October 01, 2026 13:00", "BER-3", "Amazon", "Open", "Bob" ],
          [ "October 01, 2026 12:00", "BER-1", "Amazon", "Close", "Sam" ],
          [ "October 01, 2026 11:00", "BER-1", "Amazon", "Close", "Bob" ],
          [ "October 01, 2026 10:00", "BER-2", "Amazon", "Open", "Alice" ],
          [ "October 01, 2026 09:00", "BER-4", "Amazon", "Open", "Sam" ]
        ]
      end

      it "links each entry to its Locker page" do
        switch_to alice

        get locker_actions_path

        assert_select "tbody a[href=?]", locker_path(shared), text: "BER-1", count: 2
        assert_select "tbody a[href=?]", locker_path(mornings), text: "BER-2"
      end
    end

    it "drops a Locker's history when the Employee loses access to it, even their own Locker Actions" do
      act(mornings, alice, "open", 10)
      LockerAssignment.find_by!(team: morning, locker: mornings).destroy!
      switch_to alice

      get locker_actions_path

      expect(log_rows).to be_empty
      assert_select "p", text: "No locker actions to show."
    end

    it "is linked from the header" do
      switch_to alice

      get root_path

      assert_select "header a[href=?]", locker_actions_path, text: "Action Log"
    end

    context "with more than a page of Locker Actions" do
      before do
        26.times { |hour| act(mornings, alice, "open", hour) }
        switch_to alice
      end

      it "shows 25 per page, newest first, with a link to the next page" do
        get locker_actions_path

        expect(log_rows.size).to eq 25
        expect(log_rows.first.first).to eq "October 02, 2026 01:00"
        assert_select "nav a[href=?]", locker_actions_path(page: 2)
      end

      it "shows the rest on the next page" do
        get locker_actions_path(page: 2)

        expect(log_rows.map(&:first)).to eq [ "October 01, 2026 00:00" ]
      end

      it "shows the empty state past the last page" do
        get locker_actions_path(page: 3)

        expect(response).to have_http_status(:ok)
        assert_select "p", text: "No locker actions to show."
      end

      it "shows the empty state for a page too large for the database" do
        get locker_actions_path(page: "99999999999999999999")

        expect(response).to have_http_status(:ok)
        assert_select "p", text: "No locker actions to show."
      end

      it "redirects a page below 1 or not a number to page 1" do
        [ "0", "-1", "abc", [ "2" ], { "a" => "2" } ].each do |page|
          get locker_actions_path(page:)

          expect(response).to redirect_to(locker_actions_path)
        end
      end
    end
  end
end
