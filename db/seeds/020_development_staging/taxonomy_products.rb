# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_catalog")

def find_or_create_recommendable_user(entry)
  user = User.find_by(email: entry.seller_email)
  return user if user

  user = User.create!(
    name: "Gumbo #{entry.category}",
    username: entry.seller_username,
    email: entry.seller_email,
    external_id: DevelopmentStagingProductCatalog.seller_external_id(entry),
    password: DevelopmentStagingProductCatalog::BOOTSTRAP_PASSWORD,
    user_risk_state: "compliant",
    confirmed_at: DevelopmentStagingProductCatalog::SEED_TIME,
    payment_address: entry.seller_email
  )

  # Skip validations to set a pwned but easy password
  user.password = "password"
  user.save!(validate: false)

  user
end

def find_or_create_universal_free_offer_code_for(seller, entry)
  stable_code = "seed_#{entry.permalink}"
  offer_code = seller.offer_codes.universal.alive.find_by(code: stable_code)
  return offer_code if offer_code.present?

  OfferCode.create!(
    user: seller,
    universal: true,
    amount_percentage: 100,
    code: stable_code
  )
end

def create_purchase(seller, buyer, product, entry)
  purchase = Purchase.new(
    link_id: product.id,
    seller_id: seller.id,
    price_cents: 0,
    displayed_price_cents: 0,
    tax_cents: 0,
    gumroad_tax_cents: 0,
    total_transaction_cents: 0,
    purchaser_id: buyer.id,
    email: buyer.email,
    card_country: "US",
    ip_address: "199.241.200.176",
    offer_code: find_or_create_universal_free_offer_code_for(seller, entry)
  )
  purchase.send(:calculate_fees)
  purchase.save!
  purchase.update!(purchase_state: "successful", succeeded_at: DevelopmentStagingProductCatalog::SEED_TIME)

  purchase.post_review(rating: 3)
end

def create_recommendable_product_if_not_exists(user, entry)
  product = DevelopmentStagingProductCatalog.reconcile_product!(seller: user, entry:)
  return if product.persisted?

  product.assign_attributes(
    name: entry.name,
    description: DevelopmentStagingProductCatalog::DESCRIPTION,
    filetype: "link",
    price_cents: entry.price_cents,
    taxonomy: Taxonomy.find_by!(slug: entry.taxonomy_slug),
    display_product_reviews: true
  )
  product.save!
  product.tag!(entry.taxonomy_slug[0..19])

  buyer = User.find_by(email: "seller@gumroad.com")
  create_purchase(user, buyer, product, entry)
end

DevelopmentStagingProductCatalog.taxonomy_products.each do |entry|
  create_recommendable_product_if_not_exists(find_or_create_recommendable_user(entry), entry)
end

DevTools.delete_all_indices_and_reindex_all unless ENV["SKIP_DEVELOPMENT_STAGING_PRODUCT_REINDEX"] == "true"
