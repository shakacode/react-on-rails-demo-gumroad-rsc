# frozen_string_literal: true

def ensure_seed_user_external_id!(user)
  return if user.external_id.present?

  user.save_external_id
  user.save!(validate: false)
end

def ensure_seed_user_password_login!(user)
  return unless user.two_factor_authentication_enabled?

  user.two_factor_authentication_enabled = false
  user.save!(validate: false)
end

seller = User.find_by(email: "seller@gumroad.com")
if seller.blank?
  seller = User.new
  seller.email = "seller@gumroad.com"
  seller.name = "Seller"
  seller.username = "seller"
  seller.confirmed_at = Time.current
  seller.is_team_member = true
  seller.user_risk_state = "compliant"
  seller.skip_enabling_two_factor_authentication = true
  seller.password = SecureRandom.hex(24)

  # Make seller eligible for service products
  seller.created_at = 2.months.ago
  seller.payments.build(
    state: "completed",
    amount_cents: 1000,
    processor: "paypal",
    processor_fee_cents: 100,
    payout_period_end_date: 1.day.ago
  )

  seller.save!

  # Skip validations to set a pwned but easy password
  seller.password = "password"
  seller.save!(validate: false)
end
ensure_seed_user_external_id!(seller)
ensure_seed_user_password_login!(seller)

TeamMembership::ROLES.excluding(TeamMembership::ROLE_OWNER).each do |role|
  email = "seller+#{role}@gumroad.com"
  user = User.find_by(email:)
  if user.present?
    ensure_seed_user_external_id!(user)
    ensure_seed_user_password_login!(user)
    next
  end

  user = User.new
  user.email = email
  user.name = "#{role.humanize}ForSeller"
  user.username = "#{role}forseller"
  user.confirmed_at = Time.current
  user.user_risk_state = "compliant"
  user.skip_enabling_two_factor_authentication = true
  user.password = SecureRandom.hex(24)
  user.save!

  # Skip validations to set a pwned but easy password
  user.password = "password"
  user.save!(validate: false)
  ensure_seed_user_external_id!(user)

  user.create_owner_membership_if_needed!
  user.user_memberships.create!(user:, seller:, role:)
end
