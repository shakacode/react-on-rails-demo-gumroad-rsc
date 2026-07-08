# frozen_string_literal: true

require "spec_helper"

describe "Public product RSC demo routes", type: :system, js: true do
  let(:deployed_performance_url) { "#{PublicProductRscDemoPresenter::HOSTED_DEMO_BASE_URL}#{public_product_performance_demo_path}" }

  it "renders a public performance lab that makes the product and Discover comparisons obvious" do
    visit public_product_performance_demo_path

    expect(page).to have_current_path(public_product_performance_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Gumroad RSC performance lab")
    expect(page).to have_text("Public buyer-page A/B report")
    expect(page).to have_text("React on Rails Pro 17 / React 19.2 audit")
    expect(page).to have_text("Static caching boundary")
    expect(page).to have_text("Current branch ShakaPerf A/B result")
    expect(page).to have_text("Historical hosted run")
    expect(page).to have_text("-45.8%")
    expect(page).to have_text("-19.1%")
    expect(page).to have_text("Fixture provenance")
    expect(page).to have_text("Product detail A/B route pair")
    expect(page).to have_text("Discover marketplace A/B route pair")
    expect(page).to have_text("First streamed bytes")
    expect(page).to have_text("Stream timing attribution")
    expect(page).to have_text("Route script bytes")
    expect(page).to have_text("Serialized Inertia payload")
    expect(page).to have_text("Hosted review-app rerun")
    expect(page).to have_text("602.75ms to 502.20ms")
    expect(page).to have_text("0.56 to 0.99")
    expect(page).to have_text("PageSpeed comparator pairs")
    expect(page).to have_text("PageSpeed Insights API returned HTTP 429")
    expect(page).to have_link("hosted review-app A/B summary")
    expect(page).to have_link("Lighthouse URL-pair summary")
    expect(page).to have_link("Product detail live URL", href: PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)

    expect(page).to have_link("Product detail mobile current-app PageSpeed")
    expect(page).to have_link("Product detail mobile deployed-demo PageSpeed")
    expect(page).to have_link("Product detail mobile live PageSpeed")
    expect(page).to have_text("Tendon Book by Jacked Athlete")
    expect(page).to have_link("Home", href: about_path)
    expect(page).to have_link("Back to home", href: about_path)
    expect(page).to have_link("Compare deployed demo", href: deployed_performance_url)
    expect(page).to have_link("Product Inertia", href: public_product_inertia_demo_path)
    expect(page).to have_link("Product RSC", href: public_product_rsc_demo_path)
    expect(page).to have_link("Discover Inertia", href: public_product_discover_inertia_demo_path)
    expect(page).to have_link("Discover RSC", href: public_product_discover_rsc_demo_path)
    expect(page).to have_link("Learn React on Rails", href: "https://reactonrails.com/")
    expect(page).to have_link("react_on_rails source", href: "https://github.com/shakacode/react_on_rails")
    expect(page).to have_link("Book a consultation", href: "https://meetings.hubspot.com/justingordon/30-minute-consultation")
    expect(page).to have_text("For Gumroad maintainers")
    expect(page).to have_text("For React on Rails evaluators")
    expect(page).to have_text("For ShakaCode prospects")
  end

  it "renders the product Inertia control while logged out" do
    visit public_product_inertia_demo_path

    expect(page).to have_current_path(public_product_inertia_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Tendon Book")
    expect(page).to have_text("Before: Inertia")
    expect(page).to have_text("Attributed live product fixture")
    expect(page).to have_text("Jacked Athlete")
    expect(page).to have_text("$47")
    expect(page).to have_link("Open live Gumroad source", href: PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)
    expect(page).to have_text("Recommended products")
    expect(page).to have_link("Open performance lab", href: public_product_performance_demo_path)
    expect(page).to have_link("Open RSC route", href: public_product_rsc_demo_path)
    expect(page).to have_link("Back to home", href: about_path)

    within("nav[aria-label='Public benchmark comparison routes']") do
      expect(page).to have_link("Home", href: about_path)
      expect(page).to have_link("Performance lab", href: public_product_performance_demo_path)
      expect(page).to have_link("Deployed demo", href: deployed_performance_url)
      expect(page).to have_link("Product Inertia", aria: { current: "page" })
      expect(page).to have_link("Product RSC", href: public_product_rsc_demo_path)
      expect(page).to have_link("Discover Inertia", href: public_product_discover_inertia_demo_path)
      expect(page).to have_link("Discover RSC", href: public_product_discover_rsc_demo_path)
      expect(page).to have_link("Live Product", href: PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)
      expect(page).to have_link("Live Discover", href: PublicProductRscDemoPresenter::GUMROAD_DISCOVER_REFERENCE_URL)
    end
  end

  it "renders the product RSC candidate while logged out" do
    visit public_product_rsc_demo_path

    expect(page).to have_current_path(public_product_rsc_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Tendon Book")
    expect(page).to have_text("After: React Server Components")
    expect(page).to have_text("Product story rendered before purchase intent")
    expect(page).to have_text("Jacked Athlete")
    expect(page).to have_text("$47")
    expect(page).to have_link("Open live Gumroad source", href: PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)
    expect(page).to have_link("Open performance lab", href: public_product_performance_demo_path)
    expect(page).to have_link("Open Inertia route", href: public_product_inertia_demo_path)
    expect(page).to have_link("Back to home", href: about_path)

    within("nav[aria-label='Public benchmark comparison routes']") do
      expect(page).to have_link("Product RSC", aria: { current: "page" })
      expect(page).to have_link("Product Inertia", href: public_product_inertia_demo_path)
    end
  end

  it "renders the Discover Inertia control while logged out" do
    visit public_product_discover_inertia_demo_path

    expect(page).to have_current_path(public_product_discover_inertia_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Discover creator-made products")
    expect(page).to have_text("Before: Inertia")
    expect(page).to have_text("Synthetic Discover listing")
    expect(page).to have_text("Marketplace categories")
    expect(page).to have_text("Product grid")
    expect(page).to have_text("Launch Metrics OS")
    expect(page).to have_link("Open RSC route", href: public_product_discover_rsc_demo_path)
    expect(page).to have_link("Back to home", href: about_path)

    within("nav[aria-label='Public benchmark comparison routes']") do
      expect(page).to have_link("Discover Inertia", aria: { current: "page" })
      expect(page).to have_link("Discover RSC", href: public_product_discover_rsc_demo_path)
    end
  end

  it "renders the Discover RSC candidate while logged out" do
    visit public_product_discover_rsc_demo_path

    expect(page).to have_current_path(public_product_discover_rsc_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Discover creator-made products")
    expect(page).to have_text("After: React Server Components")
    expect(page).to have_text("Featured collections")
    expect(page).to have_text("Product grid")
    expect(page).to have_text("Launch Metrics OS")
    expect(page).to have_link("Open Inertia route", href: public_product_discover_inertia_demo_path)
    expect(page).to have_link("Back to home", href: about_path)

    within("nav[aria-label='Public benchmark comparison routes']") do
      expect(page).to have_link("Discover RSC", aria: { current: "page" })
      expect(page).to have_link("Discover Inertia", href: public_product_discover_inertia_demo_path)
    end
  end
end
