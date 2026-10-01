require "rails_helper"

RSpec.describe "Lockers", type: :request do
  describe "GET /" do
    it "shows a Support Engineer every Locker, assigned or not, by name with its location, state, Tenant and action" do
      amazon = create(:tenant, name: "Amazon")
      dpd = create(:tenant, name: "DPD")
      create(:locker, tenant: dpd, name: "HAM-1", location: "Hamburg Hbf", state: :open)
      create(:locker, tenant: amazon, name: "BER-1", location: "Berlin Ostbahnhof", state: :closed)
      switch_to create(:user, :support_engineer)

      get root_path

      expect(response).to have_http_status(:ok)
      rows = css_select("tbody tr").map { |row| row.css("td").map { |cell| cell.text.strip } }
      expect(rows).to eq [
        [ "BER-1", "Berlin Ostbahnhof", "Closed", "Amazon", "Open" ],
        [ "HAM-1", "Hamburg Hbf", "Open", "DPD", "Close" ]
      ]
    end

    it "shows a Support Engineer the Tenant column" do
      create(:locker)
      switch_to create(:user, :support_engineer)

      get root_path

      assert_select "th", text: "Tenant"
    end

    context "as an Employee" do
      let(:amazon) { create(:tenant) }
      let(:morning) { create(:team, tenant: amazon) }
      let(:night) { create(:team, tenant: amazon) }

      before do
        shared = create(:locker, tenant: amazon, name: "BER-1")
        create(:locker_assignment, team: morning, locker: shared)
        create(:locker_assignment, team: night, locker: shared)
        create(:locker_assignment, team: morning, locker: create(:locker, tenant: amazon, name: "BER-2"))
        create(:locker_assignment, team: night, locker: create(:locker, tenant: amazon, name: "BER-3"))
        create(:locker, tenant: amazon, name: "BER-4")
        hamburg = create(:team)
        create(:locker_assignment, team: hamburg, locker: create(:locker, tenant: hamburg.tenant, name: "HAM-1"))
        switch_to create(:user, team: morning)

        get root_path
      end

      it "shows exactly their Team's Lockers, including one shared with another Team" do
        expect(css_select("tbody tr td:first-child").map(&:text)).to eq [ "BER-1", "BER-2" ]
      end

      it "hides the Tenant column" do
        assert_select "th", text: "Tenant", count: 0
        assert_select "td", text: amazon.name, count: 0
      end
    end

    it "links each Locker to its Locker page" do
      locker = create(:locker, name: "BER-1")
      switch_to create(:user, :support_engineer)

      get root_path

      assert_select "tbody a[href=?]", locker_path(locker), text: "BER-1"
    end

    it "offers only Open for a Closed Locker and only Close for an Open one" do
      closed = create(:locker, state: :closed)
      opened = create(:locker, state: :open)
      switch_to create(:user, :support_engineer)

      get root_path

      assert_only_action closed, "open", "Open"
      assert_only_action opened, "close", "Close"
    end

    it "shows an empty-state message when there are no Lockers" do
      switch_to create(:user, :support_engineer)

      get root_path

      assert_select "p", text: "No lockers to show."
    end
  end

  describe "GET /lockers/:id" do
    let(:amazon) { create(:tenant, name: "Amazon") }
    let(:morning) { create(:team, tenant: amazon, name: "Morning Shift") }
    let(:night) { create(:team, tenant: amazon, name: "Night Shift") }
    let(:shared) { create(:locker, tenant: amazon, name: "BER-1", location: "Berlin Ostbahnhof", state: :open) }

    before do
      create(:locker_assignment, team: morning, locker: shared)
      create(:locker_assignment, team: night, locker: shared)
    end

    it "shows the Locker's name, location, state, Tenant and assigned Teams" do
      switch_to create(:user, :support_engineer)

      get locker_path(shared)

      expect(response).to have_http_status(:ok)
      assert_select "h1", text: "BER-1"
      details = css_select("dl dt").map(&:text).zip(css_select("dl dd").map(&:text)).to_h
      expect(details).to eq(
        "Location" => "Berlin Ostbahnhof",
        "State" => "Open",
        "Tenant" => "Amazon",
        "Teams" => "Morning Shift, Night Shift"
      )
    end

    context "as an Employee" do
      before { switch_to create(:user, team: morning) }

      it "answers 200 for their Team's Lockers, including a shared one" do
        own = create(:locker_assignment, team: morning).locker

        [ shared, own ].each do |locker|
          get locker_path(locker)

          expect(response).to have_http_status(:ok)
        end
      end

      context "with the error pages a real user gets" do
        around do |example|
          env_config = Rails.application.env_config
          detailed = env_config["action_dispatch.show_detailed_exceptions"]
          env_config["action_dispatch.show_detailed_exceptions"] = false
          example.run
        ensure
          env_config["action_dispatch.show_detailed_exceptions"] = detailed
        end

        it "answers the same 404 for another Tenant's, another Team's, an unassigned and a missing Locker" do
          other_tenants = create(:locker_assignment).locker
          other_teams = create(:locker_assignment, team: night).locker
          unassigned = create(:locker, tenant: amazon)
          get locker_path(0)
          expect(response).to have_http_status(:not_found)
          missing = response.body

          [ other_tenants, other_teams, unassigned ].each do |locker|
            get locker_path(locker)

            expect(response).to have_http_status(:not_found)
            expect(response.body).to eq missing
          end
        end
      end
    end

    it "offers only the action that fits the Locker State" do
      switch_to create(:user, :support_engineer)

      get locker_path(shared)
      assert_only_action shared, "close", "Close"

      shared.update!(state: :closed)
      get locker_path(shared)
      assert_only_action shared, "open", "Open"
    end

    context "with history" do
      let(:alice) { create(:user, name: "Alice", team: morning) }
      let(:bob) { create(:user, name: "Bob", team: night) }
      let(:sam) { create(:user, :support_engineer, name: "Sam") }

      before do
        act(shared, bob, "close", 11)
        act(shared, sam, "close", 12)
        act(create(:locker_assignment, team: morning).locker, alice, "open", 13)
        act(shared, alice, "close", 10)
      end

      it "shows an Employee only this Locker's Locker Actions, newest first, with Support Engineers as eLocker Support" do
        switch_to alice

        get locker_path(shared)

        expect(log_rows).to eq [
          [ "October 01, 2026 12:00", "BER-1", "Close", "eLocker Support" ],
          [ "October 01, 2026 11:00", "BER-1", "Close", "Bob" ],
          [ "October 01, 2026 10:00", "BER-1", "Close", "Alice" ]
        ]
      end

      it "shows a Support Engineer real names and the Tenant" do
        switch_to sam

        get locker_path(shared)

        expect(log_rows.map { |row| row.values_at(2, 4) }).to eq [ [ "Amazon", "Sam" ], [ "Amazon", "Bob" ], [ "Amazon", "Alice" ] ]
      end

      it "shows 25 per page" do
        23.times { |hour| act(shared, alice, "close", 14 + hour) }
        switch_to alice

        get locker_path(shared)
        expect(log_rows.size).to eq 25

        get locker_path(shared, page: 2)
        expect(log_rows).to eq [ [ "October 01, 2026 10:00", "BER-1", "Close", "Alice" ] ]

        get locker_path(shared, page: 0)
        expect(response).to redirect_to(locker_path(shared))
      end
    end

    it "shows an empty-state message when the Locker has no history" do
      switch_to create(:user, :support_engineer)

      get locker_path(shared)

      assert_select "p", text: "No locker actions to show."
    end

    it "answers 200 to a Support Engineer for any Locker, assigned or not" do
      switch_to create(:user, :support_engineer)

      [ shared, create(:locker_assignment).locker, create(:locker) ].each do |locker|
        get locker_path(locker)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  def assert_only_action(locker, kind, label)
    assert_select "form[action=?]", locker_locker_actions_path(locker), count: 1 do
      assert_select "input[name=kind][value=?]", kind
      assert_select "button", text: label
    end
  end
end
