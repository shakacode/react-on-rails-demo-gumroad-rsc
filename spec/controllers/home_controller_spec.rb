# frozen_string_literal: true

require "spec_helper"

describe HomeController do
  render_views

  describe "GET about" do
    it "prioritizes the public buyer-page RSC performance experiment" do
      get :about

      expect(response).to be_successful
      expect(response.body).to include("React on Rails Pro performance experiment")
      expect(response.body).to include("Consumer-facing pages are the value proof")
      expect(response.body).to include("current same-fixture ShakaPerf run")
      expect(response.body).to include("Product detail result")
      expect(response.body).to include("-45.8%")
      expect(response.body).to include("Discover result")
      expect(response.body).to include("-19.1%")
      expect(response.body).to include("Product: Inertia")
      expect(response.body).to include("Product: RSC")
      expect(response.body).to include("Discover: Inertia")
      expect(response.body).to include("Discover: RSC")
      expect(response.body).to include("7 -> 1")
      expect(response.body).to include("Current ShakaPerf results")
      expect(response.body).to include("Fixture provenance")
      expect(response.body).to include("React on Rails")
      expect(response.body).to include("Book a ShakaCode consultation")
      expect(response.body).to include("https://reactonrails.com/")
      expect(response.body).to include("https://www.shakacode.com/")
      expect(response.body).to include("https://meetings.hubspot.com/justingordon/30-minute-consultation")
      expect(response.body).to include(rsc_performance_demo_path)
      expect(response.body).to include(public_product_inertia_demo_path)
      expect(response.body).to include(public_product_rsc_demo_path)
      expect(response.body).to include(public_product_discover_inertia_demo_path)
      expect(response.body).to include(public_product_discover_rsc_demo_path)
      expect(response.body).to include("docs/performance-evaluation.md")
      expect(response.body).to include("https://github.com/shakacode/react-on-rails-demo-gumroad-rsc")
    end
  end

  describe "GET features_md" do
    it "returns markdown with the feature list" do
      get :features_md

      expect(response).to be_successful
      expect(response.content_type).to include("text/markdown")
      expect(response.body).to include("# Gumroad features")
      expect(response.body).to include("Digital products")
      expect(response.body).to include("Memberships")
      expect(response.body).to include("REST API")
    end
  end

  describe "GET small_bets" do
    it "renders successfully" do
      get :small_bets

      expect(response).to be_successful
      expect(controller.send(:page_title)).to eq("Small Bets by Gumroad")
      expect(assigns(:hide_layouts)).to be(true)
    end
  end
end
