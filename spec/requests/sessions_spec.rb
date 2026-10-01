require "rails_helper"

RSpec.describe "User switching", type: :request do
  let!(:first_user) { create(:user, :support_engineer, name: "Sam Support") }
  let!(:other_user) { create(:user, :support_engineer, name: "Sue Support") }

  it "lists every User in a dropdown that submits itself on change" do
    get root_path

    assert_select "select[name=user_id][onchange]" do
      assert_select "option", text: "Sam Support"
      assert_select "option", text: "Sue Support"
    end
    assert_select "header form [type=submit]", count: 0
  end

  it "falls back to the first User when the session is empty" do
    get root_path

    assert_select "option[selected]", text: "Sam Support"
  end

  it "keeps the selected User across requests" do
    switch_to other_user
    expect(response).to redirect_to(root_path)

    get root_path
    get root_path

    assert_select "option[selected]", text: "Sue Support"
  end

  it "falls back to the first User when the selected User no longer exists" do
    switch_to other_user
    other_user.destroy!

    get root_path

    expect(response).to have_http_status(:ok)
    assert_select "option[selected]", text: "Sam Support"
  end

  it "answers not found for an unknown User" do
    patch session_path, params: { user_id: 0 }

    expect(response).to have_http_status(:not_found)
  end
end
