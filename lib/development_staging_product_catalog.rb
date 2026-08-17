# frozen_string_literal: true

require "digest"
require "yaml"

module DevelopmentStagingProductCatalog
  CATALOG_PATH = Rails.root.join("config/development_staging_products.yml")
  OWNER_KEY = "development_staging_seed_owner"
  OWNER = "canonical-product-catalog-v1"
  PERMALINK_KEY = "development_staging_seed_permalink"
  SELLER_EMAIL_KEY = "development_staging_seed_seller_email"
  OFFER_NAME_PREFIX = "development-staging-seed:"
  DESCRIPTION = "Description for demo product"
  SEED_TIME = Time.utc(2026, 8, 12, 12).freeze
  BOOTSTRAP_PASSWORD = "development-staging-seed-bootstrap-2026"

  Product = Struct.new(
    :name,
    :category,
    :taxonomy_slug,
    :seller_email,
    :seller_username,
    :price_cents,
    :permalink,
    :legacy_path,
    :next_path,
    keyword_init: true,
  )

  class OwnershipConflict < StandardError; end

  class << self
    def products
      @products ||= raw_catalog.fetch("products").map do |attributes|
        Product.new(**attributes.transform_keys(&:to_sym)).freeze
      end.freeze
    end

    def taxonomy_products
      products.reject { _1.taxonomy_slug.nil? }
    end

    def fetch(category:)
      products.find { _1.category == category } ||
        raise(KeyError, "Unknown development/staging product category #{category.inspect}")
    end

    def surfaces
      raw_catalog.fetch("surfaces").freeze
    end

    def seller_external_id(entry)
      digest = Digest::SHA256.hexdigest("#{OWNER}:#{entry.seller_email}").to_i(16)
      (1_000_000_000_000 + (digest % 9_000_000_000_000)).to_s
    end

    def reconcile_seller!(entry:)
      seller = User.find_by(email: entry.seller_email)
      if seller
        unless owned_seller?(seller, entry) || recognizable_legacy_seller?(seller, entry)
          raise OwnershipConflict,
                "Catalog seller #{entry.seller_email.inspect} is unrelated; refusing to overwrite it"
        end
      else
        seller = User.new(email: entry.seller_email)
        seller.password = BOOTSTRAP_PASSWORD
      end

      username_owner = User.where(username: entry.seller_username).where.not(id: seller.id).first
      if username_owner
        raise OwnershipConflict,
              "Catalog seller username #{entry.seller_username.inspect} belongs to an unrelated user"
      end

      seller.assign_attributes(
        email: entry.seller_email,
        external_id: seller_external_id(entry),
        name: seller_name(entry),
        username: entry.seller_username,
        confirmed_at: SEED_TIME,
        user_risk_state: "compliant",
        json_data: seller.json_data.merge(
          OWNER_KEY => OWNER,
          SELLER_EMAIL_KEY => entry.seller_email,
        ),
      )
      if entry.taxonomy_slug
        seller.payment_address = entry.seller_email
      else
        seller.is_team_member = true
        seller.created_at ||= SEED_TIME - 2.months
      end
      seller.save!

      if seller.previously_new_record?
        seller.password = "password"
        seller.save!(validate: false)
      end
      seller
    end

    def reconcile_product!(seller:, entry:)
      unless seller.email == entry.seller_email
        raise OwnershipConflict,
              "Cannot seed #{entry.permalink.inspect}: expected seller #{entry.seller_email.inspect}, got #{seller.email.inspect}"
      end

      seller_products = seller.links.to_a
      owned_products = seller_products.select { owned_product?(_1, entry) }
      if owned_products.size > 1
        raise OwnershipConflict, "Multiple products claim catalog ownership for #{entry.permalink.inspect}"
      end

      permalink_product = Link.find_by(unique_permalink: entry.permalink)
      named_products = seller_products.select { _1.name == entry.name }
      product = owned_products.first

      if product
        conflicting_named_products = named_products.reject { _1.id == product.id }
        if conflicting_named_products.any?
          raise OwnershipConflict,
                "Product identity #{entry.name.inspect} for #{entry.seller_email.inspect} conflicts with unrelated records"
        end
      else
        legacy_products = named_products.select { legacy_seed_signature?(_1, entry) }
        if legacy_products.size > 1 || named_products.any? { !legacy_products.include?(_1) }
          raise OwnershipConflict,
                "Product identity #{entry.name.inspect} for #{entry.seller_email.inspect} conflicts with unrelated or duplicate records"
        end
        product = legacy_products.first
      end

      if permalink_product && product && permalink_product.id != product.id
        raise OwnershipConflict,
              "Permalink #{entry.permalink.inspect} and product identity #{entry.name.inspect} belong to different records"
      end
      if permalink_product && product.nil?
        raise OwnershipConflict,
              "Permalink #{entry.permalink.inspect} already belongs to an unrelated product; refusing to overwrite it"
      end

      product ||= seller.links.build

      product.assign_attributes(
        name: entry.name,
        description: DESCRIPTION,
        filetype: "link",
        price_cents: entry.price_cents,
        taxonomy: entry.taxonomy_slug && Taxonomy.find_by!(slug: entry.taxonomy_slug),
        display_product_reviews: entry.taxonomy_slug.present?,
        unique_permalink: entry.permalink,
        json_data: product.json_data.merge(
          OWNER_KEY => OWNER,
          PERMALINK_KEY => entry.permalink,
        ),
      )
      product.save!
      product.save_tags!(entry.taxonomy_slug ? [entry.taxonomy_slug.first(20)] : [])
      product
    end

    def reconcile_review_state!(seller:, product:, entry:, buyer:)
      offer_code = reconcile_offer_code!(seller:, entry:)
      purchases = product.sales.to_a
      owned_purchases = purchases.select { owned_purchase?(_1, entry) }
      raise OwnershipConflict, "Multiple purchases claim catalog ownership for #{entry.permalink.inspect}" if owned_purchases.size > 1

      purchase = owned_purchases.first
      unless purchase
        legacy_purchases = purchases.select { legacy_seed_purchase?(_1, seller:, buyer:) }
        if legacy_purchases.size > 1
          raise OwnershipConflict, "Ambiguous legacy purchase state for #{entry.permalink.inspect}"
        end
        purchase = legacy_purchases.first
      end

      purchase ||= Purchase.new(link_id: product.id)
      purchase.assign_attributes(
        seller_id: seller.id,
        price_cents: 0,
        displayed_price_cents: 0,
        tax_cents: 0,
        gumroad_tax_cents: 0,
        total_transaction_cents: 0,
        purchaser_id: buyer.id,
        email: buyer.email,
        card_country: "US",
        ip_address: "199.241.200.176",
        offer_code:,
        json_data: purchase.json_data.merge(
          OWNER_KEY => OWNER,
          PERMALINK_KEY => entry.permalink,
        ),
      )
      purchase.send(:calculate_fees)
      purchase.save!
      purchase.update!(purchase_state: "successful", succeeded_at: SEED_TIME)

      review = purchase.product_review
      if review
        review.update!(rating: 3, message: nil, deleted_at: nil)
      else
        purchase.post_review(rating: 3)
      end
      purchase
    end

    private
      def raw_catalog
        @raw_catalog ||= YAML.safe_load_file(CATALOG_PATH, aliases: false).freeze
      end

      def owned_seller?(seller, entry)
        seller.json_data[OWNER_KEY] == OWNER && seller.json_data[SELLER_EMAIL_KEY] == entry.seller_email
      end

      def recognizable_legacy_seller?(seller, entry)
        return false if seller.json_data.key?(OWNER_KEY) || seller.json_data.key?(SELLER_EMAIL_KEY)

        linked_catalog_product = seller.links.any? { owned_product?(_1, entry) }
        return true if linked_catalog_product

        seller.name == seller_name(entry) &&
          seller.username == entry.seller_username &&
          seller.user_risk_state == "compliant" &&
          (!entry.taxonomy_slug || seller.payment_address == entry.seller_email) &&
          seller.links.any? { _1.name == entry.name && legacy_seed_signature?(_1, entry) }
      end

      def seller_name(entry)
        entry.taxonomy_slug ? "Gumbo #{entry.category}" : "Seller"
      end

      def owned_product?(product, entry)
        product.json_data[OWNER_KEY] == OWNER && product.json_data[PERMALINK_KEY] == entry.permalink
      end

      def legacy_seed_signature?(product, entry)
        return false if product.json_data.key?(OWNER_KEY) || product.json_data.key?(PERMALINK_KEY)

        product.description == DESCRIPTION &&
          product.filetype == "link" &&
          product.price_cents == entry.price_cents &&
          product.taxonomy&.slug == entry.taxonomy_slug &&
          product.display_product_reviews? == entry.taxonomy_slug.present?
      end

      def reconcile_offer_code!(seller:, entry:)
        owner_name = "#{OFFER_NAME_PREFIX}#{entry.permalink}"
        stable_code = "seed_#{entry.permalink}"
        owned_codes = seller.offer_codes.where(name: owner_name).to_a
        raise OwnershipConflict, "Multiple offer codes claim catalog ownership for #{entry.permalink.inspect}" if owned_codes.size > 1

        coded_offer = seller.offer_codes.find_by(code: stable_code)
        offer_code = owned_codes.first
        if offer_code && coded_offer && offer_code.id != coded_offer.id
          raise OwnershipConflict, "Catalog offer-code identity conflicts for #{entry.permalink.inspect}"
        end
        if offer_code.nil? && coded_offer && !legacy_seed_offer_code?(coded_offer)
          raise OwnershipConflict, "Offer code #{stable_code.inspect} belongs to an unrelated record"
        end
        offer_code ||= coded_offer || seller.offer_codes.build
        offer_code.assign_attributes(
          name: owner_name,
          code: stable_code,
          universal: true,
          amount_percentage: 100,
          amount_cents: nil,
          deleted_at: nil,
          valid_at: nil,
          expires_at: nil,
        )
        offer_code.save!
        offer_code
      end

      def legacy_seed_offer_code?(offer_code)
        return false unless offer_code

        offer_code.name.nil? && offer_code.universal? && offer_code.amount_percentage == 100 && offer_code.amount_cents.nil?
      end

      def owned_purchase?(purchase, entry)
        purchase.json_data[OWNER_KEY] == OWNER && purchase.json_data[PERMALINK_KEY] == entry.permalink
      end

      def legacy_seed_purchase?(purchase, seller:, buyer:)
        return false if purchase.json_data.key?(OWNER_KEY) || purchase.json_data.key?(PERMALINK_KEY)

        purchase.seller_id == seller.id &&
          purchase.purchaser_id == buyer.id &&
          purchase.email == buyer.email &&
          purchase.price_cents.zero? &&
          purchase.displayed_price_cents.zero? &&
          purchase.tax_cents.zero? &&
          purchase.gumroad_tax_cents.zero? &&
          purchase.total_transaction_cents.zero? &&
          purchase.card_country == "US" &&
          purchase.ip_address == "199.241.200.176" &&
          purchase.purchase_state == "successful" &&
          purchase.succeeded_at.present? &&
          legacy_seed_offer_code?(purchase.offer_code) &&
          purchase.offer_code.code.match?(/\Aseed-#{seller.id}-[0-9a-f]{6}\z/) &&
          purchase.product_review&.rating == 3
      end
  end
end
