# frozen_string_literal: true

require "spec_helper"

RSpec.describe "development/staging user seeds" do
  let(:seed_file) { Rails.root.join("db/seeds/020_development_staging/01_users.rb") }

  it "repairs the demo seller external ID when rerun over an existing partial seed" do
    seller = create(:user, email: "seller@gumroad.com", username: "seller", user_risk_state: "compliant")
    seller.update_column(:external_id, nil)

    load(seed_file, true)

    seller.reload
    expect(seller.external_id).to be_present
    expect { seller.two_factor_authentication_cookie_key }.not_to raise_error
  end
end
