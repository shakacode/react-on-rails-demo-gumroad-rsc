# frozen_string_literal: true

require "spec_helper"

describe "Public product RSC demo routes", type: :system, js: true do
  let(:seller) { create(:named_seller, email: PublicProductRscDemoController::PUBLIC_DEMO_SELLER_EMAIL, name: "Public Creator") }
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

  it "renders a public performance lab that makes the comparison obvious" do
    visit public_product_performance_demo_path

    expect(page).to have_current_path(public_product_performance_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Gumroad RSC performance lab")
    expect(page).to have_text("Live browser race")
    expect(page).to have_text("First streamed bytes")
    expect(page).to have_text("Route script bytes")
    expect(page).to have_text("Serialized Inertia payload")
    expect(page).to have_link("Home", href: root_path)
    expect(page).to have_link("Back to home", href: root_path)
    expect(page).to have_link("Open Inertia route", href: public_product_inertia_demo_path)
    expect(page).to have_link("Open RSC route", href: public_product_rsc_demo_path)
    expect(page).to have_link("Learn React on Rails", href: "https://reactonrails.com/")
    expect(page).to have_link("react_on_rails source", href: "https://github.com/shakacode/react_on_rails")
    expect(page).to have_link("Book a consultation", href: "https://meetings.hubspot.com/justingordon/30-minute-consultation")
    expect(page).to have_text("For Gumroad maintainers")
    expect(page).to have_text("For teams evaluating React on Rails")
    expect(page).to have_text("For teams evaluating ShakaCode")
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
    expect(page).to have_link("Open performance lab", href: public_product_performance_demo_path)
    expect(page).to have_link("Open RSC demo", href: public_product_rsc_demo_path)
    expect(page).to have_link("Back to home", href: root_path)
    expect(page).not_to have_link("Open current product page")

    within("nav[aria-label='Public product comparison routes']") do
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Performance lab", href: public_product_performance_demo_path)
      expect(page).to have_link("Inertia demo", aria: { current: "page" })
      expect(page).to have_link("RSC demo", href: public_product_rsc_demo_path)
      expect(page).not_to have_link("Current product page")
    end
  end

  it "renders the RSC candidate while logged out" do
    visit public_product_rsc_demo_path

    expect(page).to have_current_path(public_product_rsc_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Public RSC widget")
    expect(page).to have_text("React Server Components via React on Rails Pro public product demo")
    expect(page).to have_text("Buyer-facing product story for the public route.")
    expect(page).to have_text("Public Creator")
    expect(page).to have_text("$19")
    expect(page).to have_link("Open performance lab", href: public_product_performance_demo_path)
    expect(page).to have_link("Open Inertia demo", href: public_product_inertia_demo_path)
    expect(page).to have_link("Back to home", href: root_path)
    expect(page).not_to have_link("Open current product page")

    within("nav[aria-label='Public product comparison routes']") do
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Performance lab", href: public_product_performance_demo_path)
      expect(page).to have_link("RSC demo", aria: { current: "page" })
      expect(page).to have_link("Inertia demo", href: public_product_inertia_demo_path)
      expect(page).not_to have_link("Current product page")
    end
  end
end
