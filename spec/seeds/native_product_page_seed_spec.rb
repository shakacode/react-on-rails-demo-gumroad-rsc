# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native product page seed" do
  let(:seed_file) { Rails.root.join("scripts/seed_native_product_page.rb") }
  let(:permalinks) { %w[O365IT M365PS M365Purview PowerPlatform] }

  it "creates an idempotent, realistic creator catalog with visible reviews" do
    expect { load(seed_file, true) }
      .to change { Link.where(custom_permalink: permalinks).count }.from(0).to(4)
      .and change { Purchase.joins(:link).where(links: { custom_permalink: permalinks }).count }.from(0).to(21)
      .and change { ProductReview.joins(:link).where(links: { custom_permalink: permalinks }).count }.from(0).to(21)

    seller = User.find_by!(email: "office365-it-pros-benchmark@example.com")
    product = Link.fetch_leniently("O365IT")

    expect(seller).to have_attributes(name: "Office 365 for IT Pros", username: "o365itpros")
    expect(product).to have_attributes(
      user: seller,
      name: "Microsoft 365 for IT Pros (2027 Edition). The Ultimate Guide to Managing Microsoft 365.",
      price_cents: 5_995,
      native_type: Link::NATIVE_TYPE_EBOOK,
      display_product_reviews?: true,
    )
    expect(product.custom_summary).to include("Four books")
    expect(product.custom_attributes).to include("name" => "Pages", "value" => "1,000")
    expect(product.thumbnail.url).to eq("/native-product-page-fixture/microsoft-365.png")
    expect(product.display_asset_previews.first.url).to eq("/native-product-page-fixture/microsoft-365.png")
    expect(product.tags.pluck(:name)).to match_array(["microsoft 365", "it administration"])
    expect(product.product_reviews.visible_on_product_page.count).to eq(21)
    expect(product.reviews_count).to eq(21)
    expect(product.average_rating).to eq(5.0)
    expect(Link.fetch_leniently("M365PS").reviews_count).to eq(0)

    expect { load(seed_file, true) }
      .to not_change { User.where("email LIKE ?", "%benchmark%example.com").count }
      .and not_change { Link.where(custom_permalink: permalinks).count }
      .and not_change { Purchase.joins(:link).where(links: { custom_permalink: permalinks }).count }
      .and not_change { ProductReview.joins(:link).where(links: { custom_permalink: permalinks }).count }
  end

  it "refuses to overwrite a product that already uses a fixture permalink" do
    unrelated_product = create(:product, custom_permalink: "O365IT", name: "My existing product")

    expect { load(seed_file, true) }
      .to raise_error(RuntimeError, /Refusing to overwrite non-fixture product/)

    expect(unrelated_product.reload.name).to eq("My existing product")
  end

  it "refuses to infer ownership from the fixture seller email" do
    unrelated_seller = create(:user, email: "office365-it-pros-benchmark@example.com", name: "Existing seller")

    expect { load(seed_file, true) }
      .to raise_error(RuntimeError, /Refusing to overwrite non-fixture user/)

    expect(unrelated_seller.reload.name).to eq("Existing seller")
  end
end
