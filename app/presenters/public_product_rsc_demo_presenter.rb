# frozen_string_literal: true

class PublicProductRscDemoPresenter
  include Rails.application.routes.url_helpers
  include ProductsHelper

  attr_reader :product, :request, :pundit_user

  def initialize(product:, request:, pundit_user:)
    @product = product
    @request = request
    @pundit_user = pundit_user
  end

  def props
    presenter_props = ProductPresenter.new(product:, request:, pundit_user:).product_props(
      seller_custom_domain_url: nil
    )
    product_props = presenter_props.fetch(:product)

    {
      locale: I18n.locale.to_s,
      product: {
        name: product_props[:name],
        permalink: product_props[:permalink],
        seller: seller_props(product_props[:seller]),
        summary: product_props[:summary],
        description_html: product_props[:description_html],
        price_cents: product_props[:price_cents],
        currency_code: product_props[:currency_code],
        ratings: product_props[:ratings],
        attributes: product_props[:attributes],
        public_files: public_file_props(product_props[:public_files]),
        long_url: product_props[:long_url],
        purchase_url: short_link_path(product),
      }.compact,
      comparison: {
        control_url: short_link_path(product),
        inertia_url: public_product_inertia_demo_path,
        rsc_url: public_product_rsc_demo_path,
      }
    }
  end

  private
    def seller_props(seller)
      return { name: product.user.name_or_username } if seller.blank?

      {
        name: seller[:name],
        profile_url: seller[:profile_url],
        avatar_url: seller[:avatar_url],
        is_verified: seller[:is_verified],
      }.compact
    end

    def public_file_props(public_files)
      Array(public_files).map do |public_file|
        public_file.slice(:name, :description, :extension, :filetype)
      end
    end
end
