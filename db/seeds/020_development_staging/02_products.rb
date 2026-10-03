# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_catalog")

entry = DevelopmentStagingProductCatalog.fetch(category: "demo")
seller = User.find_by!(email: entry.seller_email)
# Demo product used on /widgets page for non-logged in users.
DevelopmentStagingProductCatalog.reconcile_product!(seller:, entry:)
