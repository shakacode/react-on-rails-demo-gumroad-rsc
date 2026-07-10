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

    it "calls the larger RSC encoded HTML body an Inertia win" do
      product = presenter.local_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      html_transfer = product[:rows].find { |row| row[:label] == "HTML encoded body (headers excluded)" }

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

    it "uses the stable media-bearing run as the current headline evidence" do
      product = presenter.deployed_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      navigation = product[:rows].find { |row| row[:label] == "Navigation duration" }
      response_end = product[:rows].find { |row| row[:label] == "Response end (server TTLB)" }

      expect(navigation[:verdict]).to eq(:rsc_wins)
      expect(navigation[:inertia]).to eq("1123.5 ms")
      expect(navigation[:rsc]).to eq("575 ms")
      expect(response_end[:verdict]).to eq(:tie)
    end

    it "keeps the noisy deployed Discover response-end result within the tie band" do
      discover = presenter.deployed_benchmark_surfaces.find { |surface| surface[:page_kind] == :discover }
      response_end = discover[:rows].find { |row| row[:label] == "Response end (server TTLB)" }

      expect(response_end[:verdict]).to eq(:tie)
      expect(response_end[:delta]).to eq("+4%")
    end

    it "surfaces deployed JavaScript transfer in the total wire weight row" do
      product = presenter.deployed_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      total = product[:rows].find { |row| row[:label] == "Total wire weight (HTML + JavaScript)" }

      expect(total[:inertia]).to eq("165.16 KB")
      expect(total[:rsc]).to eq("91.62 KB")
      expect(total[:verdict]).to eq(:rsc_wins)
    end
  end

  describe "#media_review_benchmark_surfaces" do
    it "keeps the PR 69 media-bearing review-app run as historical evidence" do
      product = presenter.media_review_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      navigation = product[:rows].find { |row| row[:label] == "Navigation duration" }
      lcp = product[:rows].find { |row| row[:label] == "LCP start" }

      expect(navigation[:verdict]).to eq(:rsc_wins)
      expect(navigation[:inertia]).to eq("1292.15 ms")
      expect(navigation[:rsc]).to eq("731.7 ms")
      expect(lcp[:verdict]).to eq(:rsc_wins)
    end

    it "links the historical PR 69 artifact to the canonical main branch" do
      expect(presenter.media_review_benchmark_artifact_url)
        .to start_with(PublicProductRscDemoPresenter::REPO_SOURCE_BASE_URL)
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
        .to all(start_with("#{described_class::REPO_URL}/blob/"))
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

  describe "#discover_title" do
    it "uses a neutral equal-byte title for both benchmark arms" do
      expect(presenter.discover_title).to eq("Gumroad Discover A/B benchmark")
      expect(presenter.discover_title.bytesize).to eq("Gumroad Discover RSC benchmark".bytesize)
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
        value: "1123.5 ms -> 575 ms",
        delta: "-48.8%"
      )
      expect(cards.find { |card| card[:label] == "Diagnostic only" }).to include(
        value: "Needs controlled parity",
        delta: "Not evidence yet",
        tone: "warning"
      )
    end
  end

  describe "#executive_summary" do
    it "derives the decision metrics and HTML cost from the stable benchmark artifact" do
      summary = presenter.executive_summary

      expect(summary.dig(:product, :navigation_delta)).to eq("-48.8%")
      expect(summary.dig(:discover, :navigation_delta)).to eq("-42.6%")
      expect(summary.dig(:product, :total_wire_delta)).to eq("-44.5%")
      expect(summary.dig(:discover, :total_wire_delta)).to eq("-41%")
      expect(summary.dig(:product, :html_cost)).to eq("+5.04 KB (+80.4%)")
      expect(summary.dig(:discover, :html_cost)).to eq("+9.57 KB (+100.2%)")
      expect(summary.dig(:product, :response_end)).to eq("About the same (+0.9%)")
      expect(summary.dig(:discover, :response_end)).to eq("Inconclusive (+4%)")
    end


    it "formats an HTML reduction without a double sign" do
      expect(presenter.send(:format_signed_metric, -1024, :bytes)).to eq("-1 KB")
    end
  end

  describe "#performance_claim_status_cards" do
    it "keeps the valid claim, PageSpeed caveat, and next evidence gate explicit" do
      cards = presenter.performance_claim_status_cards

      expect(cards.map { |card| card[:title] }).to eq(
        [
          "Same-host ShakaPerf A/B",
          "PageSpeed against live Gumroad",
          "Rerun after Pro 17.0.0 final",
        ]
      )
      expect(cards.second).to include(tone: "warning")
      expect(cards.second[:body]).to include("not proof today")
      expect(cards.third[:body]).to include("Wait for the final React on Rails Pro 17 release")
      expect(cards.map { |card| card[:href] }).to include("#current-shakaperf-result", "#pagespeed-comparator-pairs", "#reproduce-with-shakaperf")
    end
  end

  describe "#shakaperf_reproduction_commands" do
    it "targets the current request host and reproduces both independent batches" do
      commands = presenter.shakaperf_reproduction_commands

      product = commands.find { |command| command[:label] == "Product detail pair, batch 1" }
      discover = commands.find { |command| command[:label] == "Discover pair, batch 1" }

      expect(commands.map { |command| command[:label] }).to eq(
        [
          "Product detail pair, batch 1",
          "Product detail pair, batch 2",
          "Discover pair, batch 1",
          "Discover pair, batch 2",
        ]
      )
      expect(product[:host]).to eq("http://test.host")
      expect(product[:command]).to include("--base-url http://test.host --measure-base-url http://test.host")
      expect(product[:command]).to include("--path /public_product/inertia_demo --path /public_product/rsc_demo")
      expect(product[:command]).to include("--label current-host-public-product-alternating-8-batch1")
      expect(product[:command]).to include("--cycles 8 --server-warmup-requests 2 --require-driver-match --timeout 90")
      expect(product[:command]).not_to include("https://gumroad.reactonrails.com")

      expect(discover[:command]).to include(
        "--path /public_product/discover_inertia_demo --path /public_product/discover_rsc_demo"
      )
      expect(commands.second[:command]).to include("--label current-host-public-product-alternating-8-batch2")
      expect(commands.fourth[:command]).to include("--label current-host-public-discover-alternating-8-batch2")
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
    it "links current evidence and implementation to the image commit instead of the Control Plane app name" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GITHUB_SHA").and_return(nil)
      allow(ENV).to receive(:[]).with("GIT_COMMIT").and_return("4b21dd4fc38655ef54c2a75825d86d809fadb08b")
      allow(ENV).to receive(:[]).with("REVISION").and_return("react-on-rails-demo-gumroad-rsc-review-pr-70")
      allow(ENV).to receive(:[]).with("BRANCH").and_return("react-on-rails-demo-gumroad-rsc-review-pr-70")

      review_source_base_url = "#{described_class::REPO_URL}/blob/4b21dd4fc38655ef54c2a75825d86d809fadb08b"

      expect(presenter.deployed_benchmark_artifact_url).to start_with(review_source_base_url)
      expect(presenter.route_source_links(:product).values.flatten.pluck(:url))
        .to all(start_with(review_source_base_url))
      expect(presenter.implementation_source_links.pluck(:url)).to all(start_with(review_source_base_url))
      expect(presenter.media_review_benchmark_artifact_url).to start_with(described_class::REPO_SOURCE_BASE_URL)
    end

    it "uses canonical main links when no deployed revision metadata is available" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GITHUB_SHA").and_return(nil)
      allow(ENV).to receive(:[]).with("GIT_COMMIT").and_return(nil)
      allow(ENV).to receive(:[]).with("SOURCE_REF").and_return(nil)
      allow(ENV).to receive(:[]).with("REVISION").and_return(nil)
      allow(ENV).to receive(:[]).with("BRANCH").and_return(nil)

      expect(presenter.deployed_benchmark_artifact_url).to start_with(described_class::REPO_SOURCE_BASE_URL)
      expect(presenter.route_source_links(:product).values.flatten.pluck(:url))
        .to all(start_with(described_class::REPO_SOURCE_BASE_URL))
    end

    it "links the deployed, hosted review-app, and Lighthouse comparator artifacts" do
      expect(presenter.deployed_benchmark_artifact_url).to include(
        "deployed-stable-media-public-buyer-pages-2026-07-10/summary.json"
      )
      expect(presenter.pre_media_deployed_benchmark_artifact_url).to include(
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
