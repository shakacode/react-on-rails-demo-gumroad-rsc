# frozen_string_literal: true

require "spec_helper"

describe GumroadDomainConstraint do
  describe ".matches?" do
    before do
      @gumroad_domain_request = double("request")
      allow(@gumroad_domain_request).to receive(:host).and_return("gumroad.com")

      @non_gumroad_domain_request = double("request")
      allow(@non_gumroad_domain_request).to receive(:host).and_return("api.gumroad.com")

      stub_const("VALID_REQUEST_HOSTS", ["gumroad.com"])
    end

    context "when requests come from Gumroad root domain" do
      it "returns true" do
        expect(described_class.matches?(@gumroad_domain_request)).to eq(true)
      end
    end

    context "when requests come from non-Gumroad root domain" do
      it "returns false" do
        expect(described_class.matches?(@non_gumroad_domain_request)).to eq(false)
      end
    end

    context "when requests come from a Control Plane Rails workload host" do
      before do
        @original_branch_deployment = ENV["BRANCH_DEPLOYMENT"]
        ENV["BRANCH_DEPLOYMENT"] = "true"
        allow(@non_gumroad_domain_request).to receive(:host).and_return("rails-d7fsgnq0evscp.cpln.app")
      end

      after do
        ENV["BRANCH_DEPLOYMENT"] = @original_branch_deployment
      end

      it "returns true for branch deployments" do
        expect(described_class.matches?(@non_gumroad_domain_request)).to eq(true)
      end
    end
  end
end
