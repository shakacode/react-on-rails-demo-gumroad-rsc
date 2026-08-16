# frozen_string_literal: true

require "active_support/testing/time_helpers"
require Rails.root.join("lib/development_staging_product_surface_snapshot")

output_path = Pathname(ARGV.fetch(0))
clock = Object.new.extend(ActiveSupport::Testing::TimeHelpers)
clock.travel_to(DevelopmentStagingProductCatalog::SEED_TIME) do
  DevelopmentStagingProductSurfaceSnapshot.write(output_path)
end

puts "Wrote canonical product surface snapshot to #{output_path}"
