# frozen_string_literal: true

require "spec_helper"
require "inertia_rails/rspec"

describe PublicProductRscDemoController, type: :controller, inertia: true do
  render_views

  describe "GET inertia_demo" do
    it "renders the production-shaped public product Inertia control without requiring login" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:once).and_call_original

      get :inertia_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(inertia).to render_component("PublicProduct/InertiaDemo")
      expect(inertia.props[:page_kind]).to eq("product")
      expect(inertia.props.dig(:product_page, :name)).to eq("Creator Analytics Playbook")
      expect(inertia.props.dig(:product_page, :seller, :name)).to eq("Northstar Studio")
      expect(inertia.props.dig(:product_page, :recommendations).length).to eq(8)
      expect(inertia.props.dig(:comparison, :home_url)).to eq(root_path)
      expect(inertia.props.dig(:comparison, :product_inertia_url)).to eq(public_product_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :product_rsc_url)).to eq(public_product_rsc_demo_path)
      expect(inertia.props.dig(:comparison, :discover_inertia_url)).to eq(public_product_discover_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :discover_rsc_url)).to eq(public_product_discover_rsc_demo_path)
      expect(inertia.props.to_json).not_to include("seller.gumroad.reactonrails.com")
      expect(inertia.props.to_json).not_to include("/l/demo")
      expect(response.headers["Server-Timing"]).to include("action_total")
      expect(response.headers["Server-Timing"]).to include("compare_product")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end

    it "keeps synthetic product content in the serialized Inertia payload for benchmark measurement" do
      get :inertia_demo

      data_page_match = response.body.match(/data-page="([^"]*)"/)
      expect(data_page_match).to be_present

      page_data = JSON.parse(CGI.unescapeHTML(data_page_match[1]))
      product_props = page_data.fetch("props").fetch("product_page")

      expect(product_props.fetch("name")).to eq("Creator Analytics Playbook")
      expect(product_props.fetch("seller").fetch("name")).to eq("Northstar Studio")
      expect(product_props.fetch("description_sections").first.fetch("body")).to include("visible before hydration")
      expect(product_props.fetch("price_cents")).to eq(3900)
      expect(response.body).to include("Creator Analytics Playbook")
      expect(response.body).to include("rel=\"canonical\"")
      expect(response.body).to include(public_product_inertia_demo_url)
    end
  end

  describe "GET discover_inertia_demo" do
    it "renders the production-shaped public Discover Inertia control without requiring login" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:once).and_call_original

      get :discover_inertia_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(inertia).to render_component("PublicProduct/DiscoverInertiaDemo")
      expect(inertia.props[:page_kind]).to eq("discover")
      expect(inertia.props.dig(:discover_page, :products).length).to eq(36)
      expect(inertia.props.dig(:discover_page, :categories).length).to eq(8)
      expect(inertia.props.dig(:discover_page, :tags_data).length).to eq(8)
      expect(inertia.props.dig(:comparison, :discover_inertia_url)).to eq(public_product_discover_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :discover_rsc_url)).to eq(public_product_discover_rsc_demo_path)
      expect(inertia.props.dig(:discover_page, :products).pluck(:permalink)).to all(be_present)
      expect(inertia.props.dig(:discover_page, :products).to_json).not_to include("gumroad.com")
      expect(response.headers["Server-Timing"]).to include("compare_discover")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end
  end

  describe "GET performance_demo" do
    it "renders a logged-out public performance lab for product and Discover route pairs" do
      get :performance_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(response.body).to include("Gumroad RSC performance lab")
      expect(response.body).to include(public_product_inertia_demo_path)
      expect(response.body).to include(public_product_rsc_demo_path)
      expect(response.body).to include(public_product_discover_inertia_demo_path)
      expect(response.body).to include(public_product_discover_rsc_demo_path)
      expect(response.body).to include("Product detail A/B route pair")
      expect(response.body).to include("Discover marketplace A/B route pair")
      expect(response.body).to include("Hosted headless Chrome A/B result")
      expect(response.body).to include("-66.5%")
      expect(response.body).to include("-64.4%")
      expect(response.body).to include("Fixture provenance")
      expect(response.body).to include("Serialized Inertia payload")
      expect(response.body).to include("React Server Components via React on Rails Pro, not Rspack")
      expect(response.body).not_to include("seller.gumroad.reactonrails.com")
      expect(response.body).not_to include("/l/demo")
      expect(assigns(:hide_layouts)).to be(true)
    end
  end

  describe "GET rsc_demo" do
    it "streams the public product RSC route without requiring login" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).twice.and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:twice).and_call_original
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
      expect(assigns(:public_product_rsc_demo_props).dig(:page_kind)).to eq("product")
      expect(assigns(:public_product_rsc_demo_props).dig(:product_page, :name)).to eq("Creator Analytics Playbook")
      expect(assigns(:precomputed_rendering_context)).to include(:design_settings, :domain_settings, :user_agent_info)
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_rsc_demo_url)
      expect(controller.send(:meta_tags).fetch("meta-property-og-url")[:content]).to eq(public_product_rsc_demo_url)
      expect(controller.send(:meta_tags)).not_to have_key("structured-data")
      expect(response.headers["Last-Modified"]).to be_present
      expect(response.headers["X-Accel-Buffering"]).to eq("no")
      expect(response.headers["Server-Timing"]).to include("compare_product")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end
  end

  describe "GET discover_rsc_demo" do
    it "streams the public Discover RSC route without requiring login" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).twice.and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:twice).and_call_original
      allow(controller).to receive(:stream_view_containing_react_components) do |**|
        controller.render plain: "streamed public discover rsc"
      end

      get :discover_rsc_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(controller).to have_received(:stream_view_containing_react_components).with(
        template: "public_product_rsc_demo/discover_rsc_demo",
        layout: "inertia"
      )
      expect(assigns(:hide_layouts)).to be(true)
      expect(assigns(:public_discover_rsc_demo_props).dig(:page_kind)).to eq("discover")
      expect(assigns(:public_discover_rsc_demo_props).dig(:discover_page, :products).length).to eq(36)
      expect(assigns(:precomputed_rendering_context)).to include(:design_settings, :domain_settings, :user_agent_info)
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_discover_rsc_demo_url)
      expect(controller.send(:meta_tags).fetch("meta-property-og-url")[:content]).to eq(public_product_discover_rsc_demo_url)
      expect(response.headers["Server-Timing"]).to include("compare_discover")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end
  end
end
