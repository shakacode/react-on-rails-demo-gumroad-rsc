# frozen_string_literal: true

require Rails.root.join("lib/development_staging_product_surface_snapshot")

left_path, right_path = ARGV.map { Pathname(_1) }
DevelopmentStagingProductSurfaceSnapshot.verify_equal!(left_path, right_path)
puts "Canonical product surface snapshots are identical"
