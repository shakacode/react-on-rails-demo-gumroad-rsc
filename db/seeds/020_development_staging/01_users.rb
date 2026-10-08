# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_catalog")

demo_entry = DevelopmentStagingProductCatalog.fetch(category: "demo")
seller = DevelopmentStagingProductCatalog.reconcile_seller!(entry: demo_entry)

# Make seller eligible for service products while keeping the original payment stable.
unless seller.payments.exists?(
  state: "completed",
  amount_cents: 1000,
  processor: "paypal",
  processor_fee_cents: 100,
  payout_period_end_date: DevelopmentStagingProductCatalog::SEED_TIME.to_date - 1.day,
)
  seller.payments.create!(
    state: "completed",
    amount_cents: 1000,
    processor: "paypal",
    processor_fee_cents: 100,
    payout_period_end_date: DevelopmentStagingProductCatalog::SEED_TIME.to_date - 1.day
  )
end

TeamMembership::ROLES.excluding(TeamMembership::ROLE_OWNER).each do |role|
  email = "seller+#{role}@gumroad.com"
  user = User.find_by(email:)
  next if user.present?

  user = User.create!(
    email:,
    name: "#{role.humanize}ForSeller",
    username: "#{role}forseller",
    confirmed_at: DevelopmentStagingProductCatalog::SEED_TIME,
    user_risk_state: "compliant",
    password: DevelopmentStagingProductCatalog::BOOTSTRAP_PASSWORD
  )

  # Skip validations to set a pwned but easy password
  user.password = "password"
  user.save!(validate: false)

  user.create_owner_membership_if_needed!
  user.user_memberships.create!(user:, seller:, role:)
end
