# frozen_string_literal: true

require "spec_helper"

describe "Public product RSC demo routes", type: :system, js: true do
  it "renders a public performance lab that makes the product and Discover comparisons obvious" do
    visit public_product_performance_demo_path

    expect(page).to have_current_path(public_product_performance_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Gumroad RSC performance lab")
    expect(page).to have_text("Public buyer-page A/B report")
    expect(page).to have_text("Hosted ShakaPerf result")
    expect(page).to have_text("-66.5%")
    expect(page).to have_text("-64.4%")
    expect(page).to have_text("Product detail A/B route pair")
    expect(page).to have_text("Discover marketplace A/B route pair")
    expect(page).to have_text("First streamed bytes")
    expect(page).to have_text("Route script bytes")
    expect(page).to have_text("Serialized Inertia payload")
    expect(page).to have_link("Home", href: root_path)
    expect(page).to have_link("Back to home", href: root_path)
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
    expect(page).to have_selector("h1", text: "Creator Analytics Playbook")
    expect(page).to have_text("Before: Inertia")
    expect(page).to have_text("Synthetic public product detail")
    expect(page).to have_text("Northstar Studio")
    expect(page).to have_text("$39")
    expect(page).to have_text("Recommended products")
    expect(page).to have_link("Open performance lab", href: public_product_performance_demo_path)
    expect(page).to have_link("Open RSC route", href: public_product_rsc_demo_path)
    expect(page).to have_link("Back to home", href: root_path)
    expect(page).not_to have_link("Open current product page")

    within("nav[aria-label='Public benchmark comparison routes']") do
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Performance lab", href: public_product_performance_demo_path)
      expect(page).to have_link("Product Inertia", aria: { current: "page" })
      expect(page).to have_link("Product RSC", href: public_product_rsc_demo_path)
      expect(page).to have_link("Discover Inertia", href: public_product_discover_inertia_demo_path)
      expect(page).to have_link("Discover RSC", href: public_product_discover_rsc_demo_path)
    end
  end

  it "renders the product RSC candidate while logged out" do
    visit public_product_rsc_demo_path

    expect(page).to have_current_path(public_product_rsc_demo_path, ignore_query: true)
    expect(page).not_to have_current_path(login_path, ignore_query: true)
    expect(page).to have_selector("h1", text: "Creator Analytics Playbook")
    expect(page).to have_text("After: React Server Components")
    expect(page).to have_text("Product story rendered before purchase intent")
    expect(page).to have_text("Northstar Studio")
    expect(page).to have_text("$39")
    expect(page).to have_link("Open performance lab", href: public_product_performance_demo_path)
    expect(page).to have_link("Open Inertia route", href: public_product_inertia_demo_path)
    expect(page).to have_link("Back to home", href: root_path)

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
    expect(page).to have_link("Back to home", href: root_path)

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
    expect(page).to have_link("Back to home", href: root_path)

    within("nav[aria-label='Public benchmark comparison routes']") do
      expect(page).to have_link("Discover RSC", aria: { current: "page" })
      expect(page).to have_link("Discover Inertia", href: public_product_discover_inertia_demo_path)
    end
  end
end
