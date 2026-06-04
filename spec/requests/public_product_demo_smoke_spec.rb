# frozen_string_literal: true

require "spec_helper"

describe "Public product RSC demo routes", type: :system, js: true do
  let(:seller) { create(:named_seller, name: "Public Creator") }
  let!(:product) do
    create(
      :product,
      user: seller,
      unique_permalink: "demo",
      name: "Public RSC widget",
      price_cents: 1900,
      description: "<p>Buyer-facing product story for the public route.</p>"
    )
  end

  before do
    product.save_custom_summary("A concise public product summary.")
  end

  it "renders the Inertia control while logged out" do
    visit public_product_inertia_demo_path

    expect(page).to have_current_path(public_product_inertia_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Public RSC widget")
    expect(page).to have_text("Inertia public product demo")
    expect(page).to have_text("Buyer-facing product story for the public route.")
    expect(page).to have_text("Public Creator")
    expect(page).to have_text("$19")
    expect(page).to have_link("Open RSC demo", href: public_product_rsc_demo_path)
    expect(page).to have_link("Open current product page", href: short_link_path(product))

    within("nav[aria-label='Public product comparison routes']") do
      expect(page).to have_link("Inertia demo", aria: { current: "page" })
      expect(page).to have_link("RSC demo", href: public_product_rsc_demo_path)
      expect(page).to have_link("Current product page", href: short_link_path(product))
    end
  end

  it "renders the RSC candidate while logged out" do
    visit public_product_rsc_demo_path

    expect(page).to have_current_path(public_product_rsc_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Public RSC widget")
    expect(page).to have_text("React on Rails Pro + RSC public product demo")
    expect(page).to have_text("Buyer-facing product story for the public route.")
    expect(page).to have_text("Public Creator")
    expect(page).to have_text("$19")
    expect(page).to have_link("Open Inertia demo", href: public_product_inertia_demo_path)
    expect(page).to have_link("Open current product page", href: short_link_path(product))

    within("nav[aria-label='Public product comparison routes']") do
      expect(page).to have_link("RSC demo", aria: { current: "page" })
      expect(page).to have_link("Inertia demo", href: public_product_inertia_demo_path)
      expect(page).to have_link("Current product page", href: short_link_path(product))
    end
  end
end
