# frozen_string_literal: true

class PublicProductRscDemoPresenter
  include Rails.application.routes.url_helpers

  REACT_ON_RAILS_URL = "https://reactonrails.com/"
  REACT_ON_RAILS_GITHUB_URL = "https://github.com/shakacode/react_on_rails"
  SHAKACODE_URL = "https://www.shakacode.com/"
  CONSULTATION_URL = "https://meetings.hubspot.com/justingordon/30-minute-consultation"
  GUMROAD_DISCOVER_REFERENCE_URL = "https://gumroad.com/discover"

  REPO_SOURCE_BASE_URL = "https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main"
  HOSTED_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/hosted-public-buyer-pages-2026-06-24/summary.json"
  BENCHMARK_TIE_BAND_PERCENT = 5

  CONTROLLER_SOURCE_PATH = "app/controllers/public_product_rsc_demo_controller.rb"
  PRESENTER_SOURCE_PATH = "app/presenters/public_product_rsc_demo_presenter.rb"
  COMPARISON_UI_SOURCE_PATH = "app/javascript/src/public_product_rsc_demo/PublicProductComparisonPage.tsx"
  PRODUCT_INERTIA_PAGE_SOURCE_PATH = "app/javascript/pages/PublicProduct/InertiaDemo.tsx"
  DISCOVER_INERTIA_PAGE_SOURCE_PATH = "app/javascript/pages/PublicProduct/DiscoverInertiaDemo.tsx"
  PRODUCT_RSC_TEMPLATE_SOURCE_PATH = "app/views/public_product_rsc_demo/rsc_demo.html.erb"
  DISCOVER_RSC_TEMPLATE_SOURCE_PATH = "app/views/public_product_rsc_demo/discover_rsc_demo.html.erb"
  PRODUCT_RSC_COMPONENT_SOURCE_PATH = "app/javascript/src/public_product_rsc_demo/ror_components/PublicProductRscDemoPage.tsx"
  DISCOVER_RSC_COMPONENT_SOURCE_PATH = "app/javascript/src/public_product_rsc_demo/ror_components/PublicDiscoverRscDemoPage.tsx"

  HOSTED_BENCHMARK_METRICS = [
    { key: :median_navigation_duration_ms, label: "Navigation duration", unit: :ms },
    { key: :median_lcp_start_ms, label: "LCP start", unit: :ms },
    { key: :median_response_end_ms, label: "Response end (server TTLB)", unit: :ms },
    { key: :median_html_transfer_bytes, label: "HTML transfer (over the wire)", unit: :bytes },
    { key: :median_js_transfer_bytes, label: "JavaScript transfer (over the wire)", unit: :bytes },
    { key: :median_js_request_count, label: "JavaScript requests", unit: :count },
    { key: :median_decoded_js_css_bytes, label: "Decoded JavaScript + CSS", unit: :bytes },
    { key: :inertia_data_page_bytes, label: "Serialized Inertia payload", unit: :bytes },
  ].freeze

  PRODUCT_REFERENCE_SHAPE = "Products/Discover/Show"
  DISCOVER_REFERENCE_SHAPE = "Discover/Index"

  PRODUCT_PAGE = {
    permalink: "creator-analytics-playbook",
    name: "Creator Analytics Playbook",
    summary: "A practical workbook for turning storefront traffic, launch notes, and customer feedback into repeatable product decisions.",
    native_type: "digital workbook",
    price_cents: 3900,
    currency_code: "usd",
    call_to_action: "Buy this",
    seller: {
      name: "Northstar Studio",
      tagline: "Templates and field guides for independent creators",
      avatar_initials: "NS",
      is_verified: true,
      followers_count: 12800,
    },
    ratings: {
      average: 4.8,
      count: 427,
      percentages: [82, 13, 4, 1, 0],
    },
    hero_stats: [
      { label: "Launch checklists", value: "42" },
      { label: "Worksheet pages", value: "118" },
      { label: "Buyer segments", value: "9" },
    ],
    cover_theme: {
      start: "#ff90e8",
      end: "#23a094",
      accent: "#ffc900",
    },
    bullets: [
      "Map acquisition channels to product experiments before spending on ads.",
      "Prioritize product-page copy changes using conversion and search intent signals.",
      "Run weekly creator reviews with lightweight scorecards and decision logs.",
    ],
    description_sections: [
      {
        heading: "Built for public product pages",
        body: "The fixture mirrors the kind of product storytelling that should be visible before hydration: title, seller, summary, price, cover art, reviews, included files, and purchase framing.",
      },
      {
        heading: "Designed to stress the rendering path",
        body: "The page includes enough above-the-fold content, recommendation cards, FAQ copy, and buyer confidence details to make client JavaScript and serialized payload differences measurable.",
      },
      {
        heading: "Synthetic but production-shaped",
        body: "The layout and data shape were informed by public Gumroad Discover and product pages, but names, copy, prices, creator profiles, and artwork placeholders are synthetic for the public demo repo.",
      },
    ],
    included_files: [
      { name: "Analytics workbook", description: "Spreadsheet and PDF workbook", filetype: "xlsx + pdf" },
      { name: "Launch review template", description: "Weekly experiment retro template", filetype: "notion + md" },
      { name: "Product-page checklist", description: "Mobile-first conversion checklist", filetype: "pdf" },
    ],
    faq: [
      {
        question: "Why benchmark a public product page?",
        answer: "It is logged out, SEO-sensitive, conversion-sensitive, and common on mobile. That is the surface where React Server Components must earn their complexity.",
      },
      {
        question: "Is this copied from a creator?",
        answer: "No. The fixture uses public page structure as a guide, but the committed data is synthetic and sanitized.",
      },
      {
        question: "What would make the result compelling?",
        answer: "A meaningful win in LCP, navigation timing, client JavaScript, serialized payload, or mobile Lighthouse-style scores on matched pages.",
      },
    ],
  }.freeze

  DISCOVER_CATEGORIES = [
    { label: "Design", slug: "design", count: 18420 },
    { label: "Software development", slug: "software-development", count: 12880 },
    { label: "Business and money", slug: "business-and-money", count: 17240 },
    { label: "Education", slug: "education", count: 9640 },
    { label: "Drawing and painting", slug: "drawing-and-painting", count: 11220 },
    { label: "Music and sound design", slug: "music-and-sound-design", count: 7620 },
    { label: "Photography", slug: "photography", count: 6180 },
    { label: "Self improvement", slug: "self-improvement", count: 8420 },
  ].freeze

  DISCOVER_TAGS = [
    { key: "notion template", doc_count: 2100 },
    { key: "brushes", doc_count: 1840 },
    { key: "analytics", doc_count: 1432 },
    { key: "procreate", doc_count: 1288 },
    { key: "creator business", doc_count: 1184 },
    { key: "fitness", doc_count: 1052 },
    { key: "fonts", doc_count: 998 },
    { key: "coding", doc_count: 941 },
  ].freeze

  DISCOVER_FILETYPES = [
    { key: "pdf", doc_count: 9800 },
    { key: "zip", doc_count: 7420 },
    { key: "video", doc_count: 6350 },
    { key: "template", doc_count: 5940 },
    { key: "audio", doc_count: 2480 },
    { key: "image", doc_count: 2320 },
    { key: "epub", doc_count: 1190 },
    { key: "software", doc_count: 860 },
  ].freeze

  CARD_NAMES = [
    ["Launch Metrics OS", "Northstar Studio", "business-and-money", "template", 4900],
    ["Pixel Brush Studio Kit", "Palette Forge", "drawing-and-painting", "brush pack", 2200],
    ["Indie SaaS Pricing Lab", "Lumen Works", "software-development", "workbook", 5900],
    ["Creator Email Swipe File", "Small Bet Supply", "writing-and-publishing", "templates", 1900],
    ["Sound Pack: Glass Cities", "Wave Table Club", "music-and-sound-design", "sample pack", 2800],
    ["Notion Habit Dashboard", "Useful Systems", "self-improvement", "notion template", 1200],
    ["Mobile Photo Presets", "Wildlight Lab", "photography", "preset pack", 2400],
    ["Course Outline Builder", "Bright Stack", "education", "course template", 3400],
    ["Portfolio Type System", "Signal Type Co.", "design", "font bundle", 4200],
    ["API Client Starter", "Shipyard Code", "software-development", "starter kit", 6900],
    ["Freelance Proposal Vault", "Paper Trail Studio", "business-and-money", "templates", 2700],
    ["Storyboard Procreate Pack", "Frame Garden", "drawing-and-painting", "brush pack", 2500],
    ["Yoga Class Planner", "Studio Reset", "fitness-and-health", "planner", 1800],
    ["Synthwave Loop Library", "Neon Tape", "music-and-sound-design", "loops", 3600],
    ["Newsletter Growth Map", "Tiny Audience", "business-and-money", "guide", 3100],
    ["Rails Performance Notes", "Full Stack Field", "software-development", "ebook", 3900],
    ["Editorial Mockup Kit", "Offset Objects", "design", "mockups", 2900],
    ["Digital Product Tax Checklist", "Ledger Light", "business-and-money", "checklist", 1500],
    ["Character Pose Reference", "Draw Daily", "drawing-and-painting", "reference pack", 2100],
    ["Meditation Audio Starter", "Quiet Habit", "self-improvement", "audio course", 1700],
    ["Customer Interview Script", "Research Bench", "business-and-money", "script pack", 1600],
    ["Frontend Pattern Cards", "Interface Kitchen", "software-development", "reference deck", 3300],
    ["Film LUT Collection", "Color Cabin", "films", "luts", 2600],
    ["Micro Course Sales Page", "Launch Shelf", "education", "template", 4500],
    ["Icon Grid System", "Vector Mill", "design", "asset pack", 2300],
    ["Ambient Texture Library", "Field Audio Lab", "music-and-sound-design", "sound library", 3200],
    ["Creator Finance Tracker", "Northstar Studio", "business-and-money", "spreadsheet", 2100],
    ["3D Product Render Basics", "Render Room", "3d", "video lessons", 5300],
    ["Writing Sprint Planner", "Inkline Studio", "writing-and-publishing", "planner", 900],
    ["Landing Page Copy Blocks", "Conversion Cottage", "business-and-money", "copy kit", 3700],
    ["Game UI Button Pack", "Sprite Foundry", "gaming", "asset pack", 1900],
    ["Low Content Book Interiors", "Print Meadow", "writing-and-publishing", "templates", 2500],
    ["Personal CRM Blueprint", "Useful Systems", "self-improvement", "notion template", 1400],
    ["Podcast Edit Checklist", "Wave Table Club", "audio", "checklist", 1100],
    ["Customer Support Macros", "Help Desk Garden", "business-and-money", "templates", 1800],
    ["React Form Recipes", "Shipyard Code", "software-development", "code examples", 4100],
  ].freeze

  THEME_PAIRS = [
    ["#ff90e8", "#23a094"],
    ["#ffc900", "#ff7051"],
    ["#90a8ed", "#7f5af0"],
    ["#23a094", "#f1f333"],
    ["#ff7051", "#ffc900"],
    ["#f1f333", "#ff90e8"],
  ].freeze

  attr_reader :request

  def initialize(request:)
    @request = request
  end

  def product_props
    shared_props.merge(
      page_kind: "product",
      product_page: product_fixture,
      discover_page: nil
    )
  end

  def discover_props
    shared_props.merge(
      page_kind: "discover",
      product_page: nil,
      discover_page: discover_fixture
    )
  end

  def product_title
    PRODUCT_PAGE.fetch(:name)
  end

  def product_description
    PRODUCT_PAGE.fetch(:summary)
  end

  def discover_title
    "Gumroad Discover RSC benchmark"
  end

  def discover_description
    "A production-shaped, synthetic Discover listing fixture comparing Inertia and React Server Components via React on Rails Pro."
  end

  def self.hosted_benchmark
    return @hosted_benchmark if defined?(@hosted_benchmark)

    @hosted_benchmark = begin
      JSON.parse(File.read(Rails.root.join(HOSTED_BENCHMARK_ARTIFACT_PATH)), symbolize_names: true)
    rescue StandardError
      nil
    end
  end

  def route_source_links(page_kind)
    discover = page_kind.to_sym == :discover
    {
      inertia: [
        source_link("Controller", CONTROLLER_SOURCE_PATH),
        source_link("Inertia page", discover ? DISCOVER_INERTIA_PAGE_SOURCE_PATH : PRODUCT_INERTIA_PAGE_SOURCE_PATH),
        source_link("Shared UI", COMPARISON_UI_SOURCE_PATH),
        source_link("Fixtures", PRESENTER_SOURCE_PATH),
      ],
      rsc: [
        source_link("Controller", CONTROLLER_SOURCE_PATH),
        source_link("Streamed template", discover ? DISCOVER_RSC_TEMPLATE_SOURCE_PATH : PRODUCT_RSC_TEMPLATE_SOURCE_PATH),
        source_link("RSC server component", discover ? DISCOVER_RSC_COMPONENT_SOURCE_PATH : PRODUCT_RSC_COMPONENT_SOURCE_PATH),
        source_link("Fixtures", PRESENTER_SOURCE_PATH),
      ],
    }
  end

  def hosted_benchmark_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{HOSTED_BENCHMARK_ARTIFACT_PATH}"
  end

  def hosted_benchmark_method_note
    data = self.class.hosted_benchmark
    return if data.nil?

    browser = data[:browser] || {}
    method = data[:method] || {}
    "Captured #{data[:captured_at_utc_date]} UTC against #{data[:host]} with headless #{browser[:name]} #{browser[:version]}, " \
      "#{method[:cycles]} alternating cycles, and #{method[:server_warmup_requests_per_run]} warmup requests per measured run."
  end

  def hosted_benchmark_caveats
    self.class.hosted_benchmark&.dig(:caveats) || []
  end

  def hosted_benchmark_surfaces
    (self.class.hosted_benchmark&.dig(:results) || []).map do |result|
      {
        surface: result[:surface],
        page_kind: result[:candidate_path].to_s.include?("discover") ? :discover : :product,
        rows: hosted_benchmark_rows(result),
      }
    end
  end

  private
    def source_link(label, path)
      { label:, url: "#{REPO_SOURCE_BASE_URL}/#{path}" }
    end

    def hosted_benchmark_rows(result)
      rows = HOSTED_BENCHMARK_METRICS.filter_map do |metric|
        pair = result[metric[:key]]
        next if pair.nil?

        benchmark_row(metric[:label], pair[:inertia], pair[:rsc], metric[:unit], pair[:delta_percent])
      end

      html = result[:median_html_transfer_bytes]
      js = result[:median_js_transfer_bytes]
      if html && js
        rows << benchmark_row("Total wire weight (HTML + JavaScript)", html[:inertia] + js[:inertia], html[:rsc] + js[:rsc], :bytes)
      end

      rows
    end

    def benchmark_row(label, inertia, rsc, unit, delta_percent = nil)
      percent = delta_percent || computed_percent(inertia, rsc)
      {
        label:,
        inertia: format_metric(inertia, unit),
        rsc: format_metric(rsc, unit),
        delta: format_delta_percent(percent),
        verdict: verdict_for(inertia, rsc),
      }
    end

    def verdict_for(inertia, rsc)
      inertia = inertia.to_f
      rsc = rsc.to_f
      return :tie if inertia.zero? && rsc.zero?
      return :inertia_wins if inertia.zero?

      improvement = ((inertia - rsc) / inertia) * 100.0
      return :tie if improvement.abs < BENCHMARK_TIE_BAND_PERCENT

      improvement.positive? ? :rsc_wins : :inertia_wins
    end

    def computed_percent(inertia, rsc)
      inertia = inertia.to_f
      return if inertia.zero?

      ((rsc.to_f - inertia) / inertia) * 100.0
    end

    def format_delta_percent(percent)
      return "—" if percent.nil?

      "#{percent.negative? ? "-" : "+"}#{trim_number(percent.abs, 1)}%"
    end

    def format_metric(value, unit)
      case unit
      when :ms then "#{trim_number(value)} ms"
      when :bytes then format_bytes(value)
      when :count then value.to_i.to_s
      else value.to_s
      end
    end

    def format_bytes(value)
      value = value.to_f
      return "None" if value.zero?
      return "#{trim_number(value / 1_048_576.0)} MB" if value >= 1_048_576
      return "#{trim_number(value / 1024.0)} KB" if value >= 1024

      "#{value.to_i} B"
    end

    def trim_number(value, precision = 2)
      rounded = value.to_f.round(precision)
      rounded == rounded.to_i ? rounded.to_i.to_s : rounded.to_s
    end

    def shared_props
      {
        locale: I18n.locale.to_s,
        source_note: [
          "Fixture shape sampled from public Gumroad #{DISCOVER_REFERENCE_SHAPE} and #{PRODUCT_REFERENCE_SHAPE} pages:",
          "36-card Discover grid, 8 tag/filetype buckets, taxonomy nav, and product seller/cover/rating/purchase fields.",
          "Committed copy, creators, prices, and artwork are synthetic.",
        ].join(" "),
        comparison: comparison_links,
      }
    end

    def comparison_links
      {
        home_url: root_path,
        performance_url: public_product_performance_demo_path,
        inertia_url: public_product_inertia_demo_path,
        rsc_url: public_product_rsc_demo_path,
        product_inertia_url: public_product_inertia_demo_path,
        product_rsc_url: public_product_rsc_demo_path,
        discover_inertia_url: public_product_discover_inertia_demo_path,
        discover_rsc_url: public_product_discover_rsc_demo_path,
        react_on_rails_url: REACT_ON_RAILS_URL,
        react_on_rails_github_url: REACT_ON_RAILS_GITHUB_URL,
        shakacode_url: SHAKACODE_URL,
        consultation_url: CONSULTATION_URL,
        gumroad_discover_reference_url: GUMROAD_DISCOVER_REFERENCE_URL,
      }
    end

    def product_fixture
      PRODUCT_PAGE.merge(
        recommendations: discover_products.first(8),
      ).deep_dup
    end

    def discover_fixture
      {
        title: "Discover creator-made products",
        subtitle: "A synthetic Gumroad marketplace surface built to compare matched Inertia and RSC rendering on a public, SEO-sensitive page.",
        currency_code: "usd",
        total_products: 42_860,
        active_creators: 8_420,
        weekly_sales_cents: 3_129_297_00,
        categories: DISCOVER_CATEGORIES,
        tags_data: DISCOVER_TAGS,
        filetypes_data: DISCOVER_FILETYPES,
        products: discover_products,
        featured_collections: [
          { title: "Creator launch systems", description: "Pricing, analytics, interviews, and launch plans for first-dollar experiments." },
          { title: "Visual asset packs", description: "Brushes, mockups, LUTs, icons, and reference sets for production work." },
          { title: "Code and product templates", description: "Starter kits, recipes, and field notes for shipping software faster." },
        ],
      }.deep_dup
    end

    def discover_products
      CARD_NAMES.each_with_index.map do |(name, seller_name, taxonomy, native_type, price_cents), index|
        theme_start, theme_end = THEME_PAIRS[index % THEME_PAIRS.length]
        {
          id: "synthetic-product-#{index + 1}",
          permalink: name.parameterize,
          name:,
          seller: {
            id: "synthetic-seller-#{seller_name.parameterize}",
            name: seller_name,
            avatar_initials: seller_name.split.map(&:first).join.first(2).upcase,
            is_verified: index % 3 != 1,
          },
          ratings: {
            count: 48 + (index * 37) % 620,
            average: (4.2 + ((index % 7) * 0.1)).round(1),
          },
          thumbnail_theme: {
            start: theme_start,
            end: theme_end,
            accent: THEME_PAIRS[(index + 2) % THEME_PAIRS.length].first,
          },
          taxonomy:,
          native_type:,
          price_cents:,
          currency_code: "usd",
          is_pay_what_you_want: index % 11 == 0,
          sales_count_label: "#{(index + 2) * 113}+ sales",
        }
      end
    end
end
