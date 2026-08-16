# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("lib/development_staging_product_catalog")

RSpec.describe "development/staging product seeds" do
  let(:demo_seed_file) { Rails.root.join("db/seeds/020_development_staging/02_products.rb") }
  let(:taxonomy_seed_file) { Rails.root.join("db/seeds/020_development_staging/taxonomy_products.rb") }

  before do
    create(:user, email: "seller@gumroad.com")
    allow(DevTools).to receive(:delete_all_indices_and_reindex_all)
    load(Rails.root.join("db/seeds/010_development_staging_test/taxonomy_create.rb"), true)
  end

  def load_product_seeds
    load(demo_seed_file, true)
    load(taxonomy_seed_file, true)
  end

  it "creates the canonical catalog once and remains stable on repeat runs" do
    expect { load_product_seeds }.to change(Link, :count).by(16)

    catalog_products = Link.where(unique_permalink: DevelopmentStagingProductCatalog.products.map(&:permalink))
    original_ids = catalog_products.order(:unique_permalink).pluck(:id)
    original_purchase_count = Purchase.where(link_id: catalog_products.select(:id)).count

    expect(catalog_products.pluck(:name, :unique_permalink)).to contain_exactly(
      *DevelopmentStagingProductCatalog.products.map { [_1.name, _1.permalink] }
    )

    expect { load_product_seeds }
      .to not_change(Link, :count)
      .and not_change { Purchase.where(link_id: original_ids).count }

    persisted_ids = Link
      .where(unique_permalink: DevelopmentStagingProductCatalog.products.map(&:permalink))
      .order(:unique_permalink)
      .pluck(:id)
    expect(persisted_ids).to eq(original_ids)
    expect(Purchase.where(link_id: original_ids).count).to eq(original_purchase_count)
  end

  it "converges a legacy generated permalink without creating a duplicate" do
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    seller = create(:user, email: entry.seller_email)
    legacy_product = seller.links.create!(
      name: entry.name,
      description: "Description for demo product",
      filetype: "link",
      price_cents: 500,
      taxonomy: Taxonomy.find_by!(slug: entry.taxonomy_slug),
      display_product_reviews: true,
    )
    generated_permalink = legacy_product.unique_permalink

    load_product_seeds

    expect(legacy_product.reload).to have_attributes(unique_permalink: entry.permalink)
    expect(legacy_product.unique_permalink).not_to eq(generated_permalink)
    expect(seller.links.where(name: entry.name).count).to eq(1)
  end

  it "fails clearly rather than taking a stable permalink from an unrelated product" do
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    unrelated_product = create(:product, name: "Unrelated product", unique_permalink: entry.permalink)
    original_attributes = unrelated_product.attributes.slice("user_id", "name", "description", "price_cents", "json_data")

    expect { load_product_seeds }.to raise_error(
      DevelopmentStagingProductCatalog::OwnershipConflict,
      /#{entry.permalink}.*already belongs to an unrelated product/,
    )

    expect(unrelated_product.reload.attributes.slice(*original_attributes.keys)).to eq(original_attributes)
  end
end
