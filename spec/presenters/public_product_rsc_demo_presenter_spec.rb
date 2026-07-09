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

  describe "#deployed_benchmark_surfaces" do
    it "labels the product and discover surfaces from the deployed artifact" do
      surfaces = presenter.deployed_benchmark_surfaces

      expect(surfaces.map { |surface| surface[:surface] }).to include("Product detail", "Discover marketplace")
      expect(surfaces.map { |surface| surface[:page_kind] }).to include(:product, :discover)
    end

    it "keeps the stable deployed pre-media run available as supporting evidence" do
      product = presenter.deployed_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      navigation = product[:rows].find { |row| row[:label] == "Navigation duration" }
      response_end = product[:rows].find { |row| row[:label] == "Response end (server TTLB)" }

      expect(navigation[:verdict]).to eq(:rsc_wins)
      expect(navigation[:inertia]).to eq("883.9 ms")
      expect(navigation[:rsc]).to eq("267.25 ms")
      expect(response_end[:verdict]).to eq(:tie)
    end

    it "keeps the deployed Discover response-end tradeoff visible" do
      discover = presenter.deployed_benchmark_surfaces.find { |surface| surface[:page_kind] == :discover }
      response_end = discover[:rows].find { |row| row[:label] == "Response end (server TTLB)" }

      expect(response_end[:verdict]).to eq(:inertia_wins)
      expect(response_end[:delta]).to eq("+20.6%")
    end

    it "surfaces deployed JavaScript transfer in the total wire weight row" do
      product = presenter.deployed_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      total = product[:rows].find { |row| row[:label] == "Total wire weight (HTML + JavaScript)" }

      expect(total[:inertia]).to eq("164.43 KB")
      expect(total[:rsc]).to eq("90.22 KB")
      expect(total[:verdict]).to eq(:rsc_wins)
    end
  end

  describe "#media_review_benchmark_surfaces" do
    it "uses the PR 69 media-bearing run as the current headline benchmark" do
      product = presenter.media_review_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      navigation = product[:rows].find { |row| row[:label] == "Navigation duration" }
      lcp = product[:rows].find { |row| row[:label] == "LCP start" }

      expect(navigation[:verdict]).to eq(:rsc_wins)
      expect(navigation[:inertia]).to eq("1292.15 ms")
      expect(navigation[:rsc]).to eq("731.7 ms")
      expect(lcp[:verdict]).to eq(:rsc_wins)
    end

    it "links PR-only benchmark artifacts to the PR branch outside the stable host" do
      expect(presenter.media_review_benchmark_artifact_url)
        .to start_with(PublicProductRscDemoPresenter::REPO_PR_SOURCE_BASE_URL)
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
      expect(product.fetch(:ratings).fetch(:percentages)).to eq([0, 0, 0, 0, 100])
      expect(product.fetch(:source_url)).to eq("https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search")
      expect(product.fetch(:cover_image_url)).to eq("/public-product-rsc-demo/media/tendon-book-cover.svg")
      expect(product.fetch(:description_sections).first.fetch(:body)).to include("visible before hydration")
      expect(product.fetch(:recommendations).map { |card| card.fetch(:thumbnail_image_url) }).to all(start_with("/public-product-rsc-demo/media/"))
      expect(product.to_json).not_to include("Creator Analytics Playbook")
      expect(product.to_json).not_to include("Northstar Studio")
    end
  end

  describe "#discover_props" do
    it "renders realistic production-shaped synthetic cards without Gumroad URLs" do
      discover = presenter.discover_props.fetch(:discover_page)
      first_product = discover.fetch(:products).first

      expect(discover.fetch(:products).length).to eq(36)
      expect(first_product).to include(
        name: "Launch Metrics OS",
        summary: include("preorders"),
        format_label: "Notion + Sheets",
        audience_label: "Creator operators"
      )
      expect(first_product.fetch(:seller).fetch(:name)).to eq("Metric Harbor")
      expect(first_product.fetch(:thumbnail_image_url)).to eq("/public-product-rsc-demo/media/marketplace-analytics.svg")
      expect(discover.to_json).not_to include("gumroad.com")
    end
  end

  describe "#comparison_terms" do
    it "defines the page vocabulary for demo, deployed, and live comparisons" do
      terms = presenter.comparison_terms

      expect(terms.map { |term| term[:label] }).to include(
        "Matched Inertia control",
        "This host RSC demo",
        "Stable deployed RSC demo",
        "Live Gumroad reference"
      )
      expect(terms.find { |term| term[:label] == "Matched Inertia control" }[:description])
        .to include("not live gumroad.com production")
    end
  end

  describe "#performance_evidence_cards" do
    it "summarizes same-host ShakaPerf and labels PageSpeed as diagnostic only" do
      cards = presenter.performance_evidence_cards

      expect(cards.map { |card| card[:label] }).to include(
        "Product navigation",
        "Discover navigation",
        "Diagnostic only"
      )
      expect(cards.map { |card| card[:label] }).not_to include("Product PageSpeed-style score", "Discover PageSpeed-style score")
      expect(cards.find { |card| card[:label] == "Product navigation" }).to include(
        value: "1292.15 ms -> 731.7 ms",
        delta: "-43.4%"
      )
      expect(cards.find { |card| card[:label] == "Diagnostic only" }).to include(
        value: "Needs media parity",
        delta: "Not evidence yet",
        tone: "warning"
      )
    end
  end

  describe "#shakaperf_reproduction_commands" do
    it "targets the current request host instead of the stable deployed host" do
      commands = presenter.shakaperf_reproduction_commands

      product = commands.find { |command| command[:label] == "Product detail pair" }
      discover = commands.find { |command| command[:label] == "Discover pair" }

      expect(product[:host]).to eq("http://test.host")
      expect(product[:command]).to include("--base-url http://test.host --measure-base-url http://test.host")
      expect(product[:command]).to include("--path /public_product/inertia_demo --path /public_product/rsc_demo")
      expect(product[:command]).to include("--cycles 8 --server-warmup-requests 2 --require-driver-match --timeout 90")
      expect(product[:command]).not_to include("https://gumroad.reactonrails.com")

      expect(discover[:command]).to include(
        "--path /public_product/discover_inertia_demo --path /public_product/discover_rsc_demo"
      )
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
    it "links the deployed, hosted review-app, and Lighthouse comparator artifacts" do
      expect(presenter.deployed_benchmark_artifact_url).to include(
        "deployed-public-buyer-pages-2026-07-08/summary.json"
      )
      expect(presenter.hosted_review_benchmark_artifact_url).to include(
        "hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json"
      )
      expect(presenter.lighthouse_comparator_artifact_url).to include(
        "lighthouse-public-comparator-deployed-2026-07-08/summary.json"
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
