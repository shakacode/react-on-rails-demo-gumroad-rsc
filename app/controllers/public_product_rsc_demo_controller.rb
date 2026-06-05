# frozen_string_literal: true

class PublicProductRscDemoController < ApplicationController
  include ReactOnRailsPro::Stream
  include DashboardComparisonTiming
  include PageMeta::Product

  PUBLIC_DEMO_SELLER_EMAIL = "seller@gumroad.com"

  before_action :set_public_demo_product
  before_action :prepare_public_product_page
  write_dashboard_comparison_server_timing_after_action only: %i[inertia_demo rsc_demo]
  helper_method :content_security_policy_nonce

  layout "inertia", only: :inertia_demo

  def inertia_demo
    with_dashboard_comparison_timing("action_total") do
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?

      with_dashboard_comparison_timing("render_dispatch") do
        render inertia: "PublicProduct/InertiaDemo", props: public_product_comparison_props
      end
    end
  end

  def rsc_demo
    with_dashboard_comparison_timing("action_total") do
      @hide_layouts = true
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?
      @public_product_rsc_demo_props = public_product_comparison_props

      with_dashboard_comparison_timing("render_dispatch") do
        stream_view_containing_react_components(
          template: "public_product_rsc_demo/rsc_demo",
          layout: "inertia"
        )
      end
    end
  end

  private
    def public_product_comparison_props
      with_dashboard_comparison_timing("compare_props") do
        with_dashboard_comparison_timing("compare_product") do
          PublicProductRscDemoPresenter.new(product: @product, request:, pundit_user:).props
        end
      end
    end

    def set_public_demo_product
      @product = public_demo_products.find_by(unique_permalink: "demo") || e404
    end

    def public_demo_products
      Link.alive.not_draft
        .joins(:user)
        .merge(User.alive)
        .where(users: { email: PUBLIC_DEMO_SELLER_EMAIL })
        .order(created_at: :asc, id: :asc)
    end

    def prepare_public_product_page
      set_meta_tag(title: @product.name)
      set_product_page_meta(@product)
      set_meta_tag(tag_name: "style", inner_content: @product.user.seller_profile.custom_styles.to_s, head_key: "custom_styles")
    end

    def content_security_policy_nonce(_directive = nil)
      SecureHeaders.content_security_policy_script_nonce(request)
    end
end
