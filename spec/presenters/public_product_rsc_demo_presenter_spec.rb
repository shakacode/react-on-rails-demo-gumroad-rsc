# frozen_string_literal: true

require "spec_helper"

describe PublicProductRscDemoPresenter do
  subject(:presenter) { described_class.new(request: ActionDispatch::TestRequest.create) }

  describe "#hosted_benchmark_surfaces" do
    it "labels the product and discover surfaces from the committed artifact" do
      surfaces = presenter.hosted_benchmark_surfaces

      expect(surfaces.map { |surface| surface[:surface] }).to include("Product detail", "Discover marketplace")
      expect(surfaces.map { |surface| surface[:page_kind] }).to include(:product, :discover)
    end

    it "calls navigation duration a React on Rails Pro RSC win" do
      product = presenter.hosted_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      navigation = product[:rows].find { |row| row[:label] == "Navigation duration" }

      expect(navigation[:verdict]).to eq(:rsc_wins)
      expect(navigation[:inertia]).to eq("811.5 ms")
      expect(navigation[:rsc]).to eq("272.25 ms")
    end

    it "calls the larger RSC HTML transfer an Inertia win" do
      product = presenter.hosted_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      html_transfer = product[:rows].find { |row| row[:label] == "HTML transfer (over the wire)" }

      expect(html_transfer[:verdict]).to eq(:inertia_wins)
    end

    it "treats a response-end gap inside the tie band as about the same" do
      discover = presenter.hosted_benchmark_surfaces.find { |surface| surface[:page_kind] == :discover }
      response_end = discover[:rows].find { |row| row[:label] == "Response end (server TTLB)" }

      expect(response_end[:verdict]).to eq(:tie)
    end

    it "adds a combined wire-weight row that favors React on Rails Pro RSC" do
      product = presenter.hosted_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      total = product[:rows].find { |row| row[:label] == "Total wire weight (HTML + JavaScript)" }

      expect(total[:verdict]).to eq(:rsc_wins)
    end

    it "renders a zero serialized payload as None" do
      product = presenter.hosted_benchmark_surfaces.find { |surface| surface[:page_kind] == :product }
      payload = product[:rows].find { |row| row[:label] == "Serialized Inertia payload" }

      expect(payload[:rsc]).to eq("None")
    end
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
end
