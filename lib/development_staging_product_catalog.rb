# frozen_string_literal: true

require "yaml"

module DevelopmentStagingProductCatalog
  CATALOG_PATH = Rails.root.join("config/development_staging_products.yml")
  OWNER_KEY = "development_staging_seed_owner"
  OWNER = "canonical-product-catalog-v1"
  PERMALINK_KEY = "development_staging_seed_permalink"
  DESCRIPTION = "Description for demo product"

  Product = Struct.new(
    :name,
    :category,
    :taxonomy_slug,
    :seller_email,
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

    def reconcile_product!(seller:, entry:)
      unless seller.email == entry.seller_email
        raise OwnershipConflict,
              "Cannot seed #{entry.permalink.inspect}: expected seller #{entry.seller_email.inspect}, got #{seller.email.inspect}"
      end

      permalink_product = Link.find_by(unique_permalink: entry.permalink)
      named_products = seller.links.where(name: entry.name).to_a

      if permalink_product && !recognizable_seed_product?(permalink_product, seller:, entry:)
        raise OwnershipConflict,
              "Permalink #{entry.permalink.inspect} already belongs to an unrelated product; refusing to overwrite it"
      end

      contains_unrelated_product = named_products.any? do |candidate|
        !recognizable_seed_product?(candidate, seller:, entry:)
      end
      if contains_unrelated_product || named_products.size > 1
        raise OwnershipConflict,
              "Product identity #{entry.name.inspect} for #{entry.seller_email.inspect} conflicts with unrelated or duplicate records"
      end

      product = permalink_product || named_products.first || seller.links.build(unique_permalink: entry.permalink)
      if permalink_product && named_products.first && permalink_product.id != named_products.first.id
        raise OwnershipConflict,
              "Permalink #{entry.permalink.inspect} and product identity #{entry.name.inspect} belong to different records"
      end

      product.assign_attributes(
        unique_permalink: entry.permalink,
        json_data: product.json_data.merge(
          OWNER_KEY => OWNER,
          PERMALINK_KEY => entry.permalink,
        ),
      )
      product.save! if product.persisted? && product.changed?
      product
    end

    private

    def raw_catalog
      @raw_catalog ||= YAML.safe_load_file(CATALOG_PATH, aliases: false).freeze
    end

    def recognizable_seed_product?(product, seller:, entry:)
      return false unless product.user_id == seller.id && product.name == entry.name

      owned = product.json_data[OWNER_KEY] == OWNER && product.json_data[PERMALINK_KEY] == entry.permalink
      owned || legacy_seed_signature?(product, entry)
    end

    def legacy_seed_signature?(product, entry)
      product.description == DESCRIPTION &&
        product.filetype == "link" &&
        product.price_cents == entry.price_cents &&
        product.taxonomy&.slug == entry.taxonomy_slug
    end
  end
end
