# frozen_string_literal: true

class DashboardRscDemoController < Sellers::BaseController
  include ReactOnRailsPro::Stream
  include LiveActiveRecordConnectionCleanup
  include LiveStreamingResponseHeaders
  include DashboardComparisonTiming
  include DashboardComparisonProps

  before_action :check_payment_details, only: :index
  before_action :prepare_live_streaming_response, only: :index
  prepend_around_action :clear_live_active_record_connections, only: :index
  write_dashboard_comparison_server_timing_after_action only: :index
  helper_method :content_security_policy_nonce

  def index
    with_dashboard_comparison_timing("action_total") do
      authorize :dashboard

      if current_seller.suspended_for_tos_violation?
        redirect_to products_url
        return
      end

      with_dashboard_comparison_timing("large_seller") { LargeSeller.create_if_warranted(current_seller) }

      @hide_layouts = true
      @css_pack_name = "dashboard_rsc_demo_styles" unless Rails.env.test?
      @dashboard_rsc_demo_props = dashboard_comparison_props
      # ActionController::Live can keep this action thread open after the response
      # reaches the client, so release DB connections before entering the stream.
      release_live_active_record_connections

      with_dashboard_comparison_timing("render_dispatch") do
        stream_view_containing_react_components(
          template: "dashboard_rsc_demo/index",
          layout: "inertia"
        )
      end
    end
  end

  private
    def content_security_policy_nonce(_directive = nil)
      SecureHeaders.content_security_policy_script_nonce(request)
    end
end
