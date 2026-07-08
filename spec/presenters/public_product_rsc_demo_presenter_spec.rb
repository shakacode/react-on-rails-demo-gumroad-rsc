# frozen_string_literal: true

require "spec_helper"

describe PublicProductRscDemoPresenter do
  subject(:presenter) { described_class.new(request: ActionDispatch::TestRequest.create) }

  describe "#hosted_benchmark_surfaces" do
    it "labels the product and discover surfaces from the historical hosted artifact" do
      surfaces = presenter.hosted_benchmark_surfaces

      expect(surfaces.map { |surface| surface[:surface] }).to include("Product detail", "Discover marketplace")
      expect(surfaces.map { |surface| surface[:page_kind] }).to include(:product, :discover)
    end
  end

  describe "#local_benchmark_surfaces" do
    it "labels the product and discover surfaces from the current branch artifact" do
      surfaces = presenter.local_benchmark_surfaces

      expect(surfaces.map { |surface| surface[:surface] }).to include("Product detail", "Discover marketplace")
      expect(surfaces.map { |surface| surface[:page_kind] }).to include(:product, :discover)
    end

    it "calls navigation duration a React on Rails Pro RSC win" do
      product = presenter.local_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      navigation = product[:rows].find { |row| row[:label] == "Navigation duration" }

      expect(navigation[:verdict]).to eq(:rsc_wins)
      expect(navigation[:inertia]).to eq("392.7 ms")
      expect(navigation[:rsc]).to eq("212.8 ms")
    end

    it "calls the larger RSC HTML transfer an Inertia win" do
      product = presenter.local_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      html_transfer = product[:rows].find { |row| row[:label] == "HTML transfer (over the wire)" }

      expect(html_transfer[:verdict]).to eq(:inertia_wins)
    end

    it "calls the Discover response-end gap a React on Rails Pro RSC win" do
      discover = presenter.local_benchmark_surfaces.find { |surface| surface[:page_kind] == :discover }
      response_end = discover[:rows].find { |row| row[:label] == "Response end (server TTLB)" }

      expect(response_end[:verdict]).to eq(:rsc_wins)
      expect(response_end[:delta]).to eq("-21.8%")
    end
  end

  it "keeps the historical hosted benchmark available for JavaScript transfer context" do
    product = presenter.hosted_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
    total = product[:rows].find { |row| row[:label] == "Total wire weight (HTML + JavaScript)" }
    payload = product[:rows].find { |row| row[:label] == "Serialized Inertia payload" }

    expect(total[:verdict]).to eq(:rsc_wins)
    expect(payload[:rsc]).to eq("None")
  end

  describe "#route_source_links" do
    it "returns deep links to the matched inertia and rsc route files" do
      links = presenter.route_source_links(:discover)

      expect(links[:inertia].map { |link| link[:label] }).to include("Controller", "Inertia page", "Fixtures")
      expect(links[:rsc].map { |link| link[:url] }).to include(a_string_ending_with("PublicDiscoverRscDemoPage.tsx"))
      expect(links[:rsc].map { |link| link[:url] })
        .to all(start_with("https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/"))
    end
  end

  describe "#react_stack_versions" do
    it "reports the React on Rails Pro and React 19 RSC package line used by the demo" do
      versions = presenter.react_stack_versions

      expect(versions[:react]).to eq("19.2.7")
      expect(versions[:react_dom]).to eq("19.2.7")
      expect(versions[:react_on_rails_pro_gem]).to eq("17.0.0.rc.7")
      expect(versions[:react_on_rails_pro_npm]).to eq("17.0.0-rc.7")
      expect(versions[:react_on_rails_rsc]).to eq("19.2.1-rc.0")
    end
  end

  describe "#product_props" do
    it "preserves the approved live product identity while keeping rewritten demo copy" do
      product = presenter.product_props.fetch(:product_page)

      expect(product.fetch(:name)).to eq("Tendon Book")
      expect(product.fetch(:seller).fetch(:name)).to eq("Jacked Athlete")
      expect(product.fetch(:native_type)).to eq("ebook")
      expect(product.fetch(:price_cents)).to eq(4700)
      expect(product.fetch(:ratings)).to include(average: 5.0, count: 10)
      expect(product.fetch(:ratings).fetch(:percentages)).to eq([100, 0, 0, 0, 0])
      expect(product.fetch(:source_url)).to eq("https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search")
      expect(product.fetch(:description_sections).first.fetch(:body)).to include("visible before hydration")
      expect(product.to_json).not_to include("Creator Analytics Playbook")
      expect(product.to_json).not_to include("Northstar Studio")
    end
  end

  describe "#page_speed_comparator_pairs" do
    it "returns reproducible PageSpeed comparator links for the live Gumroad surfaces" do
      pairs = presenter.page_speed_comparator_pairs

      product = pairs.find { |pair| pair[:surface] == "Product detail" }
      discover = pairs.find { |pair| pair[:surface] == "Discover marketplace" }

      expect(product[:demo_url]).to eq("http://test.host/public_product/rsc_demo")
      expect(product[:deployed_demo_url]).to eq("https://gumroad.reactonrails.com/public_product/rsc_demo")
      expect(product[:live_url]).to eq("https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search")
      expect(product[:mobile_demo_page_speed_url]).to include("pagespeed.web.dev")
      expect(product[:mobile_demo_page_speed_url]).to include("strategy=mobile")
      expect(product[:mobile_deployed_demo_page_speed_url]).to include(CGI.escape(product[:deployed_demo_url]))
      expect(product[:mobile_live_page_speed_url]).to include(CGI.escape(product[:live_url]))

      expect(discover[:demo_url]).to eq("http://test.host/public_product/discover_rsc_demo")
      expect(discover[:deployed_demo_url]).to eq("https://gumroad.reactonrails.com/public_product/discover_rsc_demo")
      expect(discover[:live_url]).to eq("https://gumroad.com/discover")
      expect(discover[:desktop_live_page_speed_url]).to include("strategy=desktop")
    end
  end

  describe "artifact links" do
    it "links the hosted review-app and Lighthouse comparator artifacts" do
      expect(presenter.hosted_review_benchmark_artifact_url).to include(
        "hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json"
      )
      expect(presenter.lighthouse_comparator_artifact_url).to include(
        "lighthouse-public-comparator-2026-07-08/summary.json"
      )
    end
  end

  describe "internal helper visibility" do
    it "keeps benchmark and package parsing helpers out of the public class API" do
      expect(described_class.private_methods).to include(:read_benchmark)
      expect(described_class.public_methods).not_to include(:package_json)
    end
  end
end
