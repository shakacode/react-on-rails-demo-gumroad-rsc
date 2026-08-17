# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_catalog")

def find_or_create_recommendable_user(entry)
  DevelopmentStagingProductCatalog.reconcile_seller!(entry:)
end

def create_recommendable_product_if_not_exists(user, entry)
  product = DevelopmentStagingProductCatalog.reconcile_product!(seller: user, entry:)
  buyer = User.find_by!(email: DevelopmentStagingProductCatalog.fetch(category: "demo").seller_email)
  DevelopmentStagingProductCatalog.reconcile_review_state!(seller: user, product:, entry:, buyer:)
end

DevelopmentStagingProductCatalog.taxonomy_products.each do |entry|
  create_recommendable_product_if_not_exists(find_or_create_recommendable_user(entry), entry)
end

DevTools.delete_all_indices_and_reindex_all unless ENV["SKIP_DEVELOPMENT_STAGING_PRODUCT_REINDEX"] == "true"
