# frozen_string_literal: true

require "spec_helper"

describe HomeController do
  render_views

  describe "GET about" do
    it "keeps the independent landing content" do
      get :about

      expect(response).to be_successful
      expect(response.body).to include("Go from")
      expect(response.body).to include("0 to $1")
      expect(response.body).to include("Anyone can earn their first dollar online")
      expect(response.body).to include("Sell anything")
      expect(response.body).to include("Make your own road")
      expect(response.body).to include("Sell to anyone")
      expect(response.body).to include("Sell anywhere")
      expect(response.body).to include("The Gumroad Way")
      expect(response.body).to include("https://github.com/antiwork/gumroad")
      expect(response.body).not_to include("React on Rails Pro performance experiment")
      expect(response.body).not_to include("Current ShakaPerf results")
      expect(response.body).not_to include("https://github.com/shakacode/react-on-rails-demo-gumroad-rsc")
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
