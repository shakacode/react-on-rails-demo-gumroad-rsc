# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_catalog")
require "active_support/testing/time_helpers"

seed_files = %w[
  db/seeds/010_development_staging_test/taxonomy_create.rb
  db/seeds/020_development_staging/01_users.rb
  db/seeds/020_development_staging/02_products.rb
  db/seeds/020_development_staging/taxonomy_products.rb
]

original_skip_reindex = ENV["SKIP_DEVELOPMENT_STAGING_PRODUCT_REINDEX"]
begin
  ENV["SKIP_DEVELOPMENT_STAGING_PRODUCT_REINDEX"] = "true"
  clock = Object.new.extend(ActiveSupport::Testing::TimeHelpers)
  clock.travel_to(DevelopmentStagingProductCatalog::SEED_TIME) do
    seed_files.each { |relative_path| load(Rails.root.join(relative_path), true) }
  end

  catalog = DevelopmentStagingProductCatalog.products
  seeded_products = Link.where(unique_permalink: catalog.map(&:permalink))
  unless seeded_products.count == catalog.size
    raise "Expected #{catalog.size} canonical development/staging products, found #{seeded_products.count}"
  end

  puts "Seeded #{seeded_products.count} canonical development/staging products"
ensure
  if original_skip_reindex.nil?
    ENV.delete("SKIP_DEVELOPMENT_STAGING_PRODUCT_REINDEX")
  else
    ENV["SKIP_DEVELOPMENT_STAGING_PRODUCT_REINDEX"] = original_skip_reindex
  end
end
