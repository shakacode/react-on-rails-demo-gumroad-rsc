# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("lib/development_staging_product_surface_snapshot")

RSpec.describe DevelopmentStagingProductSurfaceSnapshot do
  let(:seed_script) { Rails.root.join("scripts/seed_development_staging_products.rb") }

  before do
    allow(DevTools).to receive(:delete_all_indices_and_reindex_all)
    load(seed_script, true)
  end

  it "captures the authoritative page props and renderer-relevant state for all catalog products" do
    snapshot = described_class.generate

    expect(snapshot.fetch("products").size).to eq(DevelopmentStagingProductCatalog.products.size)
    snapshot.fetch("products").each do |item|
      expect(item.dig("page_props", "product", "id")).to eq(item.dig("state", "product", "external_id"))
      expect(item.dig("page_props", "product", "seller", "id")).to eq(item.dig("state", "seller", "external_id"))
      expect(item.dig("page_props", "product")).to have_key("refund_policy")
      expect(item.dig("state", "seller_refund_policy", "presenter_props", "title")).to be_present
      expect(item.dig("state", "seller_refund_policy", "external_id")).to be_present
      expect(item.dig("state", "product", "id")).to be_present
      expect(item.dig("state", "purchases")).to all(include("external_id")) unless item.dig("state", "purchases").empty?
      expect(item.dig("state", "reviews")).to all(include("external_id")) unless item.dig("state", "reviews").empty?
      expect(item.dig("state", "seller")).not_to have_key("encrypted_password")
      expect(item.dig("state", "seller")).not_to have_key("otp_secret_key")
    end
  end

  it "rejects a mismatch in authoritative presenter output" do
    left = described_class.generate
    right = left.deep_dup
    right.dig("products", 0, "page_props", "product")["name"] = "Different rendered name"

    expect { described_class.verify_equal!(left, right) }
      .to raise_error(DevelopmentStagingProductSurfaceSnapshot::SnapshotMismatch, /snapshots differ/u)
  end

  it "rejects snapshots that omit refund-policy presenter output" do
    snapshot = described_class.generate
    snapshot.dig("products", 0, "page_props", "product").delete("refund_policy")

    expect { described_class.validate!(snapshot) }
      .to raise_error(DevelopmentStagingProductSurfaceSnapshot::InvalidSnapshot, /seller refund-policy props/u)
  end
end
