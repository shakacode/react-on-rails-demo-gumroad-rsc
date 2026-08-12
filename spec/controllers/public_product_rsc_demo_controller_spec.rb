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
      expect(inertia.props.dig(:product_page, :name)).to eq("Tendon Book")
      expect(inertia.props.dig(:product_page, :seller, :name)).to eq("Jacked Athlete")
      expect(inertia.props.dig(:product_page, :source_url)).to eq(PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)
      expect(inertia.props.dig(:product_page, :cover_image_url)).to eq("/public-product-rsc-demo/media/tendon-book-cover.svg")
      expect(inertia.props.dig(:product_page, :recommendations).length).to eq(8)
      expect(inertia.props.dig(:product_page, :recommendations, 0, :thumbnail_image_url)).to eq("/public-product-rsc-demo/media/marketplace-analytics.svg")
      expect(inertia.props.dig(:comparison, :home_url)).to eq(about_path)
      expect(inertia.props.dig(:comparison, :deployed_performance_url))
        .to eq("#{PublicProductRscDemoPresenter::HOSTED_DEMO_BASE_URL}#{public_product_performance_demo_path}")
      expect(inertia.props.dig(:comparison, :product_inertia_url)).to eq(public_product_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :product_rsc_url)).to eq(public_product_rsc_demo_path)
      expect(inertia.props.dig(:comparison, :discover_inertia_url)).to eq(public_product_discover_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :discover_rsc_url)).to eq(public_product_discover_rsc_demo_path)
      expect(inertia.props.dig(:comparison, :gumroad_product_reference_url)).to eq(PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)
      expect(inertia.props.to_json).not_to include("seller.gumroad.reactonrails.com")
      expect(inertia.props.to_json).not_to include("/l/demo")
      expect(response.headers["Server-Timing"]).to include("action_total")
      expect(response.headers["Server-Timing"]).to include("compare_product")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end

    it "keeps the source-attributed product fixture in the serialized Inertia payload for benchmark measurement" do
      get :inertia_demo

      page_data = serialized_inertia_page_payload
      product_props = page_data.fetch("props").fetch("product_page")

      expect(product_props.fetch("name")).to eq("Tendon Book")
      expect(product_props.fetch("seller").fetch("name")).to eq("Jacked Athlete")
      expect(product_props.fetch("source_url")).to eq(PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL)
      expect(product_props.fetch("cover_image_url")).to eq("/public-product-rsc-demo/media/tendon-book-cover.svg")
      expect(product_props.fetch("description_sections").first.fetch("body")).to include("visible before hydration")
      expect(product_props.fetch("price_cents")).to eq(4700)
      expect(response.body).to include("Tendon Book")
      expect(response.body).to include("rel=\"canonical\"")
      expect(response.body).to include(public_product_inertia_demo_url)
    end
  end

  describe "GET lab_clean_inertia_demo" do
    it "renders the named product fixture without analytics or the legacy application JavaScript" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:once).and_call_original

      get :lab_clean_inertia_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(inertia).to render_component("PublicProduct/InertiaDemo")
      expect(inertia.props.dig(:benchmark_variant, :name)).to eq("lab-clean")
      expect(inertia.props.dig(:benchmark_variant, :fixture_identity))
        .to eq(PublicProductRscDemoPresenter::PRODUCT_FIXTURE_IDENTITY)
      expect(inertia.props.dig(:benchmark_variant, :analytics)).to eq("disabled")
      expect(inertia.props.dig(:benchmark_variant, :legacy_application_javascript)).to be(false)
      expect(inertia.props.dig(:comparison, :product_inertia_url)).to eq(public_product_lab_clean_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :product_rsc_url)).to eq(public_product_lab_clean_rsc_demo_path)
      expect(inertia.props.dig(:product_page, :name)).to eq("Tendon Book")
      expect(inertia_meta_property("gr:google_analytics:enabled")).to eq("false")
      expect(inertia_meta_property("gr:facebook_sdk:enabled")).to eq("false")
      expect(assigns(:skip_legacy_application_javascript)).to be(true)
      expect(assigns(:hide_layouts)).to be(false)
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_lab_clean_inertia_demo_url)
    end
  end

  describe "GET production_shaped_inertia_demo" do
    it "renders the named product fixture with the production analytics and legacy bundle path enabled" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:once).and_call_original

      get :production_shaped_inertia_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(inertia).to render_component("PublicProduct/InertiaDemo")
      expect(inertia.props.dig(:benchmark_variant, :name)).to eq("production-shaped")
      expect(inertia.props.dig(:benchmark_variant, :fixture_identity))
        .to eq(PublicProductRscDemoPresenter::PRODUCT_FIXTURE_IDENTITY)
      expect(inertia.props.dig(:benchmark_variant, :analytics)).to eq("enabled")
      expect(inertia.props.dig(:benchmark_variant, :legacy_application_javascript)).to be(true)
      expect(inertia.props.dig(:comparison, :product_inertia_url)).to eq(public_product_production_shaped_inertia_demo_path)
      expect(inertia.props.dig(:comparison, :product_rsc_url)).to eq(public_product_production_shaped_rsc_demo_path)
      expect(inertia_meta_property("gr:google_analytics:enabled")).to eq("true")
      expect(inertia_meta_property("gr:facebook_sdk:enabled")).to eq("true")
      expect(assigns(:skip_legacy_application_javascript)).to be_nil
      expect(assigns(:hide_layouts)).to be(false)
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_production_shaped_inertia_demo_url)
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
      expect(inertia.props.dig(:discover_page, :products, 0, :summary)).to include("preorders")
      expect(inertia.props.dig(:discover_page, :products, 0, :format_label)).to eq("Notion + Sheets")
      expect(inertia.props.dig(:discover_page, :products, 0, :audience_label)).to eq("Creator operators")
      expect(inertia.props.dig(:discover_page, :products, 0, :thumbnail_image_url)).to eq("/public-product-rsc-demo/media/marketplace-analytics.svg")
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
    it "renders the release boundary from the presenter stack versions" do
      presenter = PublicProductRscDemoPresenter.new(request:)
      allow(presenter).to receive(:react_stack_versions).and_return(
        react: "19.2.7",
        react_dom: "19.2.7",
        react_on_rails_pro_gem: "17.0.0.rc.dynamic",
        react_on_rails_pro_npm: "17.0.0-rc.dynamic",
        react_on_rails_rsc: "19.2.1-rc.dynamic"
      )
      allow(controller).to receive(:public_product_rsc_demo_presenter).and_return(presenter)

      get :performance_demo

      release_boundary = Nokogiri::HTML(response.body).css(".dd-row").find do |row|
        row.text.include?("Release boundary:")
      end

      expect(release_boundary).to be_present
      expect(release_boundary.css("code").map(&:text)).to include(
        "17.0.0.rc.dynamic",
        "17.0.0-rc.dynamic",
        "19.2.1-rc.dynamic"
      )
    end

    it "renders a logged-out public performance lab for product and Discover route pairs" do
      get :performance_demo

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(response.body).to include("Faster paint. Heavier payload.")
      expect(response.body).to include("VP Engineering summary")
      expect(response.body).to include("href=\"#{rsc_executive_summary_path}\"")
      expect(response.body).to include(public_product_inertia_demo_path)
      expect(response.body).to include(public_product_rsc_demo_path)
      expect(response.body).to include(public_product_discover_inertia_demo_path)
      expect(response.body).to include(public_product_discover_rsc_demo_path)
      expect(response.body).to include("Product detail A/B route pair")
      expect(response.body).to include("Discover marketplace A/B route pair")
      expect(response.body).to include("Stable media-bearing same-fixture Selenium A/B")
      expect(response.body).to include("Latest measured result")
      expect(response.body).to include("Paint is faster. Payload is heavier.")
      expect(response.body).to include("First paint")
      expect(response.body).to include("-76%")
      expect(response.body).to include("Largest paint")
      expect(response.body).to include("-74% / -49%")
      expect(response.body).to include("JS requests")
      expect(response.body).to include("41 → 3")
      expect(response.body).to include("Transferred bytes")
      expect(response.body).to include("+56% / +36%")
      expect(response.body).to include("http://localhost:3100/l/O365IT?layout=discover&amp;recommended_by=search")
      expect(response.body).to include("http://localhost:3200/l/bgfjk?layout=discover&amp;recommended_by=search&amp;rsc=1")
      expect(response.body).to include("FAILED: 2 perf regressions")
      expect(response.body).to include("Pilot signal, not an overall victory")
      expect(response.body).to include("RSC, server rendering, isolated bundles")
      expect(response.body).to include("stable media-bearing A/B summary")
      expect(response.body).to include("historical PR 69 review-app A/B summary")
      expect(response.body).to include("historical stable pre-media A/B summary")
      expect(response.body).to include("diagnostic Lighthouse URL-pair summary")
      expect(response.body).to include("Supporting legacy Selenium runs")
      expect(response.body).to match(/review-app validation measures the candidate build rather than stable/)
      expect(response.body).to include("1123.5 ms")
      expect(response.body).to include("not proof today")
      expect(response.body).to include("Known invalid comparison")
      expect(response.body).not_to include("0.57 to 0.98")
      expect(response.body).to include("Read this evidence in order")
      expect(response.body).to include("Actual ShakaPerf CLI A/B")
      expect(response.body).to include("PageSpeed against live Gumroad")
      expect(response.body).to include("Production parity + field data")
      expect(response.body).to include("Claim status")
      expect(response.body).to include("What current, deployed, and live mean here")
      expect(response.body).to include("Matched Inertia control")
      expect(response.body).to include("This host RSC demo")
      expect(response.body).to include("Stable deployed RSC demo")
      expect(response.body).to include("Live Gumroad reference")
      expect(response.body).to include("Stable deployed demo")
      expect(response.body).to include("Reproducibility artifacts and source")
      expect(response.body).to include("Open PageSpeed links")
      expect(response.body)
        .to include(CGI.escapeHTML("#{PublicProductRscDemoPresenter::HOSTED_DEMO_BASE_URL}#{public_product_performance_demo_path}"))
      expect(response.body).to include("Historical hosted run")
      expect(response.body).to include("React on Rails Pro 17 / React 19.2 audit")
      expect(response.body).to include("17.0.0")
      expect(response.body).to include("Available but unused")
      expect(response.body).to include("Causal limit")
      expect(response.body).to include("Stream timing attribution")
      expect(response.body).to include("-48.8%")
      expect(response.body).to include("-42.6%")
      expect(response.body).to include("PageSpeed comparator pairs")
      expect(response.body).to include("PageSpeed links visible for reproducibility")
      expect(response.body).not_to include("use hosted and PageSpeed reruns")
      expect(response.body).to include(CGI.escapeHTML(PublicProductRscDemoPresenter::GUMROAD_PRODUCT_REFERENCE_URL))
      expect(response.body).to include("live Gumroad")
      expect(response.body).to include("Tendon Book by Jacked Athlete")
      expect(response.body).to include("Fixture provenance")
      expect(response.body).to include("Local synthetic media files")
      expect(response.body).to include("Media parity gate")
      expect(response.body).to include("not database-seeded products")
      expect(response.body).to include("node scripts/perf/assert_public_demo_media_parity.mjs --base-url #{request.base_url}")
      expect(response.body).to include("The commands below target this host")
      expect(response.body).to include("initialHashTarget.scrollIntoView")
      expect(response.body).to include("--base-url #{request.base_url} --measure-base-url #{request.base_url}")
      expect(response.body).not_to include("--base-url https://gumroad.reactonrails.com --measure-base-url https://gumroad.reactonrails.com --path /public_product/inertia_demo")
      expect(response.body).to include("Serialized Inertia payload")
      expect(response.body).to include("React Server Components via React on Rails Pro, not Rspack")
      expect(response.body).not_to include("seller.gumroad.reactonrails.com")
      expect(response.body).not_to include("/l/demo")
      expect(assigns(:hide_layouts)).to be(true)
      expect(assigns(:skip_legacy_application_javascript)).to be(true)
    end
  end

  describe "GET executive_summary" do
    it "renders a short logged-out decision brief before the detailed evidence lab" do
      expect(rsc_executive_summary_path).to eq("/rsc-demo")
      expect(rsc_performance_demo_path).to eq("/rsc-demo/evidence")
      expect(public_product_performance_demo_path).to eq("/public_product/performance_demo")

      get :executive_summary

      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
      expect(response.body).to include("VP Engineering brief")
      expect(response.body).to include("Paints 49&ndash;76% faster. Ships 36&ndash;56% more.")
      expect(response.body).to include("FAILED: 2 perf regressions")
      expect(response.body).to include("-76%")
      expect(response.body).to include("-74% / -49%")
      expect(response.body).to include("-93%")
      expect(response.body).to include("+56% / +36%")
      expect(response.body).to include("Control 35")
      expect(response.body).to include("RSC 77")
      expect(response.body).to include("Rendered DOM → fewer requests → earlier paint")
      expect(response.body).to include("41 requests become 3")
      expect(response.body).to include("Why pilot")
      expect(response.body).to include("Why not rollout")
      expect(response.body).to include("This is an architecture result")
      expect(response.body).to include("What has to converge before rollout")
      expect(response.body).to include("Shrink hydration")
      expect(response.body).to include("Recover server time")
      expect(response.body).to include("Prove conversion")
      expect(response.body).to include("Implementation, rollback, and license boundary")
      expect(response.body).to include("one native product route streams through React on Rails Pro")
      expect(response.body).to include("remove <code>rsc=1</code>")
      expect(response.body).to include("#{rsc_performance_demo_path}#native-shakaperf-result")
      expect(response.body).not_to include("-48.8%")
      expect(response.body).not_to include("-42.6%")
      expect(response.body).not_to include("data-rerun-race")
      expect(assigns(:hide_layouts)).to be(true)
      expect(assigns(:skip_legacy_application_javascript)).to be(true)
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
        layout: "inertia",
        rsc_stream_observability: true
      )
      expect(assigns(:hide_layouts)).to be(true)
      expect(assigns(:skip_legacy_application_javascript)).to be(true)
      expect(assigns(:public_product_rsc_demo_props).dig(:page_kind)).to eq("product")
      expect(assigns(:public_product_rsc_demo_props).dig(:product_page, :name)).to eq("Tendon Book")
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

  describe "GET lab_clean_rsc_demo" do
    it "streams the same named fixture without analytics or the legacy application JavaScript" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).twice.and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:twice).and_call_original
      allow(controller).to receive(:stream_view_containing_react_components) do |**|
        controller.render plain: "streamed lab-clean public product rsc"
      end

      get :lab_clean_rsc_demo

      expect(response).to be_successful
      expect(controller).to have_received(:stream_view_containing_react_components).with(
        template: "public_product_rsc_demo/lab_clean_rsc_demo",
        layout: "inertia",
        rsc_stream_observability: true
      )
      expect(assigns(:public_product_rsc_demo_props).dig(:benchmark_variant, :name)).to eq("lab-clean")
      expect(assigns(:public_product_rsc_demo_props).dig(:benchmark_variant, :fixture_identity))
        .to eq(PublicProductRscDemoPresenter::PRODUCT_FIXTURE_IDENTITY)
      expect(assigns(:public_product_rsc_demo_props).dig(:comparison, :product_inertia_url))
        .to eq(public_product_lab_clean_inertia_demo_path)
      expect(assigns(:public_product_rsc_demo_props).dig(:comparison, :product_rsc_url))
        .to eq(public_product_lab_clean_rsc_demo_path)
      expect(assigns(:skip_legacy_application_javascript)).to be(true)
      expect(assigns(:hide_layouts)).to be(false)
      expect(controller_meta_property("gr:google_analytics:enabled")).to eq("false")
      expect(controller_meta_property("gr:facebook_sdk:enabled")).to eq("false")
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_lab_clean_rsc_demo_url)
    end
  end

  describe "GET production_shaped_rsc_demo" do
    it "streams the same named fixture with the production analytics and legacy bundle path enabled" do
      expect(ActiveRecord::Base.connection_handler).to receive(:clear_active_connections!).with(:all).twice.and_call_original
      expect(ActiveRecord::Base.connection_handler).to receive(:each_connection_pool).at_least(:twice).and_call_original
      allow(controller).to receive(:stream_view_containing_react_components) do |**|
        controller.render plain: "streamed production-shaped public product rsc"
      end

      get :production_shaped_rsc_demo

      expect(response).to be_successful
      expect(controller).to have_received(:stream_view_containing_react_components).with(
        template: "public_product_rsc_demo/production_shaped_rsc_demo",
        layout: "inertia",
        rsc_stream_observability: true
      )
      expect(assigns(:public_product_rsc_demo_props).dig(:benchmark_variant, :name)).to eq("production-shaped")
      expect(assigns(:public_product_rsc_demo_props).dig(:benchmark_variant, :fixture_identity))
        .to eq(PublicProductRscDemoPresenter::PRODUCT_FIXTURE_IDENTITY)
      expect(assigns(:public_product_rsc_demo_props).dig(:comparison, :product_inertia_url))
        .to eq(public_product_production_shaped_inertia_demo_path)
      expect(assigns(:public_product_rsc_demo_props).dig(:comparison, :product_rsc_url))
        .to eq(public_product_production_shaped_rsc_demo_path)
      expect(assigns(:skip_legacy_application_javascript)).to be_nil
      expect(assigns(:hide_layouts)).to be(false)
      expect(controller_meta_property("gr:google_analytics:enabled")).to eq("true")
      expect(controller_meta_property("gr:facebook_sdk:enabled")).to eq("true")
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_production_shaped_rsc_demo_url)
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
        layout: "inertia",
        rsc_stream_observability: true
      )
      expect(assigns(:hide_layouts)).to be(true)
      expect(assigns(:skip_legacy_application_javascript)).to be(true)
      expect(assigns(:public_discover_rsc_demo_props).dig(:page_kind)).to eq("discover")
      expect(assigns(:public_discover_rsc_demo_props).dig(:discover_page, :products).length).to eq(36)
      expect(assigns(:precomputed_rendering_context)).to include(:design_settings, :domain_settings, :user_agent_info)
      expect(controller.send(:meta_tags).fetch("canonical")[:href]).to eq(public_product_discover_rsc_demo_url)
      expect(controller.send(:meta_tags).fetch("meta-property-og-url")[:content]).to eq(public_product_discover_rsc_demo_url)
      expect(response.headers["Server-Timing"]).to include("compare_discover")
      expect(response.headers["Server-Timing"]).to include("render_dispatch")
    end
  end

  def inertia_meta_property(property)
    inertia.props.fetch(:_inertia_meta).find { |tag| tag[:property] == property }[:content]
  end

  def controller_meta_property(property)
    controller.send(:meta_tags).each_value.find { |tag| tag[:property] == property }[:content]
  end
end
