# frozen_string_literal: true

class PublicProductRscDemoController < ApplicationController
  include ReactOnRailsPro::Stream
  include LiveActiveRecordConnectionCleanup
  include LiveStreamingResponseHeaders
  include DashboardComparisonTiming

  before_action :prepare_public_product_page, only: %i[inertia_demo rsc_demo]
  before_action :prepare_public_discover_page, only: %i[discover_inertia_demo discover_rsc_demo]
  before_action :prepare_live_streaming_response, only: %i[rsc_demo discover_rsc_demo]
  prepend_around_action :clear_live_active_record_connections, only: %i[inertia_demo rsc_demo discover_inertia_demo discover_rsc_demo]
  write_dashboard_comparison_server_timing_after_action only: %i[inertia_demo rsc_demo discover_inertia_demo discover_rsc_demo]
  helper_method :content_security_policy_nonce

  layout "inertia", only: %i[inertia_demo discover_inertia_demo performance_demo]

  def inertia_demo
    with_dashboard_comparison_timing("action_total") do
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?

      with_dashboard_comparison_timing("render_dispatch") do
        render inertia: "PublicProduct/InertiaDemo", props: public_product_comparison_props
      end
    end
  end

  def discover_inertia_demo
    with_dashboard_comparison_timing("action_total") do
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?

      with_dashboard_comparison_timing("render_dispatch") do
        render inertia: "PublicProduct/DiscoverInertiaDemo", props: public_discover_comparison_props
      end
    end
  end

  def performance_demo
    @hide_layouts = true
    @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?

    set_meta_tag(title: "Gumroad RSC performance lab")
    set_meta_tag(
      name: "description",
      content: "A logged-out comparison lab for Gumroad's Inertia control and React Server Components via React on Rails Pro public product routes."
    )
  end

  def rsc_demo
    with_dashboard_comparison_timing("action_total") do
      @hide_layouts = true
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?
      @public_product_rsc_demo_props = public_product_comparison_props
      @precomputed_rendering_context = RenderingExtension.custom_context(view_context)
      # ActionController::Live can keep this action thread open after the response
      # reaches the client, so release DB connections before entering the stream.
      release_live_active_record_connections

      with_dashboard_comparison_timing("render_dispatch") do
        stream_view_containing_react_components(
          template: "public_product_rsc_demo/rsc_demo",
          layout: "inertia"
        )
      end
    end
  end

  def discover_rsc_demo
    with_dashboard_comparison_timing("action_total") do
      @hide_layouts = true
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?
      @public_discover_rsc_demo_props = public_discover_comparison_props
      @precomputed_rendering_context = RenderingExtension.custom_context(view_context)
      # ActionController::Live can keep this action thread open after the response
      # reaches the client, so release DB connections before entering the stream.
      release_live_active_record_connections

      with_dashboard_comparison_timing("render_dispatch") do
        stream_view_containing_react_components(
          template: "public_product_rsc_demo/discover_rsc_demo",
          layout: "inertia"
        )
      end
    end
  end

  private
    def public_product_comparison_props
      with_dashboard_comparison_timing("compare_props") do
        with_dashboard_comparison_timing("compare_product") do
          public_product_rsc_demo_presenter.product_props
        end
      end
    end

    def public_discover_comparison_props
      with_dashboard_comparison_timing("compare_props") do
        with_dashboard_comparison_timing("compare_discover") do
          public_product_rsc_demo_presenter.discover_props
        end
      end
    end

    def public_product_rsc_demo_presenter
      @public_product_rsc_demo_presenter ||= PublicProductRscDemoPresenter.new(request:)
    end

    def prepare_public_product_page
      set_meta_tag(title: public_product_rsc_demo_presenter.product_title)
      set_meta_tag(name: "description", content: public_product_rsc_demo_presenter.product_description)
      set_meta_tag(property: "og:title", content: public_product_rsc_demo_presenter.product_title)
      set_meta_tag(property: "og:description", content: public_product_rsc_demo_presenter.product_description)
      set_public_demo_canonical_meta(
        demo_url: action_name == "rsc_demo" ? public_product_rsc_demo_url : public_product_inertia_demo_url
      )
    end

    def prepare_public_discover_page
      set_meta_tag(title: public_product_rsc_demo_presenter.discover_title)
      set_meta_tag(name: "description", content: public_product_rsc_demo_presenter.discover_description)
      set_meta_tag(property: "og:title", content: public_product_rsc_demo_presenter.discover_title)
      set_meta_tag(property: "og:description", content: public_product_rsc_demo_presenter.discover_description)
      set_public_demo_canonical_meta(
        demo_url: action_name == "discover_rsc_demo" ? public_product_discover_rsc_demo_url : public_product_discover_inertia_demo_url
      )
    end

    def set_public_demo_canonical_meta(demo_url:)
      remove_meta_tag("canonical")
      remove_meta_tag("meta-property-og-url")
      remove_meta_tag("structured-data")
      set_meta_tag(tag_name: "link", rel: "canonical", href: demo_url, head_key: "canonical")
      set_meta_tag(property: "og:url", content: demo_url)
    end

    def content_security_policy_nonce(_directive = nil)
      SecureHeaders.content_security_policy_script_nonce(request)
    end
end
