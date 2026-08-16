# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("lib/development_staging_product_catalog")

RSpec.describe "scripts/seed_development_staging_products.rb" do
  let(:seed_script) { Rails.root.join("scripts/seed_development_staging_products.rb") }
  let(:catalog_permalinks) { DevelopmentStagingProductCatalog.products.map(&:permalink) }

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

  def canonical_render_snapshot
    Link.where(unique_permalink: catalog_permalinks).order(:unique_permalink).map do |product|
      seller = product.user
      purchases = Purchase.where(link_id: product.id).order(:created_at)
      {
        product: product.attributes.except("id", "user_id", "taxonomy_id", "default_offer_code_id"),
        taxonomy: product.taxonomy && {
          "slug" => product.taxonomy.slug,
          "ancestor_slugs" => product.taxonomy.self_and_ancestors.pluck(:slug).sort,
        },
        tags: product.tags.order(:name).pluck(:name),
        seller: seller.attributes.slice(
          "external_id", "email", "name", "username", "payment_address", "bio", "profile_picture_url",
          "twitter_handle",
          "country", "state", "city", "verified", "currency_type", "locale", "timezone",
          "user_risk_state", "support_email", "json_data", "created_at", "updated_at", "confirmed_at"
        ),
        seller_profile: seller.seller_profile.attributes.except("id", "seller_id"),
        purchases: purchases.map do |purchase|
          purchase.attributes.except(
            "id", "link_id", "seller_id", "purchaser_id", "offer_code_id", "merchant_account_id",
            "purchase_success_balance_id", "purchase_chargeback_balance_id", "purchase_refund_balance_id"
          ).merge("offer_code" => purchase.offer_code&.code)
        end,
        reviews: ProductReview.where(link_id: product.id).order(:created_at).map do |review|
          review.attributes.except("id", "link_id", "purchase_id")
        end,
        offer_codes: seller.offer_codes.alive.order(:code).map do |offer_code|
          offer_code.attributes.except("id", "user_id", "link_id")
        end,
      }
    end
  end

  def independently_seeded_snapshot
    snapshot = nil
    ActiveRecord::Base.transaction(requires_new: true) do
      load(seed_script, true)
      snapshot = canonical_render_snapshot
      raise ActiveRecord::Rollback
    end
    snapshot
  end

  it "produces equal render-relevant snapshots in independently clean seed worlds" do
    first_snapshot = independently_seeded_snapshot
    second_snapshot = independently_seeded_snapshot

    expect(second_snapshot).to eq(first_snapshot)
    expect(first_snapshot.flat_map { _1[:offer_codes].pluck("code") }.sort).to eq(
      DevelopmentStagingProductCatalog.taxonomy_products.map { "seed_#{_1.permalink}" }.sort,
    )
    expect(first_snapshot.flat_map { _1[:purchases].pluck("created_at") }.uniq)
      .to eq([DevelopmentStagingProductCatalog::SEED_TIME])
    expect(first_snapshot.flat_map { _1[:reviews].pluck("created_at") }.uniq)
      .to eq([DevelopmentStagingProductCatalog::SEED_TIME])
    expect(first_snapshot.map { _1[:seller]["external_id"] }.sort).to eq(
      DevelopmentStagingProductCatalog.products.map { DevelopmentStagingProductCatalog.seller_external_id(_1) }.sort,
    )

    # BCrypt salts are intentionally random and never reach ProductPresenter.
    # Opaque IDs derived from database IDs are excluded because savepoint rollback
    # cannot rewind MySQL sequences; the clean twins share seed order and cipher keys.
    expect(first_snapshot.to_s).not_to include("encrypted_password")
  end
end
