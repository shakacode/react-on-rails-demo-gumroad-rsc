# frozen_string_literal: true

require "spec_helper"

describe DiscoverDomainConstraint do
  describe ".matches?" do
    before do
      @original_branch_deployment = ENV["BRANCH_DEPLOYMENT"]
      stub_const("VALID_DISCOVER_REQUEST_HOST", "staging.gumroad.com")
    end

    after do
      ENV["BRANCH_DEPLOYMENT"] = @original_branch_deployment
    end

    it "returns true for the discover host" do
      request = double("request", host: "staging.gumroad.com", path: "/")

      expect(described_class.matches?(request)).to eq(true)
    end

    it "returns true for Control Plane branch deployment discover paths" do
      ENV["BRANCH_DEPLOYMENT"] = "true"
      request = double("request", host: "rails-d98bp9qhcc8be.cpln.app", path: "/discover")

      expect(described_class.matches?(request)).to eq(true)
    end

    it "returns true for Control Plane branch deployment taxonomy paths" do
      ENV["BRANCH_DEPLOYMENT"] = "true"
      request = double("request", host: "rails-d98bp9qhcc8be.cpln.app", path: "/3d")
      allow(DiscoverTaxonomyConstraint).to receive(:matches?).with(request).and_return(true)

      expect(described_class.matches?(request)).to eq(true)
    end

    it "returns false for the Control Plane branch root path" do
      ENV["BRANCH_DEPLOYMENT"] = "true"
      request = double("request", host: "rails-d98bp9qhcc8be.cpln.app", path: "/")

      expect(described_class.matches?(request)).to eq(false)
    end

    it "returns false for Control Plane hosts outside branch deployments" do
      ENV["BRANCH_DEPLOYMENT"] = nil
      request = double("request", host: "rails-d98bp9qhcc8be.cpln.app", path: "/discover")

      expect(described_class.matches?(request)).to eq(false)
    end
  end
end
