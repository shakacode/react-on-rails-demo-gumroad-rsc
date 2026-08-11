# frozen_string_literal: true

# Seed a realistic, database-backed creator storefront for local product-page
# development and ShakaPerf twin servers.
#
# Usage:
#   bin/rails runner scripts/seed_native_product_page.rb
#
# Product metadata and cover art are a stable snapshot of the public Office 365
# for IT Pros storefront. Buyer accounts and review messages are synthetic.
# See public/native-product-page-fixture/SOURCES.md for source URLs and hashes.

module NativeProductPageSeed
  OWNER = "native-product-page-benchmark"
  OWNER_KEY = "native_product_page_fixture_owner"
  VERSION = 2
  VERSION_KEY = "native_product_page_fixture_version"
  SELLER_EMAIL = "office365-it-pros-benchmark@example.com"
  BUYER_COUNT = 21
  MEDIA_BASE_PATH = "/native-product-page-fixture"

  PRODUCTS = [
    {
      unique_permalink: "OITPROS",
      permalink: "O365IT",
      name: "Microsoft 365 for IT Pros (2027 Edition). The Ultimate Guide to Managing Microsoft 365.",
      summary: "Four books: The main Microsoft 365 for IT Pros eBook and Automating Microsoft 365 with PowerShell, Microsoft Purview for IT Pros, and Power Platform for IT Pros. All books come in EPUB and PDF formats.",
      price_cents: 5995,
      pages: 1_000,
      cover: "microsoft-365.png",
      native_type: Link::NATIVE_TYPE_EBOOK,
      review_count: 21,
      tags: ["microsoft 365", "it administration"],
      description: <<~HTML,
        <h2>The ultimate guide to managing Microsoft 365</h2>
        <p>A continuously updated reference for tenant administrators, architects, and support teams. The bundle covers identity, Exchange Online, Teams, SharePoint Online, security, compliance, and practical automation.</p>
        <h3>What is included</h3>
        <ul>
          <li>The main Microsoft 365 for IT Pros ebook in PDF and EPUB formats</li>
          <li>Companion guides for PowerShell, Microsoft Purview, and Power Platform</li>
          <li>Monthly content updates throughout the edition</li>
          <li>More than 1,000 pages of operational guidance and examples</li>
        </ul>
        <p>Built for working IT professionals who need practical detail instead of marketing summaries.</p>
      HTML
    },
    {
      unique_permalink: "MPSAUTOMATION",
      permalink: "M365PS",
      name: "Automating Microsoft 365 with PowerShell (2027 Edition)",
      summary: "Practical PowerShell automation for Microsoft 365 administrators",
      price_cents: 1995,
      pages: 450,
      cover: "powershell.png",
      native_type: Link::NATIVE_TYPE_EBOOK,
      review_count: 0,
      tags: ["powershell", "automation"],
      description: <<~HTML,
        <h2>Turn repetitive administration into reliable automation</h2>
        <p>A hands-on guide to the Microsoft Graph PowerShell SDK, Exchange Online, Teams, SharePoint Online, and Entra ID. Examples focus on reporting, lifecycle management, resilient scripts, and secure unattended execution.</p>
        <p>The 2027 edition includes PDF and EPUB files with approximately 450 pages of tested patterns and explanations.</p>
      HTML
    },
    {
      unique_permalink: "MPURVIEW",
      permalink: "M365Purview",
      name: "Microsoft Purview for IT Pros (2027 Edition)",
      summary: "Deep technical insight into how the most important Microsoft Purview solutions work. Includes coverage of Data Lifecycle Management, Data Loss Prevention, Information Protection, and eDiscovery.",
      price_cents: 1295,
      pages: 310,
      cover: "purview.png",
      native_type: Link::NATIVE_TYPE_DIGITAL,
      review_count: 0,
      tags: ["microsoft purview", "compliance"],
      description: <<~HTML,
        <h2>Put Microsoft Purview into practice</h2>
        <p>Understand retention, sensitivity labels, eDiscovery, audit, data loss prevention, and insider risk from an administrator's perspective. Scenario-led chapters connect configuration choices to day-to-day governance work.</p>
        <p>Includes PDF and EPUB editions plus updates during the edition year.</p>
      HTML
    },
    {
      unique_permalink: "PowerPlatformITPros",
      permalink: "PowerPlatform",
      name: "Power Platform for IT Pros (2027 Edition)",
      summary: "Learn how to exploit the capabilities of Microsoft Power Platform to automate Microsoft 365 management",
      price_cents: 1295,
      pages: 280,
      cover: "power-platform.png",
      native_type: Link::NATIVE_TYPE_DIGITAL,
      review_count: 0,
      tags: ["power platform", "governance"],
      description: <<~HTML,
        <h2>Operate Power Platform with confidence</h2>
        <p>A concise field guide to environments, connectors, data policies, the Power Platform admin center, governance at scale, and the Center of Excellence starter kit.</p>
        <p>Written for Microsoft 365 teams responsible for balancing maker productivity with operational control.</p>
      HTML
    },
  ].freeze

  REVIEW_MESSAGES = [
    "Clear, practical, and unusually thorough. I keep it open while administering our tenant.",
    "The monthly-update approach makes this far more useful than a conventional technical book.",
    "Excellent operational detail and enough context to understand why each recommendation matters.",
    "Saved our team hours of research during a tenant rollout.",
    "The examples translate directly to real administration work.",
    "A dependable reference for both planning and troubleshooting.",
    "Dense in the best way: searchable, current, and grounded in experience.",
    "Useful for experienced admins without becoming inaccessible to newer team members.",
  ].freeze

  module_function

  def run!
    ActiveRecord::Base.transaction do
      seller = owned_user!(
        email: SELLER_EMAIL,
        name: "Office 365 for IT Pros",
        username: "o365itpros",
        bio: "Independent technical ebooks for Microsoft 365 administrators, written and continuously updated by experienced IT professionals.",
      )
      buyers = seed_buyers!
      products = PRODUCTS.map { |attributes| seed_product!(seller:, buyers:, attributes:) }

      puts "Seeded #{seller.name}: #{products.size} products and #{products.sum(&:reviews_count)} reviews."
      puts "Open http://localhost:3300/l/O365IT?layout=discover&recommended_by=search"
    end
  end

  def owned_user!(email:, name:, username:, bio: nil)
    user = User.find_by(email:)
    if user && user.json_data[OWNER_KEY] != OWNER
      raise "Refusing to overwrite non-fixture user with email #{email.inspect}"
    end

    user ||= User.new(email:)
    user.assign_attributes(
      name:,
      username:,
      bio:,
      user_risk_state: "compliant",
      confirmed_at: user.confirmed_at || Time.current,
      payment_address: email,
    )
    user.json_data[OWNER_KEY] = OWNER
    user.json_data[VERSION_KEY] = VERSION
    user.password = SecureRandom.hex(24) if user.new_record?
    user.save!
    user
  end

  def seed_buyers!
    BUYER_COUNT.times.map do |index|
      owned_user!(
        email: "native-product-buyer-#{index + 1}@example.com",
        name: "Benchmark Reader #{index + 1}",
        username: "benchmarkreader#{index + 1}",
      )
    end
  end

  def seed_product!(seller:, buyers:, attributes:)
    permalink = attributes.fetch(:permalink)
    unique_permalink = attributes.fetch(:unique_permalink)
    product = Link.find_by(unique_permalink:)
    product_by_general_permalink = Link.by_general_permalink(permalink).order(created_at: :asc, id: :asc).first
    if product && product_by_general_permalink && product.id != product_by_general_permalink.id
      raise "Refusing to claim permalink #{permalink.inspect} already used by product #{product_by_general_permalink.id}"
    end
    product ||= product_by_general_permalink
    if product && (product.user_id != seller.id || product.json_data[OWNER_KEY] != OWNER)
      raise "Refusing to overwrite non-fixture product with permalink #{permalink.inspect}"
    end

    product ||= seller.links.build(unique_permalink:)
    product.assign_attributes(
      user: seller,
      custom_permalink: permalink,
      name: attributes.fetch(:name),
      description: attributes.fetch(:description),
      filetype: "pdf",
      native_type: attributes.fetch(:native_type),
      price_cents: attributes.fetch(:price_cents),
      display_product_reviews: true,
      draft: false,
      purchase_disabled_at: nil,
      deleted_at: nil,
    )
    product.json_data[OWNER_KEY] = OWNER
    product.json_data[VERSION_KEY] = VERSION
    product.json_data["custom_summary"] = attributes.fetch(:summary)
    product.json_data["custom_attributes"] = [
      { "name" => "Pages", "value" => attributes.fetch(:pages).to_fs(:delimited) },
      { "name" => "Formats", "value" => "PDF and EPUB" },
      { "name" => "Edition", "value" => "2027" },
    ]
    product.save!
    product.save_tags!(attributes.fetch(:tags))

    thumbnail = Thumbnail.find_or_initialize_by(product:)
    thumbnail.update!(
      unsplash_url: "#{MEDIA_BASE_PATH}/#{attributes.fetch(:cover)}",
      deleted_at: nil,
    )

    preview_guid = "native-page-#{attributes.fetch(:unique_permalink).downcase}"
    preview = product.asset_previews.find_or_initialize_by(guid: preview_guid)
    preview.update!(
      unsplash_url: "#{MEDIA_BASE_PATH}/#{attributes.fetch(:cover)}",
      deleted_at: nil,
      position: 0,
    )

    buyers.first(attributes.fetch(:review_count)).each_with_index do |buyer, index|
      seed_review!(
        product:,
        seller:,
        buyer:,
        rating: 5,
        message: REVIEW_MESSAGES.fetch((index + PRODUCTS.index(attributes)) % REVIEW_MESSAGES.size),
      )
    end
    remove_surplus_reviews!(product:, buyers:, keep: attributes.fetch(:review_count))
    product.sync_review_stat

    product.reload
  end

  def remove_surplus_reviews!(product:, buyers:, keep:)
    surplus_buyer_ids = buyers.drop(keep).map(&:id)
    return if surplus_buyer_ids.empty?

    purchases = Purchase.where(link_id: product.id, purchaser_id: surplus_buyer_ids)
    ProductReview.where(purchase_id: purchases.select(:id)).delete_all
    purchases.delete_all
  end

  def seed_review!(product:, seller:, buyer:, rating:, message:)
    purchase = Purchase.find_or_initialize_by(link_id: product.id, purchaser_id: buyer.id)
    if purchase.persisted? && purchase.seller_id != seller.id
      raise "Refusing to overwrite non-fixture purchase #{purchase.id}"
    end

    unless purchase.persisted?
      purchase.assign_attributes(
        seller_id: seller.id,
        price_cents: 0,
        displayed_price_cents: 0,
        tax_cents: 0,
        gumroad_tax_cents: 0,
        total_transaction_cents: 0,
        email: buyer.email,
        card_country: "US",
        ip_address: "192.0.2.#{buyer.id % 200 + 1}",
        offer_code: fixture_offer_code!(seller),
      )
      purchase.send(:calculate_fees)
      purchase.save!
    end
    purchase.update!(purchase_state: "successful", succeeded_at: purchase.succeeded_at || Time.current)

    purchase.post_review(rating:, message:)
  end

  def fixture_offer_code!(seller)
    seller.offer_codes.universal.alive.find_by(code: "native-page-review") ||
      OfferCode.create!(
        user: seller,
        universal: true,
        amount_percentage: 100,
        code: "native-page-review",
      )
  end
end

NativeProductPageSeed.run!
