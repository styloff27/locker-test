require "rails_helper"

RSpec.describe "Lockers", type: :request do
  describe "GET /" do
    it "shows a Support Engineer every Locker by name with its location, state and Tenant" do
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

    it "shows an Employee no Lockers until Teams exist" do
      create(:locker)
      switch_to create(:user)

      get root_path

      assert_select "tbody tr", count: 0
    end

    it "shows an empty-state message when there are no Lockers" do
      switch_to create(:user, :support_engineer)

      get root_path

      assert_select "p", text: "No lockers to show."
    end
  end
end
