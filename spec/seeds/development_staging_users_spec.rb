# frozen_string_literal: true

require "spec_helper"

RSpec.describe "development/staging user seeds" do
  let(:seed_file) { Rails.root.join("db/seeds/020_development_staging/01_users.rb") }

  def with_env(name, value)
    original = ENV[name]
    value.nil? ? ENV.delete(name) : ENV[name] = value

    yield
  ensure
    original.nil? ? ENV.delete(name) : ENV[name] = original
  end

  it "repairs the demo seller external ID when rerun over an existing partial seed" do
    seller = create(:user, email: "seller@gumroad.com", username: "seller", user_risk_state: "compliant")
    seller.update_column(:external_id, nil)
    seller.two_factor_authentication_enabled = true
    seller.save!(validate: false)

    with_env("ALLOW_DEMO_SEED", nil) do
      load(seed_file, true)
    end

    seller.reload
    expect(seller.external_id).to be_present
    expect(seller.two_factor_authentication_enabled?).to eq(true)
    expect { seller.two_factor_authentication_cookie_key }.not_to raise_error
  end

  it "creates public demo accounts that can use password login without internal admin access" do
    expected_emails = [
      "seller@gumroad.com",
      *TeamMembership::ROLES.excluding(TeamMembership::ROLE_OWNER).map { "seller+#{_1}@gumroad.com" }
    ]

    with_env("ALLOW_DEMO_SEED", "true") do
      load(seed_file, true)
    end

    demo_users = User.where(email: expected_emails)
    seller = demo_users.find { _1.email == "seller@gumroad.com" }

    expect(demo_users.pluck(:email)).to match_array(expected_emails)
    expect(demo_users.select(&:two_factor_authentication_enabled?)).to be_empty
    expect(seller.is_team_member?).to eq(false)
  end

  it "reconciles public demo accounts back to local development defaults" do
    expected_emails = [
      "seller@gumroad.com",
      *TeamMembership::ROLES.excluding(TeamMembership::ROLE_OWNER).map { "seller+#{_1}@gumroad.com" }
    ]

    with_env("ALLOW_DEMO_SEED", "true") do
      load(seed_file, true)
    end

    with_env("ALLOW_DEMO_SEED", nil) do
      load(seed_file, true)
    end

    demo_users = User.where(email: expected_emails)
    seller = demo_users.find { _1.email == "seller@gumroad.com" }

    expect(demo_users.pluck(:email)).to match_array(expected_emails)
    expect(demo_users.all?(&:two_factor_authentication_enabled?)).to eq(true)
    expect(seller.is_team_member?).to eq(true)
  end
end
