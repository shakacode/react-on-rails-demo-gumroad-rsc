# frozen_string_literal: true

require "spec_helper"

describe Subdomain do
  before do
    @seller1 = create(:user)
    @seller1.username = "test_user" # old style username
    @seller1.save(validate: false)

    @seller2 = create(:user, username: "testuser2") # new style username

    @seller3 = create(:user, username: nil)

    @root_domain_without_port = URI("#{PROTOCOL}://#{ROOT_DOMAIN}").host
  end

  describe "#find_seller_by_request" do
    def request_obj(username)
      username = username.tr("_", "-") # convert underscores to hyphens in usernames
      OpenStruct.new({ host: "#{username}.#{@root_domain_without_port}", subdomains: [username] })
    end

    it "does not match sellers with blank usernames" do
      root_domain_request = OpenStruct.new({ host: @root_domain_without_port, subdomains: [] })
      expect(Subdomain.find_seller_by_request(root_domain_request)).to eq nil
    end

    it "finds the sellers using request subdomain" do
      expect(Subdomain.find_seller_by_request(request_obj(@seller1.username))).to eq @seller1
      expect(Subdomain.find_seller_by_request(request_obj(@seller2.username))).to eq @seller2
      expect(Subdomain.find_seller_by_request(request_obj(@seller3.external_id))).to eq @seller3
    end

    context "when seller is marked as deleted" do
      before do
        @seller1.mark_deleted!
      end

      it "does not find the seller" do
        expect(Subdomain.find_seller_by_request(request_obj(@seller1.username))).to be_nil
      end
    end
  end

  describe "#find_seller_by_hostname" do
    def subdomain_url(username)
      [username.tr("_", "-"), @root_domain_without_port].join(".")
    end

    it "does not match sellers with blank usernames" do
      expect(Subdomain.find_seller_by_hostname(@root_domain_without_port)).to eq nil
    end

    it "finds the sellers using request subdomain" do
      expect(Subdomain.find_seller_by_hostname(subdomain_url(@seller1.username))).to eq @seller1
      expect(Subdomain.find_seller_by_hostname(subdomain_url(@seller2.username))).to eq @seller2
    end

    context "when seller is marked as deleted" do
      before do
        @seller1.mark_deleted!
      end

      it "does not find the seller" do
        expect(Subdomain.find_seller_by_hostname(subdomain_url(@seller1.username))).to be_nil
      end
    end
  end

  describe "#subdomain_request?" do
    it "returns true when it's a valid subdomain request" do
      domain = "test.#{@root_domain_without_port}"

      expect(Subdomain.send(:subdomain_request?, domain).present?).to eq(true)
    end

    it "returns false when hostname contains underscore" do
      domain = "test_123.#{@root_domain_without_port}"

      expect(Subdomain.send(:subdomain_request?, domain).present?).to eq(false)
    end

    it "returns false when hostname doesn't look like a subdomain request" do
      domain = "sample.example.com"

      expect(Subdomain.send(:subdomain_request?, domain).present?).to eq(false)
    end
  end

  describe "surface-specific creator hosts" do
    around do |example|
      original = ENV["GUMROAD_CREATOR_ROOT_DOMAIN"]
      ENV["GUMROAD_CREATOR_ROOT_DOMAIN"] = "legacy.gumroad.reactonrails.com"
      example.run
    ensure
      original.nil? ? ENV.delete("GUMROAD_CREATOR_ROOT_DOMAIN") : ENV["GUMROAD_CREATOR_ROOT_DOMAIN"] = original
    end

    it "resolves a seller directly on a configured rendering surface" do
      expect(described_class.from_username(@seller1.username))
        .to eq("test-user.legacy.gumroad.reactonrails.com")
      expect(described_class.find_seller_by_hostname("test-user.legacy.gumroad.reactonrails.com"))
        .to eq(@seller1)
    end
  end
end
