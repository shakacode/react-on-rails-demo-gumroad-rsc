# frozen_string_literal: true

require "fileutils"
require "json"
require "optparse"
require "selenium-webdriver"
require "time"
require "uri"

module PublicPageResourceAudit
  module_function

  MACOS_CHROME_BINARY = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

  DEFAULTS = {
    urls: [],
    output: nil,
    width: 390,
    height: 844,
    mobile: false,
    settle_seconds: 3.0,
    timeout: 60,
    require_driver_match: false
  }.freeze

  DOM_SUMMARY_SCRIPT = <<~JAVASCRIPT
    const countBy = (values) => values.reduce((summary, value) => {
      summary[value] = (summary[value] || 0) + 1;
      return summary;
    }, {});
    const images = Array.from(document.images).map((image) => {
      const rectangle = image.getBoundingClientRect();
      const source = new URL(image.currentSrc || image.src, location.href);
      return {
        host: source.host,
        renderedSize: `${Math.round(rectangle.width)}x${Math.round(rectangle.height)}`,
        naturalSize: `${image.naturalWidth}x${image.naturalHeight}`,
        loading: image.getAttribute("loading") || "unspecified",
        fetchPriority: image.getAttribute("fetchpriority") || "unspecified",
        hasSrcset: Boolean(image.getAttribute("srcset")),
        hasSizes: Boolean(image.getAttribute("sizes")),
        inViewport: rectangle.bottom > 0 && rectangle.top < window.innerHeight,
        complete: image.complete,
        sourceKey: image.currentSrc || image.src
      };
    });
    return {
      title: document.title,
      heading: document.querySelector("h1")?.textContent?.trim() || null,
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight
      },
      bodyWidth: {
        client: document.body.clientWidth,
        scroll: document.body.scrollWidth
      },
      landmarks: {
        headers: document.querySelectorAll("header").length,
        navs: document.querySelectorAll("nav").length,
        mains: document.querySelectorAll("main").length,
        footers: document.querySelectorAll("footer").length
      },
      controls: {
        buttons: document.querySelectorAll("button").length,
        links: document.querySelectorAll("a").length,
        forms: document.querySelectorAll("form").length,
        inputs: document.querySelectorAll("input").length,
        iframes: document.querySelectorAll("iframe").length
      },
      images: {
        elementCount: images.length,
        uniqueSourceCount: new Set(images.map((image) => image.sourceKey)).size,
        completeCount: images.filter((image) => image.complete).length,
        inViewportCount: images.filter((image) => image.inViewport).length,
        hosts: countBy(images.map((image) => image.host)),
        loading: countBy(images.map((image) => image.loading)),
        fetchPriority: countBy(images.map((image) => image.fetchPriority)),
        srcsetCount: images.filter((image) => image.hasSrcset).length,
        sizesCount: images.filter((image) => image.hasSizes).length,
        renderedSizes: countBy(images.map((image) => image.renderedSize)),
        naturalSizes: countBy(images.map((image) => image.naturalSize))
      }
    };
  JAVASCRIPT

  def parse_options(arguments)
    options = DEFAULTS.merge(urls: [])

    OptionParser.new do |parser|
      parser.banner = "Usage: ruby scripts/perf/audit_public_page_resources.rb --url URL [--url URL] [options]"
      parser.on("--url URL", String) { |value| options[:urls] << value }
      parser.on("--output PATH", String) { |value| options[:output] = value }
      parser.on("--width PIXELS", Integer) { |value| options[:width] = value }
      parser.on("--height PIXELS", Integer) { |value| options[:height] = value }
      parser.on("--mobile", "Emulate a touch-capable mobile browser with DPR 3") { options[:mobile] = true }
      parser.on("--settle-seconds SECONDS", Float) { |value| options[:settle_seconds] = value }
      parser.on("--timeout SECONDS", Integer) { |value| options[:timeout] = value }
      parser.on("--require-driver-match") { options[:require_driver_match] = true }
    end.parse!(arguments.dup)

    raise OptionParser::MissingArgument, "at least one --url is required" if options[:urls].empty?
    raise OptionParser::InvalidArgument, "viewport dimensions must be positive" if options[:width] <= 0 || options[:height] <= 0
    raise OptionParser::InvalidArgument, "--settle-seconds must be zero or greater" if options[:settle_seconds].negative?

    options
  end

  def parse_network_rows(messages)
    responses = {}

    messages.each do |message|
      params = message.fetch("params", {})

      case message["method"]
      when "Network.responseReceived"
        response = params.fetch("response", {})
        responses[params.fetch("requestId")] = {
          url: response["url"],
          type: params["type"],
          status: response["status"],
          mime: response["mimeType"],
          headers: response.fetch("headers", {}),
          protocol: response["protocol"],
          from_disk_cache: response["fromDiskCache"],
          from_service_worker: response["fromServiceWorker"],
          encoded_data_length: response["encodedDataLength"]
        }
      when "Network.loadingFinished"
        row = responses[params["requestId"]]
        row[:encoded_data_length] = params["encodedDataLength"] if row
      end
    end

    responses.values.select { |row| row[:url]&.start_with?("http") }
  end

  def summarize_resources(rows)
    {
      requestCount: rows.length,
      transferBytes: rows.sum { |row| row.fetch(:encoded_data_length).to_i },
      byType: summarize_groups(rows.group_by { |row| row.fetch(:type) }),
      byHost: summarize_hosts(rows),
      images: summarize_delivery(rows, "Image"),
      fonts: summarize_delivery(rows, "Font")
    }
  end

  def summarize_delivery(rows, type)
    matching_rows = rows.select { |row| row.fetch(:type) == type }
    profiles = matching_rows.map do |row|
      {
        host: URI(row.fetch(:url)).host,
        mime: row[:mime],
        transfer_bytes: row.fetch(:encoded_data_length).to_i,
        cacheControl: header_value(row, "cache-control"),
        contentEncoding: header_value(row, "content-encoding"),
        cdnCacheStatus: header_value(row, "cf-cache-status"),
        age_seconds: header_value(row, "age")&.to_i,
        protocol: row[:protocol],
        fromDiskCache: row[:from_disk_cache]
      }
    end

    {
      requestCount: matching_rows.length,
      transferBytes: matching_rows.sum { |row| row.fetch(:encoded_data_length).to_i },
      mimes: matching_rows.map { |row| row[:mime] }.compact.tally,
      cacheProfiles: group_delivery_profiles(profiles)
    }
  end

  def group_delivery_profiles(profiles)
    profiles
      .group_by { |profile| profile.except(:transfer_bytes, :age_seconds) }
      .map do |profile, matching_profiles|
        ages = matching_profiles.filter_map { |matching_profile| matching_profile[:age_seconds] }
        profile.merge(
          requestCount: matching_profiles.length,
          transferBytes: matching_profiles.sum { |matching_profile| matching_profile.fetch(:transfer_bytes) },
          ageRangeSeconds: ages.empty? ? nil : [ages.min, ages.max]
        )
      end
  end

  def header_value(row, name)
    row.fetch(:headers, {}).find { |key, _value| key.downcase == name }&.last
  end

  def chrome_options(width:, height:)
    Selenium::WebDriver::Chrome::Options.new.tap do |options|
      options.binary = MACOS_CHROME_BINARY if File.exist?(MACOS_CHROME_BINARY)
      options.add_argument("--headless=new")
      options.add_argument("--window-size=#{width},#{height}")
      options.add_argument("--disable-popup-blocking")
      options.add_option("goog:loggingPrefs", { performance: "ALL" })
    end
  end

  def device_metrics(width:, height:, mobile:)
    { width:, height:, deviceScaleFactor: mobile ? 3 : 1, mobile: }
  end

  def mobile_user_agent(browser_version)
    "Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 " \
      "(KHTML, like Gecko) Chrome/#{browser_version} Mobile Safari/537.36"
  end

  def enable_mobile_emulation(driver, browser_version)
    driver.execute_cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 5)
    driver.execute_cdp(
      "Network.setUserAgentOverride",
      userAgent: mobile_user_agent(browser_version),
      acceptLanguage: "en-US,en;q=0.9",
      platform: "Android"
    )
  end

  def browser_metadata(driver)
    chrome_capabilities = driver.capabilities["chrome"] || {}
    {
      browserName: driver.capabilities.browser_name,
      browserVersion: driver.capabilities.browser_version,
      chromeDriverVersion: chrome_capabilities["chromedriverVersion"]&.split(" ")&.first,
      platformName: driver.capabilities.platform_name
    }
  end

  def validate_driver_match!(browser)
    browser_major = browser.fetch(:browserVersion).to_s.split(".").first
    driver_major = browser.fetch(:chromeDriverVersion).to_s.split(".").first
    return if !browser_major.empty? && browser_major == driver_major

    raise "Chrome #{browser[:browserVersion]} does not match ChromeDriver #{browser[:chromeDriverVersion]}"
  end

  def performance_messages(entries)
    entries.filter_map do |entry|
      JSON.parse(entry.message).fetch("message")
    rescue JSON::ParserError, KeyError
      nil
    end
  end

  def audit_url(url, options)
    driver = Selenium::WebDriver.for(
      :chrome,
      options: chrome_options(width: options.fetch(:width), height: options.fetch(:height))
    )

    driver.execute_cdp("Network.enable")
    browser = browser_metadata(driver)
    validate_driver_match!(browser) if options.fetch(:require_driver_match)
    driver.execute_cdp(
      "Emulation.setDeviceMetricsOverride",
      **device_metrics(width: options.fetch(:width), height: options.fetch(:height), mobile: options.fetch(:mobile))
    )
    enable_mobile_emulation(driver, browser.fetch(:browserVersion)) if options.fetch(:mobile)
    driver.navigate.to(url)
    Selenium::WebDriver::Wait.new(timeout: options.fetch(:timeout)).until do
      driver.execute_script("return document.readyState") == "complete"
    end
    sleep(options.fetch(:settle_seconds))

    rows = parse_network_rows(performance_messages(driver.logs.get(:performance)))

    {
      sourceUrl: url,
      finalUrl: driver.current_url,
      browser:,
      document: driver.execute_script(DOM_SUMMARY_SCRIPT),
      resources: summarize_resources(rows)
    }
  ensure
    driver&.quit
  end

  def run(arguments)
    options = parse_options(arguments)
    output = {
      capturedAtUtc: Time.now.utc.iso8601,
      method: "Chrome DevTools Network.responseReceived + Network.loadingFinished with a fresh browser per URL",
      viewport: { width: options.fetch(:width), height: options.fetch(:height) },
      emulation: {
        mobile: options.fetch(:mobile),
        deviceScaleFactor: options.fetch(:mobile) ? 3 : 1,
        touch: options.fetch(:mobile)
      },
      settleSeconds: options.fetch(:settle_seconds),
      requireDriverMatch: options.fetch(:require_driver_match),
      pages: options.fetch(:urls).map { |url| audit_url(url, options) }
    }
    json = JSON.pretty_generate(output)

    if options[:output]
      FileUtils.mkdir_p(File.dirname(File.expand_path(options[:output])))
      File.write(options[:output], json)
    end

    puts json
  end

  def summarize_groups(groups)
    groups.transform_values do |rows|
      {
        requestCount: rows.length,
        transferBytes: rows.sum { |row| row.fetch(:encoded_data_length).to_i }
      }
    end
  end

  def summarize_hosts(rows)
    rows
      .group_by { |row| URI(row.fetch(:url)).host }
      .transform_values do |host_rows|
        {
          requestCount: host_rows.length,
          transferBytes: host_rows.sum { |row| row.fetch(:encoded_data_length).to_i },
          types: host_rows.map { |row| row.fetch(:type) }.tally
        }
      end
  end
end

PublicPageResourceAudit.run(ARGV) if $PROGRAM_NAME == __FILE__
