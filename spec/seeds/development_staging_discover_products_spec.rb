# frozen_string_literal: true

require "spec_helper"

RSpec.describe "development/staging Discover product seeds" do
  let(:seed_file) { Rails.root.join("db/seeds/020_development_staging/taxonomy_products.rb") }
  let(:fixture_cards) { PublicProductRscDemoPresenter::DISCOVER_PRODUCT_CARDS }
  let(:fixture_names) { fixture_cards.map { _1.fetch(:name) } }
  let(:link_index) { Link.__elasticsearch__ }

  before do
    allow(DevTools).to receive(:delete_all_indices_and_reindex_all)
    allow(Link).to receive(:import)
    allow(link_index).to receive(:create_index!).and_raise(
      Elasticsearch::Transport::Transport::Errors::BadRequest.new("resource_already_exists_exception")
    )
    allow(link_index).to receive(:index_exists?).and_return(true)
    load(Rails.root.join("db/seeds/010_development_staging_test/taxonomy_create.rb"), true)
  end

  it "creates an idempotent card-specific native inventory from the benchmark fixture" do
    load(seed_file, true)

    products = Link.where(name: fixture_names).includes(:thumbnail, :product_review_stat)
    first_product = products.find { _1.name == fixture_names.first }

    expect(products.size).to eq(36)
    expect(products.map(&:name)).to match_array(fixture_names)
    expect(first_product).to have_attributes(
      name: "Launch Metrics OS",
      price_cents: 4900,
      description: include("preorders"),
    )
    expect(first_product.thumbnail.url).to eq(
      "/public-product-rsc-demo/media/marketplace-analytics.svg"
    )
    expect(products.map { _1.thumbnail.url }.uniq.size).to eq(8)
    expect(products.map(&:reviews_count)).to all(eq(10))
    expect(products.map(&:average_rating).uniq.sort).to eq([4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8])

    expect { load(seed_file, true) }
      .to not_change { Link.where(name: fixture_names).count }
      .and not_change { Purchase.where(link_id: products.map(&:id)).count }
      .and not_change { ProductReview.where(link_id: products.map(&:id)).count }

    partial_purchase = Purchase.find_by!(link_id: first_product.id, purchaser_id: User.find_by!(email: "discover-demo-buyer-1@gumroad.com").id)
    partial_purchase.product_review.delete
    partial_purchase.update_columns(purchase_state: "in_progress", succeeded_at: nil)

    load(seed_file, true)

    expect(partial_purchase.reload).to have_attributes(purchase_state: "successful", succeeded_at: be_present)
    expect(partial_purchase.product_review).to have_attributes(rating: 5)
    expect(DevTools).not_to have_received(:delete_all_indices_and_reindex_all)
    expect(link_index).to have_received(:create_index!).exactly(3).times
    expect(link_index).to have_received(:index_exists?).exactly(3).times
    expect(Link).to have_received(:import).with(no_args).exactly(3).times
  end
end
