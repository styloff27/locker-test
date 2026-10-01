require "rails_helper"

RSpec.describe "Pages", type: :request do
  it "renders the root page inside the layout" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("@picocss/pico", "<header", "<main")
  end
end
