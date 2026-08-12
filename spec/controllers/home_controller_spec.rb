# frozen_string_literal: true

require "spec_helper"

describe HomeController do
  render_views

  describe "GET about" do
    it "prioritizes the public buyer-page RSC performance experiment" do
      get :about

      expect(response).to be_successful
      expect(response.body).to include("React on Rails Pro performance experiment")
      expect(response.body).to include("Faster paint")
      expect(response.body).to include("actual ShakaPerf CLI")
      expect(response.body).to include("First contentful paint")
      expect(response.body).to include("-76%")
      expect(response.body).to include("Largest contentful paint")
      expect(response.body).to include("-74% / -49%")
      expect(response.body).to include("41 → 3")
      expect(response.body).to include("+56% / +36%")
      expect(response.body).to include("exits 1 with two test regressions")
      expect(response.body).not_to include("-48.8%")
      expect(response.body).not_to include("-42.6%")
      expect(response.body).to include("Current ShakaPerf results")
      expect(response.body).to include("Fixture provenance")
      expect(response.body).to include("React on Rails")
      expect(response.body).to include("https://reactonrails.com/")
      expect(response.body).to include("https://www.shakacode.com/")
      expect(response.body).to include("Read the VP Engineering summary")
      expect(response.body).to include("href=\"#{rsc_executive_summary_path}\"")
      expect(response.body).to include("href=\"#{rsc_performance_demo_path}#native-shakaperf-result\"")
      expect(response.body).to include("href=\"#{rsc_performance_demo_path}#fixture-provenance\"")
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
