require "rails_helper"

RSpec.describe "Lockers", type: :request do
  describe "GET /" do
    it "shows a Support Engineer every Locker, assigned or not, by name with its location, state and Tenant" do
      amazon = create(:tenant, name: "Amazon")
      dpd = create(:tenant, name: "DPD")
      create(:locker, tenant: dpd, name: "HAM-1", location: "Hamburg Hbf", state: :open)
      create(:locker, tenant: amazon, name: "BER-1", location: "Berlin Ostbahnhof", state: :closed)
      switch_to create(:user, :support_engineer)

      get root_path

      expect(response).to have_http_status(:ok)
      rows = css_select("tbody tr").map { |row| row.css("td").map(&:text) }
      expect(rows).to eq [
        [ "BER-1", "Berlin Ostbahnhof", "Closed", "Amazon" ],
        [ "HAM-1", "Hamburg Hbf", "Open", "DPD" ]
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
        assert_select "tbody tr:first-child td", count: 3
      end
    end

    it "shows an empty-state message when there are no Lockers" do
      switch_to create(:user, :support_engineer)

      get root_path

      assert_select "p", text: "No lockers to show."
    end
  end
end
