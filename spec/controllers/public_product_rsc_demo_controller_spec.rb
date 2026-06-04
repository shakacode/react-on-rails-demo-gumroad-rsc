# frozen_string_literal: true

require "spec_helper"
require "inertia_rails/rspec"

describe PublicProductRscDemoController, type: :controller, inertia: true do
  render_views

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

  describe "GET inertia_demo" do
    it "renders the matched public Inertia control without requiring login" do
      get :inertia_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(inertia).to render_component("PublicProduct/InertiaDemo")
      expect(inertia.props.dig(:product, :name)).to eq("Public RSC widget")
      expect(inertia.props.dig(:product, :seller, :name)).to eq("Public Creator")
      expect(inertia.props.dig(:product, :summary)).to eq("A concise public product summary.")
      expect(inertia.props.dig(:comparison, :control_url)).to eq(short_link_path(product))
      expect(response.headers["Server-Timing"]).to include("action_total")
      expect(response.headers["Server-Timing"]).to include("compare_product")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end

    it "keeps product content in the initial HTML payload for crawlers and no-JS checks" do
      get :inertia_demo

      data_page_match = response.body.match(/data-page="([^"]*)"/)
      expect(data_page_match).to be_present

      page_data = JSON.parse(CGI.unescapeHTML(data_page_match[1]))
      product_props = page_data.fetch("props").fetch("product")

      expect(product_props.fetch("name")).to eq("Public RSC widget")
      expect(product_props.fetch("seller").fetch("name")).to eq("Public Creator")
      expect(product_props.fetch("description_html")).to include("Buyer-facing product story")
      expect(product_props.fetch("price_cents")).to eq(1900)
      expect(response.body).to include("product:retailer_item_id")
      expect(response.body).to include("og:title")
      expect(response.body).to include("rel=\"canonical\"")
    end

    it "does not expose an unavailable demo product to logged-out visitors" do
      product.update!(draft: true)

      expect { get :inertia_demo }.to raise_error(ActionController::RoutingError, "Not Found")
    end
  end

  describe "GET rsc_demo" do
    it "streams the public RSC route without requiring login" do
      allow(controller).to receive(:stream_view_containing_react_components) do |**|
        controller.render plain: "streamed public product rsc"
      end

      get :rsc_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(controller).to have_received(:stream_view_containing_react_components).with(
        template: "public_product_rsc_demo/rsc_demo",
        layout: "inertia"
      )
      expect(assigns(:hide_layouts)).to be(true)
      expect(assigns(:public_product_rsc_demo_props).dig(:product, :name)).to eq("Public RSC widget")
      expect(assigns(:public_product_rsc_demo_props).dig(:comparison, :rsc_url)).to eq(public_product_rsc_demo_path)
      expect(response.headers["Server-Timing"]).to include("action_total")
      expect(response.headers["Server-Timing"]).to include("compare_product")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end
  end
end
