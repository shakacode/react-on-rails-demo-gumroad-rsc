# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_catalog")

entry = DevelopmentStagingProductCatalog.fetch(category: "demo")
seller = User.find_by!(email: entry.seller_email)
product = DevelopmentStagingProductCatalog.reconcile_product!(seller:, entry:)
if product.new_record?
  # Demo product used on /widgets page for non-logged in users
  product.assign_attributes(
    name: entry.name,
    description: DevelopmentStagingProductCatalog::DESCRIPTION,
    filetype: "link",
    price_cents: entry.price_cents,
  )
  product.save!
end
