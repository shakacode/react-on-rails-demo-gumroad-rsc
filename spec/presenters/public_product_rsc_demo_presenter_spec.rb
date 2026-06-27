# frozen_string_literal: true

require "spec_helper"

describe PublicProductRscDemoPresenter do
  describe ".hosted_benchmark_report" do
    let(:report) { described_class.hosted_benchmark_report }

    def surface(name)
      report[:surfaces].find { |candidate| candidate[:name] == name }
    end

    def row(surface_name, key)
      surface(surface_name)[:rows].find { |candidate| candidate[:key] == key }
    end

    it "reads provenance from the committed summary.json" do
      provenance = report[:provenance]

      expect(provenance[:captured_at_utc_date]).to eq("2026-06-24")
      expect(provenance[:host]).to eq("https://gumroad.reactonrails.com")
      expect(provenance[:browser_summary]).to eq("chrome 149.0.7827.158 (headless desktop)")
      expect(provenance[:method_summary]).to include("8 alternating cycles")
    end

    it "names RSC the winner when the candidate is faster beyond the tie band" do
      nav = row("Product detail", "median_navigation_duration_ms")

      expect(nav[:inertia_display]).to eq("811.50ms")
      expect(nav[:rsc_display]).to eq("272.25ms")
      expect(nav[:delta_display]).to eq("-66.5%")
      expect(nav[:winner]).to eq(:rsc)
      expect(nav[:winner_label]).to eq("RSC wins")
    end

    it "names Inertia the winner where RSC transfers more HTML" do
      html = row("Product detail", "median_html_transfer_bytes")

      expect(html[:inertia_display]).to eq("5,702 B")
      expect(html[:rsc_display]).to eq("9,105 B")
      expect(html[:delta_display]).to eq("+59.7%")
      expect(html[:winner]).to eq(:inertia)
      expect(html[:winner_label]).to eq("Inertia wins")
    end

    it "treats a sub-2% responseEnd delta as a tie and a larger one as an Inertia win" do
      expect(row("Product detail", "median_response_end_ms")[:winner]).to eq(:tie)
      expect(row("Discover marketplace", "median_response_end_ms")[:winner]).to eq(:inertia)
    end

    it "reports the eliminated Inertia payload as an RSC win" do
      payload = row("Product detail", "inertia_data_page_bytes")

      expect(payload[:inertia_display]).to eq("12,183 B")
      expect(payload[:rsc_display]).to eq("none")
      expect(payload[:delta_display]).to eq("removed")
      expect(payload[:winner]).to eq(:rsc)
    end

    it "builds view-source deep links that track main for the hosted app" do
      links = surface("Product detail")[:source_links]
      urls = links.map { |link| link[:url] }

      expect(urls).to include(
        "https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/app/controllers/public_product_rsc_demo_controller.rb"
      )
      expect(urls).to all(start_with("https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/"))
      expect(links.map { |link| link[:label] }).to include("RSC server component", "Inertia control component")
    end

    it "groups each Inertia-winning metric with its React on Rails tracking issues" do
      groups = report[:inertia_win_groups]

      expect(groups.map { |group| group[:label] }).to include("Median HTML transfer", "Median responseEnd")

      html_group = groups.find { |group| group[:label] == "Median HTML transfer" }
      expect(html_group[:occurrences].map { |occurrence| occurrence[:surface] })
        .to contain_exactly("Product detail", "Discover marketplace")
      expect(html_group[:issues].map { |issue| issue[:number] }).to eq([4238])
      expect(html_group[:issues].first[:url]).to eq("https://github.com/shakacode/react_on_rails/issues/4238")

      response_end_group = groups.find { |group| group[:label] == "Median responseEnd" }
      expect(response_end_group[:occurrences].map { |occurrence| occurrence[:surface] }).to eq(["Discover marketplace"])
      expect(response_end_group[:issues].map { |issue| issue[:number] }).to eq([4239, 4240])
    end
  end
end
