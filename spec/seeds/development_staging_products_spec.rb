# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("lib/development_staging_product_catalog")

RSpec.describe "development/staging product seeds" do
  let(:user_seed_file) { Rails.root.join("db/seeds/020_development_staging/01_users.rb") }
  let(:demo_seed_file) { Rails.root.join("db/seeds/020_development_staging/02_products.rb") }
  let(:taxonomy_seed_file) { Rails.root.join("db/seeds/020_development_staging/taxonomy_products.rb") }

  before do
    allow(DevTools).to receive(:delete_all_indices_and_reindex_all)
    load(Rails.root.join("db/seeds/010_development_staging_test/taxonomy_create.rb"), true)
  end

  def load_product_seeds
    load(user_seed_file, true)
    load(demo_seed_file, true)
    load(taxonomy_seed_file, true)
  end

  it "creates the canonical catalog once and remains stable on repeat runs" do
    expect { load_product_seeds }.to change(Link, :count).by(16)

    catalog_products = Link.where(unique_permalink: DevelopmentStagingProductCatalog.products.map(&:permalink))
    original_ids = catalog_products.order(:unique_permalink).pluck(:id)
    original_purchase_count = Purchase.where(link_id: catalog_products.select(:id)).count
    original_review_count = ProductReview.where(link_id: catalog_products.select(:id)).count

    expect(catalog_products.pluck(:name, :unique_permalink)).to contain_exactly(
      *DevelopmentStagingProductCatalog.products.map { [_1.name, _1.permalink] }
    )

    expect { load_product_seeds }
      .to not_change(Link, :count)
      .and not_change { Purchase.where(link_id: original_ids).count }
      .and not_change { ProductReview.where(link_id: original_ids).count }

    persisted_ids = Link
      .where(unique_permalink: DevelopmentStagingProductCatalog.products.map(&:permalink))
      .order(:unique_permalink)
      .pluck(:id)
    expect(persisted_ids).to eq(original_ids)
    expect(Purchase.where(link_id: original_ids).count).to eq(original_purchase_count)
    expect(ProductReview.where(link_id: original_ids).count).to eq(original_review_count)
  end

  it "converges a legacy generated permalink without creating a duplicate" do
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    seller = create(
      :user,
      email: entry.seller_email,
      name: "Gumbo #{entry.category}",
      username: entry.seller_username,
      user_risk_state: "compliant",
      payment_address: entry.seller_email,
    )
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
    expect(seller.reload.json_data).to include(
      DevelopmentStagingProductCatalog::OWNER_KEY => DevelopmentStagingProductCatalog::OWNER,
    )
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
    expect(unrelated_product.sales).to be_empty
    expect(unrelated_product.product_reviews).to be_empty
  end

  it "does not infer product ownership from an owned catalog seller" do
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    seller = create(
      :user,
      email: entry.seller_email,
      external_id: DevelopmentStagingProductCatalog.seller_external_id(entry),
      name: "Gumbo #{entry.category}",
      username: entry.seller_username,
      confirmed_at: DevelopmentStagingProductCatalog::SEED_TIME,
      user_risk_state: "compliant",
      payment_address: entry.seller_email,
      json_data: {
        DevelopmentStagingProductCatalog::OWNER_KEY => DevelopmentStagingProductCatalog::OWNER,
        DevelopmentStagingProductCatalog::SELLER_EMAIL_KEY => entry.seller_email,
      },
    )
    unrelated_product = create(
      :product,
      user: seller,
      name: "Manual product on a canonical seed seller",
      unique_permalink: entry.permalink,
    )
    original_user_attributes = seller.attributes.slice("name", "username", "user_risk_state", "payment_address", "json_data")
    original_product_attributes = unrelated_product.attributes.slice("name", "description", "price_cents", "json_data")

    expect { load_product_seeds }.to raise_error(
      DevelopmentStagingProductCatalog::OwnershipConflict,
      /#{entry.permalink}.*already belongs to an unrelated product/,
    )

    expect(seller.reload.attributes.slice(*original_user_attributes.keys)).to eq(original_user_attributes)
    expect(unrelated_product.reload.attributes.slice(*original_product_attributes.keys)).to eq(original_product_attributes)
  end

  it "does not infer seller ownership from the canonical email alone" do
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    unrelated_seller = create(
      :user,
      email: entry.seller_email,
      name: "Gumbo #{entry.category}",
      username: entry.seller_username,
      user_risk_state: "compliant",
      payment_address: entry.seller_email,
    )
    original_attributes = unrelated_seller.attributes.slice(
      "name", "username", "email", "external_id", "user_risk_state", "payment_address", "json_data"
    )

    expect { load_product_seeds }.to raise_error(
      DevelopmentStagingProductCatalog::OwnershipConflict,
      /seller.*#{Regexp.escape(entry.seller_email)}.*unrelated/u,
    )

    expect(unrelated_seller.reload.attributes.slice(*original_attributes.keys)).to eq(original_attributes)
    expect(unrelated_seller.links).to be_empty
  end

  it "does not adopt a failed purchase that resembles the historical seed fixture" do
    load_product_seeds
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    product = Link.find_by!(unique_permalink: entry.permalink)
    seller = product.user
    buyer = User.find_by!(email: "seller@gumroad.com")
    product.sales.sole.destroy!
    legacy_offer = seller.offer_codes.create!(
      universal: true,
      amount_percentage: 100,
      code: "seed-#{seller.id}-abcdef",
    )
    unrelated_purchase = Purchase.new(
      link_id: product.id,
      seller_id: seller.id,
      price_cents: 0,
      displayed_price_cents: 0,
      tax_cents: 0,
      gumroad_tax_cents: 0,
      total_transaction_cents: 0,
      purchaser_id: buyer.id,
      email: buyer.email,
      card_country: "US",
      ip_address: "199.241.200.176",
      offer_code: legacy_offer,
    )
    unrelated_purchase.send(:calculate_fees)
    unrelated_purchase.save!
    unrelated_purchase.update!(purchase_state: "successful", succeeded_at: DevelopmentStagingProductCatalog::SEED_TIME)
    unrelated_purchase.post_review(rating: 3)
    unrelated_purchase.update!(purchase_state: "failed", succeeded_at: nil)

    expect { load_product_seeds }.to change { product.sales.count }.by(1)

    expect(unrelated_purchase.reload).to have_attributes(
      purchase_state: "failed",
      succeeded_at: nil,
      offer_code: legacy_offer,
    )
    expect(unrelated_purchase.json_data).not_to include(DevelopmentStagingProductCatalog::OWNER_KEY)
    expect(product.sales.where.not(id: unrelated_purchase.id).sole).to have_attributes(
      purchase_state: "successful",
      succeeded_at: DevelopmentStagingProductCatalog::SEED_TIME,
    )
  end

  it "converges renderer-visible catalog and review state for owned records without changing identities" do
    load_product_seeds
    entry = DevelopmentStagingProductCatalog.fetch(category: "film")
    product = Link.find_by!(unique_permalink: entry.permalink)
    seller = product.user
    purchase = product.sales.sole
    review = purchase.product_review
    offer_code = purchase.offer_code
    original_ids = [seller.id, product.id, purchase.id, review.id, offer_code.id]
    unrelated_purchase = create(:purchase, link: product, seller:, purchase_state: "failed")

    seller.update!(name: "Drifted seller", username: "driftedfilm", payment_address: "drifted@example.com")
    product.update!(
      name: "Drifted product",
      description: "Drifted description",
      price_cents: 9_999,
      taxonomy: Taxonomy.find_by!(slug: "audio"),
      display_product_reviews: false,
    )
    product.save_tags!(["drifted"])
    offer_code.update!(code: "drifted-code", amount_percentage: 25)
    purchase.update!(purchase_state: "failed", succeeded_at: nil, price_cents: 99, displayed_price_cents: 99)
    review.update_columns(rating: 1, deleted_at: DevelopmentStagingProductCatalog::SEED_TIME)

    expect { load_product_seeds }
      .to not_change(User, :count)
      .and not_change(Link, :count)
      .and not_change(Purchase, :count)
      .and not_change(ProductReview, :count)
      .and not_change(OfferCode, :count)

    expect([seller.reload.id, product.reload.id, purchase.reload.id, review.reload.id, offer_code.reload.id]).to eq(original_ids)
    expect(seller).to have_attributes(
      name: "Gumbo #{entry.category}",
      username: entry.seller_username,
      payment_address: entry.seller_email,
      subdomain: "#{entry.seller_username}.#{ROOT_DOMAIN}",
    )
    expect(product).to have_attributes(
      name: entry.name,
      description: DevelopmentStagingProductCatalog::DESCRIPTION,
      price_cents: entry.price_cents,
      taxonomy: Taxonomy.find_by!(slug: entry.taxonomy_slug),
      display_product_reviews?: true,
    )
    expect(product.tags.pluck(:name)).to eq([entry.taxonomy_slug.first(20)])
    expect(offer_code).to have_attributes(
      code: "seed_#{entry.permalink}",
      amount_percentage: 100,
      universal?: true,
    )
    expect(purchase).to have_attributes(
      purchase_state: "successful",
      succeeded_at: DevelopmentStagingProductCatalog::SEED_TIME,
      price_cents: 0,
      displayed_price_cents: 0,
    )
    expect(review).to have_attributes(rating: 3, deleted_at: nil)
    expect(unrelated_purchase.reload).to have_attributes(purchase_state: "failed")
    expect(product).to have_attributes(reviews_count: 1, average_rating: 3.0)
  end
end
