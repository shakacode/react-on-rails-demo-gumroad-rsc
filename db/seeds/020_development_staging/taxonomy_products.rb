# frozen_string_literal: true

DISCOVER_DEMO_MEDIA_BASE_PATH = "/public-product-rsc-demo/media"
DISCOVER_DEMO_BUYER_COUNT = 10
DISCOVER_DEMO_FIXTURE_OWNER = "rsc-discover-demo"
DISCOVER_DEMO_FIXTURE_OWNER_KEY = "discover_demo_fixture_owner"
DISCOVER_DEMO_FIXTURE_VERSION = 1
DISCOVER_DEMO_FIXTURE_VERSION_KEY = "discover_demo_fixture_version"

def find_or_create_discover_demo_user(name:, username:, email:)
  user = User.find_by(email:)
  if user && user.json_data[DISCOVER_DEMO_FIXTURE_OWNER_KEY] != DISCOVER_DEMO_FIXTURE_OWNER
    raise "Refusing to overwrite non-fixture user with email #{email.inspect}"
  end

  user ||= User.new(email:)
  user.assign_attributes(
    name:,
    username:,
    user_risk_state: "compliant",
    confirmed_at: user.confirmed_at || Time.current,
    payment_address: email,
  )
  user.json_data[DISCOVER_DEMO_FIXTURE_OWNER_KEY] = DISCOVER_DEMO_FIXTURE_OWNER
  user.json_data[DISCOVER_DEMO_FIXTURE_VERSION_KEY] = DISCOVER_DEMO_FIXTURE_VERSION
  user.password = SecureRandom.hex(24) if user.new_record?
  user.save!
  user
end

def find_or_create_discover_demo_offer_code(seller)
  seller.offer_codes.universal.alive.find_by(amount_percentage: 100) ||
    OfferCode.create!(
      user: seller,
      universal: true,
      amount_percentage: 100,
      code: "discover-demo-#{seller.id}",
    )
end

def ensure_discover_demo_review(product:, seller:, buyer:, rating:)
  purchase = Purchase.find_or_initialize_by(link_id: product.id, purchaser_id: buyer.id)
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
      ip_address: "199.241.200.176",
      offer_code: find_or_create_discover_demo_offer_code(seller),
    )
    purchase.send(:calculate_fees)
    purchase.save!
  end
  unless purchase.purchase_state == "successful" && purchase.succeeded_at.present?
    purchase.update!(purchase_state: "successful", succeeded_at: purchase.succeeded_at || Time.current)
  end

  review = purchase.product_review
  review.present? ? review.update!(rating:) : purchase.post_review(rating:)
end

def discover_demo_native_type(card)
  type = card.fetch(:native_type)
  return Link::NATIVE_TYPE_COURSE if type.include?("course") || type.include?("video")
  return Link::NATIVE_TYPE_EBOOK if type.include?("ebook") || type.include?("guide")
  return Link::NATIVE_TYPE_AUDIOBOOK if type.include?("audio")

  Link::NATIVE_TYPE_DIGITAL
end

def discover_demo_permalink(card, index)
  letters = +""
  number = index
  loop do
    letters.prepend(("a".ord + (number % 26)).chr)
    number = (number / 26) - 1
    break if number.negative?
  end
  name = card.fetch(:name).parameterize(separator: "_").gsub(/[^a-z_]/, "")
  "discover_#{letters}_#{name}"
end

def find_or_initialize_discover_demo_product(seller:, permalink:)
  product = Link.find_by(unique_permalink: permalink)
  return seller.links.build(unique_permalink: permalink) unless product

  fixture_owned = product.user_id == seller.id &&
    product.json_data[DISCOVER_DEMO_FIXTURE_OWNER_KEY] == DISCOVER_DEMO_FIXTURE_OWNER
  unless fixture_owned
    raise "Refusing to overwrite non-fixture product with permalink #{permalink.inspect}"
  end

  product
end

buyers = DISCOVER_DEMO_BUYER_COUNT.times.map do |index|
  find_or_create_discover_demo_user(
    name: "Discover Demo Buyer #{index + 1}",
    username: "discoverbuyer#{index + 1}",
    email: "discover-demo-buyer-#{index + 1}@gumroad.com",
  )
end

PublicProductRscDemoPresenter::DISCOVER_PRODUCT_CARDS.each_with_index do |card, index|
  seller_name = card.fetch(:seller_name)
  seller_slug = seller_name.parameterize
  seller = find_or_create_discover_demo_user(
    name: seller_name,
    username: "d#{seller_slug.delete("-").first(19)}",
    email: "discover-#{seller_slug}@gumroad.com",
  )

  product = find_or_initialize_discover_demo_product(
    seller:,
    permalink: discover_demo_permalink(card, index),
  )
  product.assign_attributes(
    user: seller,
    name: card.fetch(:name),
    description: card.fetch(:summary),
    filetype: "link",
    native_type: discover_demo_native_type(card),
    price_cents: card.fetch(:price_cents),
    taxonomy: Taxonomy.find_by!(slug: card.fetch(:taxonomy)),
    display_product_reviews: true,
    draft: false,
    purchase_disabled_at: nil,
    deleted_at: nil,
  )
  product.json_data[DISCOVER_DEMO_FIXTURE_OWNER_KEY] = DISCOVER_DEMO_FIXTURE_OWNER
  product.json_data[DISCOVER_DEMO_FIXTURE_VERSION_KEY] = DISCOVER_DEMO_FIXTURE_VERSION
  product.save!
  product.save_tags!([
                       card.fetch(:format_label).downcase.first(20),
                       card.fetch(:audience_label).downcase.first(20),
                     ])

  media_file = PublicProductRscDemoPresenter::DISCOVER_MEDIA_FILES.fetch(
    index % PublicProductRscDemoPresenter::DISCOVER_MEDIA_FILES.length
  )
  thumbnail = Thumbnail.find_or_initialize_by(product:)
  thumbnail.assign_attributes(
    unsplash_url: "#{DISCOVER_DEMO_MEDIA_BASE_PATH}/#{media_file}",
    deleted_at: nil,
  )
  thumbnail.save!

  five_star_review_count = ((4.2 + ((index % 7) * 0.1) - 4) * DISCOVER_DEMO_BUYER_COUNT).round
  buyers.each_with_index do |buyer, buyer_index|
    ensure_discover_demo_review(
      product:,
      seller:,
      buyer:,
      rating: buyer_index < five_star_review_count ? 5 : 4,
    )
  end
end

product_index = Link.__elasticsearch__
begin
  product_index.create_index!
rescue Elasticsearch::Transport::Transport::Errors::BadRequest => error
  raise unless error.message.include?("resource_already_exists_exception") && product_index.index_exists?
end
Link.import
