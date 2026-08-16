# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("lib/development_staging_product_catalog")

RSpec.describe "scripts/seed_development_staging_products.rb" do
  let(:seed_script) { Rails.root.join("scripts/seed_development_staging_products.rb") }
  before do
    allow(DevTools).to receive(:delete_all_indices_and_reindex_all)
  end

  it "seeds the canonical 16 products idempotently" do
    expect { load(seed_script, true) }.to change(Link, :count).by(16)

    seeded_products = Link.where(unique_permalink: DevelopmentStagingProductCatalog.products.map(&:permalink))
    original_ids = seeded_products.order(:unique_permalink).pluck(:id)
    original_sales = Purchase.where(link_id: original_ids).count

    expect { load(seed_script, true) }
      .to not_change(Link, :count)
      .and not_change { Purchase.where(link_id: original_ids).count }

    expect(seeded_products.reload.order(:unique_permalink).pluck(:id)).to eq(original_ids)
    expect(original_sales).to eq(15)
  end

end
