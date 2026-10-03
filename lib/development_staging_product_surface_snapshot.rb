# frozen_string_literal: true

require "json"
require Rails.root.join("lib/development_staging_product_catalog")

module DevelopmentStagingProductSurfaceSnapshot
  class InvalidSnapshot < StandardError; end
  class SnapshotMismatch < StandardError; end

  VERSION = 1
  NON_RENDERED_SELLER_AUTH_ATTRIBUTES = %w[encrypted_password otp_secret_key].freeze

  class << self
    def generate
      products_by_permalink = Link
        .where(unique_permalink: DevelopmentStagingProductCatalog.products.map(&:permalink))
        .index_by(&:unique_permalink)

      snapshot = {
        snapshot_version: VERSION,
        seed_time: DevelopmentStagingProductCatalog::SEED_TIME.iso8601,
        products: DevelopmentStagingProductCatalog.products.map do |entry|
          product = products_by_permalink.fetch(entry.permalink) do
            raise InvalidSnapshot, "Missing canonical product #{entry.permalink.inspect}"
          end
          product_snapshot(product, entry)
        end,
      }

      canonicalize(snapshot).tap { validate!(_1) }
    end

    def write(path)
      File.write(path, "#{JSON.pretty_generate(generate)}\n")
    end

    def verify_equal!(left, right)
      left_snapshot = load_snapshot(left)
      right_snapshot = load_snapshot(right)
      validate!(left_snapshot)
      validate!(right_snapshot)
      return true if left_snapshot == right_snapshot

      path, left_value, right_value = first_difference(left_snapshot, right_snapshot)
      raise SnapshotMismatch,
            "Development/staging surface snapshots differ " \
            "(left=#{Digest::SHA256.hexdigest(JSON.generate(left_snapshot))}, " \
            "right=#{Digest::SHA256.hexdigest(JSON.generate(right_snapshot))}); " \
            "first difference at #{path}: #{left_value.inspect.first(160)} != #{right_value.inspect.first(160)}"
    end

    def validate!(snapshot)
      expected_permalinks = DevelopmentStagingProductCatalog.products.map(&:permalink)
      products = snapshot.fetch("products")
      actual_permalinks = products.map { _1.dig("catalog", "permalink") }
      unless snapshot["snapshot_version"] == VERSION && actual_permalinks == expected_permalinks
        raise InvalidSnapshot, "Snapshot does not contain the canonical #{expected_permalinks.size}-product catalog"
      end

      products.each do |item|
        permalink = item.dig("catalog", "permalink")
        page_product = item.dig("page_props", "product")
        required_values = {
          "presenter product external ID" => page_product&.dig("id"),
          "presenter seller external ID" => page_product&.dig("seller", "id"),
          "database product ID" => item.dig("state", "product", "id"),
          "database-derived product external ID" => item.dig("state", "product", "external_id"),
          "seller refund-policy state" => item.dig("state", "seller_refund_policy"),
        }
        missing = required_values.filter_map { |label, value| label if value.nil? }
        missing << "seller refund-policy props" unless page_product&.key?("refund_policy")
        raise InvalidSnapshot, "#{permalink}: missing #{missing.join(', ')}" if missing.any?
      end

      true
    rescue KeyError, TypeError => error
      raise InvalidSnapshot, "Malformed surface snapshot: #{error.message}"
    end

    private
      def product_snapshot(product, entry)
        seller = product.user
        request = ActionDispatch::TestRequest.create(
          "HTTP_HOST" => "#{seller.username}.#{ROOT_DOMAIN}",
          "REMOTE_ADDR" => "203.0.113.10",
        )
        page_props = ProductPresenter.new(
          product:,
          request:,
          pundit_user: SellerContext.logged_out,
        ).product_page_props(
          seller_custom_domain_url: nil,
          recommended_by: nil,
          discount_code: nil,
          quantity: 1,
          layout: nil,
        )

        purchases = Purchase.where(link_id: product.id).order(:id)
        {
          catalog: entry.to_h,
          page_props:,
          state: {
            product: attributes_with_external_id(product),
            taxonomy: product.taxonomy && {
              attributes: product.taxonomy.attributes,
              ancestor_slugs: product.taxonomy.self_and_ancestors.pluck(:slug).sort,
            },
            tags: product.tags.order(:id).map(&:attributes),
            seller: seller.attributes.except(*NON_RENDERED_SELLER_AUTH_ATTRIBUTES),
            seller_profile: seller.seller_profile.attributes,
            seller_refund_policy: refund_policy_snapshot(seller.refund_policy),
            product_refund_policy: product.product_refund_policy && refund_policy_snapshot(product.product_refund_policy),
            purchases: purchases.map { attributes_with_external_id(_1) },
            reviews: ProductReview.where(link_id: product.id).order(:id).map { attributes_with_external_id(_1) },
            offer_codes: seller.offer_codes.order(:id).map { attributes_with_external_id(_1) },
          },
        }
      end

      def attributes_with_external_id(record)
        record.attributes.merge("external_id" => record.external_id)
      end

      def refund_policy_snapshot(refund_policy)
        attributes_with_external_id(refund_policy).merge("presenter_props" => refund_policy.as_json)
      end

      def load_snapshot(value)
        parsed = value.is_a?(String) || value.is_a?(Pathname) ? JSON.parse(File.read(value)) : value
        canonicalize(parsed)
      end

      def canonicalize(value)
        case value
        when Hash
          value.to_h.transform_keys(&:to_s).sort.to_h.transform_values { canonicalize(_1) }
        when Array
          value.map { canonicalize(_1) }
        when Time, DateTime, ActiveSupport::TimeWithZone
          value.iso8601(6)
        when Date
          value.iso8601
        else
          value
        end
      end

      def first_difference(left, right, path = "$")
        if left.is_a?(Hash) && right.is_a?(Hash)
          (left.keys | right.keys).sort.each do |key|
            return ["#{path}.#{key}", left[key], right[key]] unless left.key?(key) && right.key?(key)

            difference = first_difference(left[key], right[key], "#{path}.#{key}")
            return difference if difference
          end
          nil
        elsif left.is_a?(Array) && right.is_a?(Array)
          return ["#{path}.length", left.length, right.length] unless left.length == right.length

          left.each_index do |index|
            difference = first_difference(left[index], right[index], "#{path}[#{index}]")
            return difference if difference
          end
          nil
        elsif left != right
          [path, left, right]
        end
      end
  end
end
