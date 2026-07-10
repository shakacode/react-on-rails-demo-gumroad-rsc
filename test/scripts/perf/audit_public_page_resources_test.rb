# frozen_string_literal: true

require "json"
require "minitest/autorun"
require_relative "../../../scripts/perf/audit_public_page_resources"

class AuditPublicPageResourcesTest < Minitest::Test
  def test_builds_mobile_device_metrics_with_a_realistic_pixel_ratio
    assert_equal(
      { width: 390, height: 844, deviceScaleFactor: 3, mobile: true },
      PublicPageResourceAudit.device_metrics(width: 390, height: 844, mobile: true)
    )
  end

  def test_builds_a_versioned_mobile_user_agent
    user_agent = PublicPageResourceAudit.mobile_user_agent("150.0.7871.49")

    assert_includes user_agent, "Android 14"
    assert_includes user_agent, "Chrome/150.0.7871.49 Mobile"
  end

  def test_parses_repeatable_urls_and_browser_capture_options
    options = PublicPageResourceAudit.parse_options(
      [
        "--url", "https://gumroad.reactonrails.com/public_product/rsc_demo",
        "--url", "https://gumroad.com/discover",
        "--output", "tmp/parity.json",
        "--width", "390",
        "--height", "844",
        "--mobile",
        "--settle-seconds", "3",
        "--require-driver-match"
      ]
    )

    assert_equal 2, options[:urls].length
    assert_equal "tmp/parity.json", options[:output]
    assert_equal 390, options[:width]
    assert_equal 844, options[:height]
    assert options[:mobile]
    assert_equal 3.0, options[:settle_seconds]
    assert options[:require_driver_match]
  end

  def test_parses_completed_network_responses
    messages = [
      {
        "method" => "Network.responseReceived",
        "params" => {
          "requestId" => "request-1",
          "type" => "Image",
          "response" => {
            "url" => "https://public-files.gumroad.com/product.webp",
            "status" => 200,
            "mimeType" => "image/webp",
            "headers" => { "cache-control" => "public, max-age=31536000" },
            "protocol" => "h3",
            "fromDiskCache" => false,
            "fromServiceWorker" => false
          }
        }
      },
      {
        "method" => "Network.loadingFinished",
        "params" => { "requestId" => "request-1", "encodedDataLength" => 1_200 }
      }
    ]

    assert_equal(
      [
        {
          url: "https://public-files.gumroad.com/product.webp",
          type: "Image",
          status: 200,
          mime: "image/webp",
          headers: { "cache-control" => "public, max-age=31536000" },
          protocol: "h3",
          from_disk_cache: false,
          from_service_worker: false,
          encoded_data_length: 1_200
        }
      ],
      PublicPageResourceAudit.parse_network_rows(messages)
    )
  end

  def test_aggregates_transfer_bytes_without_retaining_asset_urls
    rows = [
      {
        url: "https://public-files.gumroad.com/product.webp",
        type: "Image",
        mime: "image/webp",
        encoded_data_length: 1_200,
        headers: { "cache-control" => "public, max-age=31536000" }
      },
      {
        url: "https://assets.gumroad.com/app.js",
        type: "Script",
        mime: "application/javascript",
        encoded_data_length: 800,
        headers: {}
      }
    ]

    summary = PublicPageResourceAudit.summarize_resources(rows)

    assert_equal 2, summary[:requestCount]
    assert_equal 2_000, summary[:transferBytes]
    assert_equal(
      {
        "Image" => { requestCount: 1, transferBytes: 1_200 },
        "Script" => { requestCount: 1, transferBytes: 800 }
      },
      summary[:byType]
    )
    assert_equal(
      {
        "public-files.gumroad.com" => { requestCount: 1, transferBytes: 1_200, types: { "Image" => 1 } },
        "assets.gumroad.com" => { requestCount: 1, transferBytes: 800, types: { "Script" => 1 } }
      },
      summary[:byHost]
    )
    # This standalone Minitest file does not load Active Support's assert_not_includes.
    refute_includes summary.to_json, "product.webp" # rubocop:disable Rails/RefuteMethods
    refute_includes summary.to_json, "app.js" # rubocop:disable Rails/RefuteMethods
  end

  def test_summarizes_image_and_font_delivery_profiles
    rows = [
      {
        url: "https://public-files.gumroad.com/a.webp",
        type: "Image",
        mime: "image/webp",
        encoded_data_length: 1_200,
        headers: {
          "cache-control" => "public, max-age=31536000",
          "cf-cache-status" => "HIT",
          "age" => "100"
        },
        protocol: "h3",
        from_disk_cache: false
      },
      {
        url: "https://public-files.gumroad.com/b.webp",
        type: "Image",
        mime: "image/webp",
        encoded_data_length: 800,
        headers: {
          "cache-control" => "public, max-age=31536000",
          "cf-cache-status" => "HIT",
          "age" => "200"
        },
        protocol: "h3",
        from_disk_cache: false
      },
      {
        url: "https://assets.gumroad.com/font.woff2",
        type: "Font",
        mime: "font/woff2",
        encoded_data_length: 500,
        headers: { "cache-control" => "public, max-age=31536000" },
        protocol: "h2",
        from_disk_cache: false
      }
    ]

    summary = PublicPageResourceAudit.summarize_resources(rows)

    assert_equal({ "image/webp" => 2 }, summary.dig(:images, :mimes))
    assert_equal 2_000, summary.dig(:images, :transferBytes)
    assert_equal [100, 200], summary.dig(:images, :cacheProfiles, 0, :ageRangeSeconds)
    assert_equal({ "font/woff2" => 1 }, summary.dig(:fonts, :mimes))
    assert_equal 500, summary.dig(:fonts, :transferBytes)
  end
end
