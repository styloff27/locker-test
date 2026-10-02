require "rails_helper"

RSpec.describe "Navigation", type: :request do
  before { switch_to create(:user, :support_engineer) }

  it "links to the Lockers list and the Action Log, marking the current page" do
    { root_path => "Lockers", lockers_path => "Lockers", locker_actions_path(page: 2) => "Action Log" }.each do |path, current|
      get path

      assert_select "header nav a[href=?]", root_path, text: "Lockers"
      assert_select "header nav a[href=?]", locker_actions_path, text: "Action Log"
      assert_select "header nav a[aria-current=page]", count: 1, text: current
    end
  end

  it "names the app eLocker in English" do
    get root_path

    assert_select "html[lang=en]"
    assert_select "title", text: "eLocker"
    assert_select "meta[name=application-name][content=eLocker]"
  end

  it "ends each page title with the app name" do
    get locker_actions_path

    assert_select "title", text: "Action Log · eLocker"
  end
end
