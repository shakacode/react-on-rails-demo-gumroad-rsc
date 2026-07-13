# frozen_string_literal: true

require "spec_helper"

RSpec.describe "development/staging Discover product seeds" do
  let(:seed_file) { Rails.root.join("db/seeds/020_development_staging/taxonomy_products.rb") }
  let(:fixture_cards) { PublicProductRscDemoPresenter::DISCOVER_PRODUCT_CARDS }
  let(:fixture_names) { fixture_cards.map { _1.fetch(:name) } }
  let(:link_index) { Link.__elasticsearch__ }
  let(:purchase_index) { Purchase.__elasticsearch__ }
  let(:index_events) { [] }

  before do
    allow(DevTools).to receive(:delete_all_indices_and_reindex_all)
    allow(Link).to receive(:import) { index_events << :link_import }
    allow(Purchase).to receive(:import) { index_events << :purchase_import }
    allow(link_index).to receive(:create_index!) do
      index_events << :link_create
      raise Elasticsearch::Transport::Transport::Errors::BadRequest.new("resource_already_exists_exception")
    end
    allow(link_index).to receive(:index_exists?) do
      index_events << :link_exists
      true
    end
    allow(purchase_index).to receive(:create_index!) do
      index_events << :purchase_create
      raise Elasticsearch::Transport::Transport::Errors::BadRequest.new("resource_already_exists_exception")
    end
    allow(purchase_index).to receive(:index_exists?) do
      index_events << :purchase_exists
      true
    end
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
    expect(products.map { _1.json_data.fetch("discover_demo_fixture_owner") }).to all(eq("rsc-discover-demo"))
    expect(products.map { _1.json_data.fetch("discover_demo_fixture_version") }).to all(eq(1))

    first_product.json_data["discover_demo_fixture_version"] = 0
    first_product.save!

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
    expect(first_product.reload.json_data.fetch("discover_demo_fixture_version")).to eq(1)
    expect(DevTools).not_to have_received(:delete_all_indices_and_reindex_all)
    expect(link_index).to have_received(:create_index!).exactly(3).times
    expect(link_index).to have_received(:index_exists?).exactly(3).times
    expect(Link).to have_received(:import).with(no_args).exactly(3).times
    expect(purchase_index).to have_received(:create_index!).exactly(3).times
    expect(purchase_index).to have_received(:index_exists?).exactly(3).times
    expect(Purchase).to have_received(:import).with(no_args).exactly(3).times
    expect(index_events).to eq(
      %i[purchase_create purchase_exists purchase_import link_create link_exists link_import] * 3
    )
  end

  it "fails closed when index creation errors are not verified as an existing index" do
    failures = [
      ["mapper_parsing_exception", true],
      ["resource_already_exists_exception", false],
    ]

    failures.each do |message, index_exists|
      error = Elasticsearch::Transport::Transport::Errors::BadRequest.new(message)
      allow(purchase_index).to receive(:create_index!).and_raise(error)
      allow(purchase_index).to receive(:index_exists?).and_return(index_exists)

      expect { load(seed_file, true) }.to raise_error(error.class, message)
    end

    expect(Purchase).not_to have_received(:import)
    expect(link_index).not_to have_received(:create_index!)
    expect(Link).not_to have_received(:import)
  end

  it "refuses to overwrite a product that already owns a fixture permalink" do
    unrelated_product = create(
      :product,
      name: "Manual staging product",
      unique_permalink: "discover_a_launch_metrics_os",
    )
    original_attributes = unrelated_product.attributes.slice("user_id", "name", "description", "price_cents", "deleted_at")

    expect { load(seed_file, true) }
      .to raise_error(RuntimeError, /Refusing to overwrite non-fixture product/)

    expect(unrelated_product.reload.attributes.slice(*original_attributes.keys)).to eq(original_attributes)
    expect(unrelated_product.thumbnail).to be_nil
    expect(unrelated_product.sales).to be_empty
    expect(unrelated_product.product_reviews).to be_empty
  end

  it "does not infer fixture ownership from the seller email alone" do
    fixture_seller = create(:user, email: "discover-metric-harbor@gumroad.com")
    unrelated_product = create(
      :product,
      user: fixture_seller,
      name: "Manual product on a fixture seller",
      unique_permalink: "discover_a_launch_metrics_os",
    )
    original_user_attributes = fixture_seller.attributes.slice("name", "username", "user_risk_state", "payment_address", "json_data")
    original_attributes = unrelated_product.attributes.slice("name", "description", "price_cents", "json_data")

    expect { load(seed_file, true) }
      .to raise_error(RuntimeError, /Refusing to overwrite non-fixture user/)

    expect(fixture_seller.reload.attributes.slice(*original_user_attributes.keys)).to eq(original_user_attributes)
    expect(unrelated_product.reload.attributes.slice(*original_attributes.keys)).to eq(original_attributes)
  end

  it "does not delete a legacy fixture lookalike without durable seed ownership" do
    legacy_seller = create(:user, email: "gumbo_film@gumroad.com")
    lookalike = create(
      :product,
      user: legacy_seller,
      name: "Beautiful films widget",
      description: "Description for demo product",
      price_cents: 500,
      taxonomy: Taxonomy.find_by!(slug: "films"),
      display_product_reviews: true,
    )

    expect { load(seed_file, true) }.not_to change { lookalike.reload.deleted_at }
  end
end
