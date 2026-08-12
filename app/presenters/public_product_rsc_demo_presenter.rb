# frozen_string_literal: true

require "shellwords"

class PublicProductRscDemoPresenter
  include Rails.application.routes.url_helpers

  HOSTED_DEMO_BASE_URL = "https://gumroad.reactonrails.com"
  REACT_ON_RAILS_URL = "https://reactonrails.com/"
  REACT_ON_RAILS_GITHUB_URL = "https://github.com/shakacode/react_on_rails"
  SHAKACODE_URL = "https://www.shakacode.com/"
  REACT_ON_RAILS_PRO_URL = "https://www.shakacode.com/react-on-rails-pro/"
  SHAKAPACKER_GITHUB_URL = "https://github.com/shakacode/shakapacker"
  CONSULTATION_URL = "https://meetings.hubspot.com/justingordon/30-minute-consultation"
  GUMROAD_DISCOVER_REFERENCE_URL = "https://gumroad.com/discover"
  GUMROAD_PRODUCT_REFERENCE_URL = "https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search"
  PAGE_SPEED_INSIGHTS_URL = "https://pagespeed.web.dev/analysis"
  DEMO_MEDIA_BASE_PATH = "/public-product-rsc-demo/media"
  PRODUCT_FIXTURE_IDENTITY = "public-product-rsc-demo-v1"
  PRODUCT_VARIANTS = {
    lab_clean: {
      name: "lab-clean",
      analytics: "disabled",
      legacy_application_javascript: false,
    },
    production_shaped: {
      name: "production-shaped",
      analytics: "enabled",
      legacy_application_javascript: true,
    },
  }.freeze

  REPO_URL = "https://github.com/shakacode/react-on-rails-demo-gumroad-rsc"
  REPO_SOURCE_BASE_URL = "#{REPO_URL}/blob/main"
  HOSTED_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/hosted-public-buyer-pages-2026-06-24/summary.json"
  LOCAL_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json"
  HOSTED_REVIEW_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json"
  DEPLOYED_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json"
  PRE_MEDIA_DEPLOYED_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json"
  MEDIA_REVIEW_BENCHMARK_ARTIFACT_PATH = "docs/performance-artifacts/hosted-review-pr69-media-public-buyer-pages-2026-07-09/summary.json"
  LIGHTHOUSE_COMPARATOR_ARTIFACT_PATH = "docs/performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json"
  NATIVE_SHAKAPERF_ARTIFACT_PATH = "docs/performance-artifacts/native-product-rsc-shakaperf-2026-08-12/summary.json"
  HISTORICAL_PERFORMANCE_PR_URL = "https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/69"
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

  BENCHMARK_METRICS = [
    { key: :median_navigation_duration_ms, label: "Navigation duration", unit: :ms },
    { key: :median_lcp_start_ms, label: "LCP start", unit: :ms },
    { key: :median_response_end_ms, label: "Response end (server TTLB)", unit: :ms },
    { key: :median_html_transfer_bytes, label: "HTML encoded body (headers excluded)", unit: :bytes },
    { key: :median_js_transfer_bytes, label: "JavaScript transfer (over the wire)", unit: :bytes },
    { key: :median_js_request_count, label: "JavaScript requests", unit: :count },
    { key: :median_decoded_js_css_bytes, label: "Decoded JavaScript + CSS", unit: :bytes },
    { key: :inertia_data_page_bytes, label: "Serialized Inertia payload", unit: :bytes },
  ].freeze

  PRODUCT_REFERENCE_SHAPE = "Products/Discover/Show"
  DISCOVER_REFERENCE_SHAPE = "Discover/Index"

  PRODUCT_PAGE = {
    permalink: "tendonbook",
    name: "Tendon Book",
    summary: "A practical ebook for athletes and coaches who want a clearer framework for tendon pain, loading progressions, and return-to-sport decisions.",
    native_type: "ebook",
    price_cents: 4700,
    currency_code: "usd",
    call_to_action: "Buy this",
    source_url: GUMROAD_PRODUCT_REFERENCE_URL,
    source_label: "Tendon Book by Jacked Athlete",
    cover_image_url: "#{DEMO_MEDIA_BASE_PATH}/tendon-book-cover.svg",
    seller: {
      name: "Jacked Athlete",
      tagline: "Training resources for tendon health and athletic performance",
      avatar_initials: "JA",
      is_verified: false,
    },
    ratings: {
      average: 5.0,
      count: 10,
      percentages: [0, 0, 0, 0, 100],
    },
    hero_stats: [
      { label: "Source price", value: "$47" },
      { label: "Rating", value: "5.0" },
      { label: "Reviews", value: "10" },
    ],
    cover_theme: {
      start: "#ffc900",
      end: "#23a094",
      accent: "#ff90e8",
    },
    bullets: [
      "Frame tendon pain with plain-language anatomy, loading concepts, and recovery milestones.",
      "Choose progressions that match the athlete's current tolerance instead of guessing from symptoms alone.",
      "Turn a static product page into a source-linked RSC benchmark with real public marketplace identity.",
    ],
    description_sections: [
      {
        heading: "Built from a live Gumroad comparator",
        body: "The fixture preserves the source title, seller, price, ebook type, rating summary, and link so the product story is visible before hydration without pretending the demo owns the creator's listing.",
      },
      {
        heading: "Lightly rewritten for a public demo",
        body: "Long explanatory copy is rewritten rather than copied, while the page still keeps enough above-the-fold content, recommendation cards, FAQ text, and buyer confidence details to make client JavaScript and serialized payload differences measurable.",
      },
      {
        heading: "Scientific enough to reproduce",
        body: "The source URL is part of the fixture, the demo URL is stable, and the lab provides PageSpeed rerun links so maintainers can compare the RSC route with the live Gumroad status quo.",
      },
    ],
    included_files: [
      { name: "Tendon education guide", description: "Rewritten demo summary of the ebook-style source material", filetype: "pdf" },
      { name: "Loading progression notes", description: "Public-page copy shaped for buyer confidence and crawlable content", filetype: "pdf" },
      { name: "Return-to-training checklist", description: "Benchmark content that stays source-attributed without copying long creator copy", filetype: "pdf" },
    ],
    faq: [
      {
        question: "Why benchmark a public product page?",
        answer: "It is logged out, SEO-sensitive, conversion-sensitive, and common on mobile. That is the surface where React Server Components must earn their complexity.",
      },
      {
        question: "Is this copied from the creator's listing?",
        answer: "No. The fixture preserves source identity fields and links back to Gumroad, but the longer descriptive text is rewritten for the benchmark demo.",
      },
      {
        question: "What would make the result compelling?",
        answer: "A meaningful win in LCP, navigation timing, client JavaScript, serialized payload, or mobile Lighthouse-style scores on the matched route pair and live URL comparator.",
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

  DISCOVER_PRODUCT_CARDS = [
    {
      name: "Launch Metrics OS",
      seller_name: "Metric Harbor",
      taxonomy: "business-and-money",
      native_type: "notion template",
      price_cents: 4900,
      summary: "Track launch experiments, preorders, revenue, refunds, and cohort notes from one founder dashboard.",
      format_label: "Notion + Sheets",
      audience_label: "Creator operators",
    },
    {
      name: "Pixel Brush Studio Kit",
      seller_name: "Palette Forge",
      taxonomy: "drawing-and-painting",
      native_type: "brush pack",
      price_cents: 2200,
      summary: "Layered sketch, ink, grain, and paint brushes tuned for commercial illustration workflows.",
      format_label: "Procreate",
      audience_label: "Illustrators",
    },
    {
      name: "Indie SaaS Pricing Lab",
      seller_name: "Lumen Works",
      taxonomy: "software-development",
      native_type: "workbook",
      price_cents: 5900,
      summary: "A pricing worksheet, competitor matrix, and upgrade-path calculator for small software products.",
      format_label: "PDF + spreadsheet",
      audience_label: "SaaS founders",
    },
    {
      name: "Creator Email Swipe File",
      seller_name: "Small Bet Supply",
      taxonomy: "writing-and-publishing",
      native_type: "templates",
      price_cents: 1900,
      summary: "Launch, nurture, discount, and win-back email drafts with notes on when each message is useful.",
      format_label: "Copy deck",
      audience_label: "Newsletter sellers",
    },
    {
      name: "Sound Pack: Glass Cities",
      seller_name: "Wave Table Club",
      taxonomy: "music-and-sound-design",
      native_type: "sample pack",
      price_cents: 2800,
      summary: "Clean plucks, skyline pads, and rhythmic one-shots for cinematic synth-pop production.",
      format_label: "WAV loops",
      audience_label: "Producers",
    },
    {
      name: "Notion Habit Dashboard",
      seller_name: "Useful Systems",
      taxonomy: "self-improvement",
      native_type: "notion template",
      price_cents: 1200,
      summary: "Daily habit logs, energy check-ins, weekly reviews, and streak views for lightweight accountability.",
      format_label: "Notion",
      audience_label: "Self trackers",
    },
    {
      name: "Mobile Photo Presets",
      seller_name: "Wildlight Lab",
      taxonomy: "photography",
      native_type: "preset pack",
      price_cents: 2400,
      summary: "Warm editorial presets for mobile creators who need consistent product and travel imagery.",
      format_label: "Lightroom",
      audience_label: "Photographers",
    },
    {
      name: "Course Outline Builder",
      seller_name: "Bright Stack",
      taxonomy: "education",
      native_type: "course template",
      price_cents: 3400,
      summary: "Turn a rough teaching idea into modules, lessons, assessments, and a launch checklist.",
      format_label: "Template kit",
      audience_label: "Educators",
    },
    {
      name: "Portfolio Type System",
      seller_name: "Signal Type Co.",
      taxonomy: "design",
      native_type: "font bundle",
      price_cents: 4200,
      summary: "A restrained display and text pairing with licensing notes for portfolio and case-study pages.",
      format_label: "OTF + WOFF",
      audience_label: "Designers",
    },
    {
      name: "API Client Starter",
      seller_name: "Shipyard Code",
      taxonomy: "software-development",
      native_type: "starter kit",
      price_cents: 6900,
      summary: "Typed request helpers, retry policies, fixtures, and docs for shipping a polished API client faster.",
      format_label: "TypeScript",
      audience_label: "Developers",
    },
    {
      name: "Freelance Proposal Vault",
      seller_name: "Paper Trail Studio",
      taxonomy: "business-and-money",
      native_type: "templates",
      price_cents: 2700,
      summary: "Proposal, scope, pricing, and kickoff templates for repeatable client-service sales.",
      format_label: "Docs",
      audience_label: "Freelancers",
    },
    {
      name: "Storyboard Procreate Pack",
      seller_name: "Frame Garden",
      taxonomy: "drawing-and-painting",
      native_type: "brush pack",
      price_cents: 2500,
      summary: "Panel guides, pencil brushes, speech bubble stamps, and thumbnails for visual story planning.",
      format_label: "Procreate",
      audience_label: "Story artists",
    },
    {
      name: "Yoga Class Planner",
      seller_name: "Studio Reset",
      taxonomy: "fitness-and-health",
      native_type: "planner",
      price_cents: 1800,
      summary: "Sequence cards, class themes, music prompts, and seasonal planning pages for studio teachers.",
      format_label: "PDF",
      audience_label: "Instructors",
    },
    {
      name: "Synthwave Loop Library",
      seller_name: "Neon Tape",
      taxonomy: "music-and-sound-design",
      native_type: "loops",
      price_cents: 3600,
      summary: "Arps, basslines, fills, and drum loops inspired by retro soundtrack production.",
      format_label: "Audio pack",
      audience_label: "Musicians",
    },
    {
      name: "Newsletter Growth Map",
      seller_name: "Tiny Audience",
      taxonomy: "business-and-money",
      native_type: "guide",
      price_cents: 3100,
      summary: "A practical map for referral loops, content pillars, paid offers, and subscriber research.",
      format_label: "PDF guide",
      audience_label: "Writers",
    },
    {
      name: "Rails Performance Notes",
      seller_name: "Full Stack Field",
      taxonomy: "software-development",
      native_type: "ebook",
      price_cents: 3900,
      summary: "Field notes on request profiling, fragment caching, slow SQL, and production observability.",
      format_label: "eBook",
      audience_label: "Rails teams",
    },
    {
      name: "Editorial Mockup Kit",
      seller_name: "Offset Objects",
      taxonomy: "design",
      native_type: "mockups",
      price_cents: 2900,
      summary: "Magazine, booklet, poster, and social mockups for showing brand systems in context.",
      format_label: "PSD scenes",
      audience_label: "Brand designers",
    },
    {
      name: "Digital Product Tax Checklist",
      seller_name: "Ledger Light",
      taxonomy: "business-and-money",
      native_type: "checklist",
      price_cents: 1500,
      summary: "Plain-language prompts for collecting tax questions before a creator talks to an accountant.",
      format_label: "Checklist",
      audience_label: "Shop owners",
    },
    {
      name: "Character Pose Reference",
      seller_name: "Draw Daily",
      taxonomy: "drawing-and-painting",
      native_type: "reference pack",
      price_cents: 2100,
      summary: "Action, sitting, hand, and silhouette references for speeding up character studies.",
      format_label: "Image pack",
      audience_label: "Artists",
    },
    {
      name: "Meditation Audio Starter",
      seller_name: "Quiet Habit",
      taxonomy: "self-improvement",
      native_type: "audio course",
      price_cents: 1700,
      summary: "Short guided sessions, reflection prompts, and practice notes for building a daily routine.",
      format_label: "MP3 + PDF",
      audience_label: "Beginners",
    },
    {
      name: "Customer Interview Script",
      seller_name: "Research Bench",
      taxonomy: "business-and-money",
      native_type: "script pack",
      price_cents: 1600,
      summary: "Question banks, call agendas, and synthesis pages for validating a product idea.",
      format_label: "Docs",
      audience_label: "Product teams",
    },
    {
      name: "Frontend Pattern Cards",
      seller_name: "Interface Kitchen",
      taxonomy: "software-development",
      native_type: "reference deck",
      price_cents: 3300,
      summary: "Reusable interface patterns for forms, empty states, tables, and product onboarding flows.",
      format_label: "Cards",
      audience_label: "UI engineers",
    },
    {
      name: "Film LUT Collection",
      seller_name: "Color Cabin",
      taxonomy: "films",
      native_type: "luts",
      price_cents: 2600,
      summary: "Neutral, warm, and high-contrast looks for creators who need consistent video color.",
      format_label: "LUT pack",
      audience_label: "Video editors",
    },
    {
      name: "Micro Course Sales Page",
      seller_name: "Launch Shelf",
      taxonomy: "education",
      native_type: "template",
      price_cents: 4500,
      summary: "A sales-page wireframe, headline prompts, proof blocks, FAQ patterns, and offer checklist.",
      format_label: "Figma + docs",
      audience_label: "Course sellers",
    },
    {
      name: "Icon Grid System",
      seller_name: "Vector Mill",
      taxonomy: "design",
      native_type: "asset pack",
      price_cents: 2300,
      summary: "Grid rules, starter icons, stroke guidance, and export presets for a cohesive icon set.",
      format_label: "SVG + Figma",
      audience_label: "Product designers",
    },
    {
      name: "Ambient Texture Library",
      seller_name: "Field Audio Lab",
      taxonomy: "music-and-sound-design",
      native_type: "sound library",
      price_cents: 3200,
      summary: "Room tones, paper movement, field beds, and subtle loops for podcasts and video essays.",
      format_label: "WAV",
      audience_label: "Editors",
    },
    {
      name: "Creator Finance Tracker",
      seller_name: "Metric Harbor",
      taxonomy: "business-and-money",
      native_type: "spreadsheet",
      price_cents: 2100,
      summary: "Monthly revenue, expense, tax set-aside, and launch-cost tracking for solo digital shops.",
      format_label: "Sheets",
      audience_label: "Creators",
    },
    {
      name: "3D Product Render Basics",
      seller_name: "Render Room",
      taxonomy: "3d",
      native_type: "video lessons",
      price_cents: 5300,
      summary: "Short lessons on lighting, cameras, materials, and export settings for product mockups.",
      format_label: "Video course",
      audience_label: "3D learners",
    },
    {
      name: "Writing Sprint Planner",
      seller_name: "Inkline Studio",
      taxonomy: "writing-and-publishing",
      native_type: "planner",
      price_cents: 900,
      summary: "A compact planning system for drafting essays, newsletters, chapters, and product copy.",
      format_label: "PDF",
      audience_label: "Writers",
    },
    {
      name: "Landing Page Copy Blocks",
      seller_name: "Conversion Cottage",
      taxonomy: "business-and-money",
      native_type: "copy kit",
      price_cents: 3700,
      summary: "Benefit, proof, pricing, FAQ, and objection-handling blocks for lightweight sales pages.",
      format_label: "Copy kit",
      audience_label: "Founders",
    },
    {
      name: "Game UI Button Pack",
      seller_name: "Sprite Foundry",
      taxonomy: "gaming",
      native_type: "asset pack",
      price_cents: 1900,
      summary: "Menu buttons, states, sound cues, and export notes for polished casual-game interfaces.",
      format_label: "PNG + SVG",
      audience_label: "Game makers",
    },
    {
      name: "Low Content Book Interiors",
      seller_name: "Print Meadow",
      taxonomy: "writing-and-publishing",
      native_type: "templates",
      price_cents: 2500,
      summary: "Planner, journal, tracker, and workbook interiors prepared for print-on-demand workflows.",
      format_label: "PDF + InDesign",
      audience_label: "Publishers",
    },
    {
      name: "Personal CRM Blueprint",
      seller_name: "Useful Systems",
      taxonomy: "self-improvement",
      native_type: "notion template",
      price_cents: 1400,
      summary: "A relationship tracker with reminders, context notes, follow-up prompts, and weekly review views.",
      format_label: "Notion",
      audience_label: "Network builders",
    },
    {
      name: "Podcast Edit Checklist",
      seller_name: "Wave Table Club",
      taxonomy: "audio",
      native_type: "checklist",
      price_cents: 1100,
      summary: "Preflight, edit, mix, export, transcript, and publishing checks for consistent podcast releases.",
      format_label: "Checklist",
      audience_label: "Podcasters",
    },
    {
      name: "Customer Support Macros",
      seller_name: "Help Desk Garden",
      taxonomy: "business-and-money",
      native_type: "templates",
      price_cents: 1800,
      summary: "Refund, access, billing, bug, and onboarding replies written for small product support teams.",
      format_label: "Macros",
      audience_label: "Support teams",
    },
    {
      name: "React Form Recipes",
      seller_name: "Shipyard Code",
      taxonomy: "software-development",
      native_type: "code examples",
      price_cents: 4100,
      summary: "Accessible form patterns for validation, optimistic submission, file fields, and error recovery.",
      format_label: "React",
      audience_label: "Frontend teams",
    },
  ].freeze

  THEME_PAIRS = [
    ["#ff90e8", "#23a094"],
    ["#ffc900", "#ff7051"],
    ["#90a8ed", "#7f5af0"],
    ["#23a094", "#f1f333"],
    ["#ff7051", "#ffc900"],
    ["#f1f333", "#ff90e8"],
  ].freeze

  DISCOVER_MEDIA_FILES = [
    "marketplace-analytics.svg",
    "marketplace-brushes.svg",
    "marketplace-code.svg",
    "marketplace-email.svg",
    "marketplace-audio.svg",
    "marketplace-habits.svg",
    "marketplace-photo.svg",
    "marketplace-course.svg",
  ].freeze

  attr_reader :request

  def initialize(request:)
    @request = request
  end

  def product_props(variant: nil)
    props = shared_props(variant:).merge(
      page_kind: "product",
      product_page: product_fixture,
      discover_page: nil
    )
    props[:benchmark_variant] = product_variant_identity(variant) if variant
    props
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
    "Gumroad Discover A/B benchmark"
  end

  def discover_description
    "A production-shaped, synthetic Discover listing fixture comparing Inertia and React Server Components via React on Rails Pro."
  end

  def self.hosted_benchmark
    @hosted_benchmark ||= read_benchmark(HOSTED_BENCHMARK_ARTIFACT_PATH)
  end

  def self.local_benchmark
    @local_benchmark ||= read_benchmark(LOCAL_BENCHMARK_ARTIFACT_PATH)
  end

  def self.deployed_benchmark
    @deployed_benchmark ||= read_benchmark(DEPLOYED_BENCHMARK_ARTIFACT_PATH)
  end

  def self.media_review_benchmark
    @media_review_benchmark ||= read_benchmark(MEDIA_REVIEW_BENCHMARK_ARTIFACT_PATH)
  end

  def self.lighthouse_comparator
    @lighthouse_comparator ||= read_benchmark(LIGHTHOUSE_COMPARATOR_ARTIFACT_PATH)
  end

  def self.native_shakaperf_benchmark
    @native_shakaperf_benchmark ||= read_benchmark(NATIVE_SHAKAPERF_ARTIFACT_PATH)
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

  def implementation_source_links
    [
      source_link("controller", CONTROLLER_SOURCE_PATH),
      source_link("fixtures", PRESENTER_SOURCE_PATH),
    ]
  end

  def hosted_benchmark_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{HOSTED_BENCHMARK_ARTIFACT_PATH}"
  end

  def local_benchmark_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{LOCAL_BENCHMARK_ARTIFACT_PATH}"
  end

  def hosted_review_benchmark_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{HOSTED_REVIEW_BENCHMARK_ARTIFACT_PATH}"
  end

  def deployed_benchmark_artifact_url
    "#{current_repo_source_base_url}/#{DEPLOYED_BENCHMARK_ARTIFACT_PATH}"
  end

  def pre_media_deployed_benchmark_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{PRE_MEDIA_DEPLOYED_BENCHMARK_ARTIFACT_PATH}"
  end

  def media_review_benchmark_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{MEDIA_REVIEW_BENCHMARK_ARTIFACT_PATH}"
  end

  def lighthouse_comparator_artifact_url
    "#{REPO_SOURCE_BASE_URL}/#{LIGHTHOUSE_COMPARATOR_ARTIFACT_PATH}"
  end

  def native_shakaperf_artifact_url
    "#{current_repo_source_base_url}/#{NATIVE_SHAKAPERF_ARTIFACT_PATH}"
  end

  def native_shakaperf_benchmark
    self.class.native_shakaperf_benchmark || {}
  end

  def native_shakaperf_result_cards
    native_shakaperf_benchmark.fetch(:results, []).map do |result|
      {
        label: result.fetch(:label).sub(" seeded product", ""),
        control_url: result.fetch(:control_url),
        experiment_url: result.fetch(:experiment_url),
        wins: native_shakaperf_metrics(result, ["FCP", "LCP", "CLS", "Lighthouse score", "JavaScript requests", "All requests"]),
        costs: native_shakaperf_metrics(result, ["TTFB", "JavaScript transfer", "All downloads", "TBT"]),
        quality: result.fetch(:quality),
      }
    end
  end

  def native_shakaperf_headline_metrics
    results = native_shakaperf_result_cards
    return [] if results.empty?

    [
      native_shakaperf_cross_product_metric(results, "FCP", "First paint", :win),
      native_shakaperf_cross_product_metric(results, "LCP", "Largest paint", :win),
      native_shakaperf_cross_product_metric(results, "JavaScript requests", "JS requests", :win),
      native_shakaperf_cross_product_metric(results, "All downloads", "Transferred bytes", :cost),
    ]
  end

  def native_shakaperf_scorecards
    native_shakaperf_result_cards.map do |result|
      metric = result.fetch(:wins).find { |item| item[:key] == "Lighthouse score" }
      result.slice(:label).merge(
        metric:,
        control_score: metric.fetch(:control).to_i,
        experiment_score: metric.fetch(:experiment).to_i
      )
    end
  end

  def native_shakaperf_explanation_steps
    [
      {
        number: "01",
        title: "HTML arrives rendered",
        detail: "RSC streams the real product DOM; Inertia sends props and waits for JavaScript to construct it.",
      },
      {
        number: "02",
        title: "41 requests become 3",
        detail: "The dedicated RSC entry avoids the control's legacy pack request waterfall.",
      },
      {
        number: "03",
        title: "Paint moves forward",
        detail: "Fewer round trips and stable server-rendered layout improve FCP, LCP, and CLS.",
      },
    ]
  end

  def media_review_benchmark_method_note
    benchmark_method_note(self.class.media_review_benchmark)
  end

  def local_benchmark_method_note
    benchmark_method_note(self.class.local_benchmark)
  end

  def deployed_benchmark_method_note
    benchmark_method_note(self.class.deployed_benchmark)
  end

  def hosted_benchmark_method_note
    benchmark_method_note(self.class.hosted_benchmark)
  end

  def local_benchmark_caveats
    self.class.local_benchmark&.dig(:caveats) || []
  end

  def deployed_benchmark_caveats
    self.class.deployed_benchmark&.dig(:caveats) || []
  end

  def media_review_benchmark_caveats
    self.class.media_review_benchmark&.dig(:caveats) || []
  end

  def hosted_benchmark_caveats
    self.class.hosted_benchmark&.dig(:caveats) || []
  end

  def react_stack_versions
    {
      react: package_dependency_version("react"),
      react_dom: package_dependency_version("react-dom"),
      react_on_rails_pro_gem: Gem.loaded_specs["react_on_rails_pro"]&.version&.to_s,
      react_on_rails_pro_npm: package_dependency_version("react-on-rails-pro"),
      react_on_rails_rsc: package_dependency_version("react-on-rails-rsc"),
    }.compact
  end

  def page_speed_comparator_pairs
    [
      page_speed_comparator_pair(
        surface: "Product detail",
        demo_url: current_demo_url(public_product_rsc_demo_path),
        deployed_demo_url: hosted_demo_url(public_product_rsc_demo_path),
        live_url: GUMROAD_PRODUCT_REFERENCE_URL
      ),
      page_speed_comparator_pair(
        surface: "Discover marketplace",
        demo_url: current_demo_url(public_product_discover_rsc_demo_path),
        deployed_demo_url: hosted_demo_url(public_product_discover_rsc_demo_path),
        live_url: GUMROAD_DISCOVER_REFERENCE_URL
      ),
    ]
  end

  def comparison_terms
    [
      {
        label: "Matched Inertia control",
        eyebrow: "Same-fixture A/B baseline",
        description: "The before route inside this demo app. It uses the same fixture data, same host, and same Ruby/Selenium harness as the RSC candidate. It is not live gumroad.com production.",
        href: public_product_inertia_demo_path,
      },
      {
        label: "This host RSC demo",
        eyebrow: "Review app, local app, or deployed app",
        description: "The RSC candidate served from the host in your address bar. On a review app, PageSpeed links point at that review app; locally they point at your local host.",
        href: current_demo_url(public_product_rsc_demo_path),
      },
      {
        label: "Stable deployed RSC demo",
        eyebrow: HOSTED_DEMO_BASE_URL,
        description: "The public demo deployment used for the headline hosted Selenium artifacts. This is the stable URL to share when the review app is gone.",
        href: hosted_demo_url(public_product_rsc_demo_path),
      },
      {
        label: "Live Gumroad reference",
        eyebrow: "External status quo",
        description: "The real Gumroad product or Discover page used for PageSpeed diagnostics. It is not valid proof until media, chrome, and production-service differences are accounted for.",
        href: GUMROAD_PRODUCT_REFERENCE_URL,
      },
    ]
  end

  def performance_evidence_cards
    [
      shakaperf_evidence_card(:product, "Product navigation"),
      shakaperf_evidence_card(:discover, "Discover navigation"),
      page_speed_diagnostic_card,
    ].compact
  end

  def executive_summary
    %i[product discover].to_h do |key|
      result = benchmark_result(key)
      next [key, {}] if result.nil?

      navigation = result.fetch(:median_navigation_duration_ms)
      response_end = result.fetch(:median_response_end_ms)
      html = result.fetch(:median_html_transfer_bytes)
      javascript = result.fetch(:median_js_transfer_bytes)
      inertia_wire_bytes = html.fetch(:inertia) + javascript.fetch(:inertia)
      rsc_wire_bytes = html.fetch(:rsc) + javascript.fetch(:rsc)
      html_cost_bytes = html.fetch(:rsc) - html.fetch(:inertia)
      response_label = response_end.fetch(:delta_percent).abs <= 1 ? "About the same" : "Inconclusive"

      [
        key,
        {
          navigation_delta: format_delta_percent(navigation.fetch(:delta_percent)),
          total_wire_delta: format_delta_percent(computed_percent(inertia_wire_bytes, rsc_wire_bytes)),
          html_cost: "#{format_signed_metric(html_cost_bytes, :bytes)} (#{format_delta_percent(html.fetch(:delta_percent))})",
          response_end: "#{response_label} (#{format_delta_percent(response_end.fetch(:delta_percent))})",
        },
      ]
    end
  end

  def performance_claim_status_cards
    [
      {
        step: "1",
        label: "Current measured status",
        title: "Actual ShakaPerf CLI A/B",
        body: "The native RSC product pages improve FCP, LCP, Lighthouse score, and request count, but regress TTFB and transferred bytes. The CLI therefore exits nonzero rather than declaring an overall win.",
        href: "#native-shakaperf-result",
        link_label: "Read the complete result",
      },
      {
        step: "2",
        label: "Diagnostic only",
        title: "PageSpeed against live Gumroad",
        body: "Useful for inspecting production gaps, but not proof today. Resource audits show different media, chrome, caching, fonts, and third-party services.",
        href: "#pagespeed-comparator-pairs",
        link_label: "Open comparator links",
        tone: "warning",
      },
      {
        step: "3",
        label: "Before rollout",
        title: "Production parity + field data",
        body: "The native CLI run exists. The remaining gate is equivalent production chrome and analytics, lower TTFB and bundle weight, then real-user LCP, INP, availability, and conversion.",
        href: "#react-on-rails-pro-17-audit",
        link_label: "Review rollout gates",
      },
    ]
  end

  def native_shakaperf_metric(result, key)
    (result[:wins] + result[:costs]).find { |metric| metric[:key] == key }
  end

  def shakaperf_reproduction_commands
    method = self.class.deployed_benchmark&.dig(:method) || {}
    batch_count = method[:independent_batches] || 1
    surfaces = [
      {
        label: "Product detail pair",
        inertia_path: public_product_inertia_demo_path,
        rsc_path: public_product_rsc_demo_path,
        label_slug: "current-host-public-product-alternating-8",
      },
      {
        label: "Discover pair",
        inertia_path: public_product_discover_inertia_demo_path,
        rsc_path: public_product_discover_rsc_demo_path,
        label_slug: "current-host-public-discover-alternating-8",
      },
    ]

    surfaces.flat_map do |surface|
      1.upto(batch_count).map do |batch|
        shakaperf_reproduction_command(
          label: "#{surface[:label]}, batch #{batch}",
          inertia_path: surface[:inertia_path],
          rsc_path: surface[:rsc_path],
          label_slug: "#{surface[:label_slug]}-batch#{batch}",
          method:
        )
      end
    end
  end

  def deployed_performance_demo_url
    hosted_demo_url(public_product_performance_demo_path)
  end

  def local_benchmark_surfaces
    benchmark_surfaces(self.class.local_benchmark)
  end

  def deployed_benchmark_surfaces
    benchmark_surfaces(self.class.deployed_benchmark)
  end

  def media_review_benchmark_surfaces
    benchmark_surfaces(self.class.media_review_benchmark)
  end

  def hosted_benchmark_surfaces
    benchmark_surfaces(self.class.hosted_benchmark)
  end

  private

    def native_shakaperf_metrics(result, keys)
      keys.filter_map do |key|
        metric = result.fetch(:metrics).find { |candidate| candidate.fetch(:label).start_with?(key) }
        next if metric.nil?

        {
          key:,
          label: metric.fetch(:label).sub(/ \(.+\)\z/, ""),
          control: metric.fetch(:control),
          experiment: metric.fetch(:experiment),
          change: metric.fetch(:change),
          p_value: metric.fetch(:p_value),
        }
      end
    end

    def native_shakaperf_cross_product_metric(results, key, label, tone)
      metrics = results.map { |result| native_shakaperf_metric(result, key) }
      {
        label:,
        tone:,
        change: compact_paired_value(metrics.map { |metric| metric.fetch(:change) }),
        values: results.zip(metrics).map do |result, metric|
          "#{result.fetch(:label)} #{metric.fetch(:control)} → #{metric.fetch(:experiment)}"
        end,
      }
    end

    def compact_paired_value(values)
      values.uniq.one? ? values.first : values.join(" / ")
    end
    def self.read_benchmark(path)
      JSON.parse(File.read(Rails.root.join(path)), symbolize_names: true)
    rescue StandardError
      nil
    end
    private_class_method :read_benchmark

    def benchmark_method_note(data)
      return if data.nil?

      browser = data[:browser] || {}
      method = data[:method] || {}
      captured_at = data[:captured_at_utc] || data[:captured_at_utc_date]
      host = method[:measure_base_url] || method[:base_url] || data[:host]
      cycles = method[:cycles_per_pair] || method[:cycles]
      batches = method[:independent_batches]
      browser_label = method[:browser] || [browser[:name], browser[:version]].compact.join(" ")
      cycle_label = batches ? "#{batches} independent batches of #{cycles} alternating cycles" : "#{cycles} alternating cycles"
      "Captured #{captured_at} against #{host} with headless #{browser_label}, " \
        "#{cycle_label}, and #{method[:server_warmup_requests_per_run]} warmup requests per measured run."
    end

    def hosted_demo_url(path)
      "#{HOSTED_DEMO_BASE_URL}#{path}"
    end

    def current_demo_url(path)
      "#{request.base_url}#{path}"
    end

    def page_speed_comparator_pair(surface:, demo_url:, deployed_demo_url:, live_url:)
      {
        surface:,
        demo_url:,
        deployed_demo_url:,
        live_url:,
        mobile_demo_page_speed_url: page_speed_url(demo_url, strategy: "mobile"),
        mobile_deployed_demo_page_speed_url: page_speed_url(deployed_demo_url, strategy: "mobile"),
        mobile_live_page_speed_url: page_speed_url(live_url, strategy: "mobile"),
        desktop_demo_page_speed_url: page_speed_url(demo_url, strategy: "desktop"),
        desktop_deployed_demo_page_speed_url: page_speed_url(deployed_demo_url, strategy: "desktop"),
        desktop_live_page_speed_url: page_speed_url(live_url, strategy: "desktop"),
      }
    end

    def page_speed_url(url, strategy:)
      "#{PAGE_SPEED_INSIGHTS_URL}?url=#{CGI.escape(url)}&strategy=#{strategy}"
    end

    def source_link(label, path)
      { label:, url: "#{current_repo_source_base_url}/#{path}" }
    end

    def current_repo_source_base_url
      return REPO_SOURCE_BASE_URL if request.base_url == HOSTED_DEMO_BASE_URL

      "#{REPO_URL}/blob/#{current_repo_ref}"
    end

    def current_repo_ref
      image_commit = [ENV["GITHUB_SHA"], ENV["GIT_COMMIT"]]
        .find { |value| value.to_s.match?(/\A[0-9a-f]{40}\z/i) }

      image_commit || ENV["SOURCE_REF"].presence || "main"
    end

    def package_dependency_version(name)
      package_json.dig("dependencies", name)&.delete_prefix("^")
    end

    def package_json
      return @package_json if defined?(@package_json)

      @package_json = begin
        JSON.parse(File.read(Rails.root.join("package.json")))
      rescue StandardError
        {}
      end
    end

    def benchmark_surfaces(data)
      (data&.dig(:results) || []).map do |result|
        {
          surface: result[:surface],
          page_kind: result[:candidate_path].to_s.include?("discover") ? :discover : :product,
          rows: benchmark_rows(result),
        }
      end
    end

    def benchmark_result(key, data: self.class.deployed_benchmark)
      (data&.fetch(:results, []) || []).find { |result| result[:key] == key.to_s }
    end

    def shakaperf_evidence_card(key, label)
      result = benchmark_result(key)
      navigation = result&.fetch(:median_navigation_duration_ms, nil)
      return if navigation.blank?

      {
        eyebrow: "Stable media-bearing Selenium A/B",
        label:,
        value: "#{format_metric(navigation[:inertia], :ms)} -> #{format_metric(navigation[:rsc], :ms)}",
        delta: format_delta_percent(navigation[:delta_percent]),
        note: "Matched Inertia control to React on Rails Pro RSC across two independent stable-deployment batches.",
      }
    end

    def page_speed_diagnostic_card
      {
        eyebrow: "External PageSpeed",
        label: "Diagnostic only",
        value: "Needs controlled parity",
        delta: "Not evidence yet",
        note: "Live Gumroad loads different media, chrome, caching, and third parties; inspect gaps without treating scores as proof.",
        tone: "warning",
      }
    end

    def shakaperf_reproduction_command(label:, inertia_path:, rsc_path:, label_slug:, method:)
      command = [
        "ruby", "scripts/perf/compare_dashboard_routes.rb",
        "--public",
        "--base-url", request.base_url,
        "--measure-base-url", request.base_url,
        "--path", inertia_path,
        "--path", rsc_path,
        "--label", label_slug,
        "--cycles", (method[:cycles_per_pair] || method[:cycles] || 8).to_s,
        "--server-warmup-requests", (method[:server_warmup_requests_per_run] || 2).to_s,
      ]
      command << "--require-driver-match" if method[:require_driver_match] != false
      command.concat(["--timeout", "90"])

      {
        label:,
        host: request.base_url,
        command: Shellwords.join(command),
      }
    end

    def benchmark_rows(result)
      rows = BENCHMARK_METRICS.filter_map do |metric|
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

    def format_signed_metric(value, unit)
      sign = value.negative? ? "-" : "+"
      "#{sign}#{format_metric(value.abs, unit)}"
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

    def shared_props(variant: nil)
      {
        locale: I18n.locale.to_s,
        source_note: [
          "Product fixture source: Tendon Book by Jacked Athlete, linked back to Gumroad with title, seller, price, type, and rating identity preserved.",
          "Long copy is rewritten for the demo. Discover shape still follows public Gumroad #{DISCOVER_REFERENCE_SHAPE} data:",
          "36-card grid, 8 tag/filetype buckets, taxonomy nav, and product seller/cover/rating/purchase fields.",
        ].join(" "),
        comparison: comparison_links(variant:),
      }
    end

    def comparison_links(variant: nil)
      product_inertia_url, product_rsc_url = product_variant_paths(variant)
      {
        home_url: about_path,
        performance_url: public_product_performance_demo_path,
        deployed_performance_url: deployed_performance_demo_url,
        inertia_url: product_inertia_url,
        rsc_url: product_rsc_url,
        product_inertia_url: product_inertia_url,
        product_rsc_url: product_rsc_url,
        discover_inertia_url: public_product_discover_inertia_demo_path,
        discover_rsc_url: public_product_discover_rsc_demo_path,
        react_on_rails_url: REACT_ON_RAILS_URL,
        react_on_rails_github_url: REACT_ON_RAILS_GITHUB_URL,
        shakacode_url: SHAKACODE_URL,
        consultation_url: CONSULTATION_URL,
        gumroad_product_reference_url: GUMROAD_PRODUCT_REFERENCE_URL,
        gumroad_discover_reference_url: GUMROAD_DISCOVER_REFERENCE_URL,
      }
    end

    def product_variant_identity(variant)
      profile = PRODUCT_VARIANTS.fetch(variant)
      profile.merge(
        fixture_identity: PRODUCT_FIXTURE_IDENTITY,
        inertia_path: product_variant_paths(variant).first,
        rsc_path: product_variant_paths(variant).last,
      )
    end

    def product_variant_paths(variant)
      case variant
      when :lab_clean
        [public_product_lab_clean_inertia_demo_path, public_product_lab_clean_rsc_demo_path]
      when :production_shaped
        [public_product_production_shaped_inertia_demo_path, public_product_production_shaped_rsc_demo_path]
      else
        [public_product_inertia_demo_path, public_product_rsc_demo_path]
      end
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
      DISCOVER_PRODUCT_CARDS.each_with_index.map do |card, index|
        theme_start, theme_end = THEME_PAIRS[index % THEME_PAIRS.length]
        seller_name = card.fetch(:seller_name)
        {
          id: "synthetic-product-#{index + 1}",
          permalink: card.fetch(:name).parameterize,
          name: card.fetch(:name),
          summary: card.fetch(:summary),
          audience_label: card.fetch(:audience_label),
          format_label: card.fetch(:format_label),
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
          thumbnail_image_url: "#{DEMO_MEDIA_BASE_PATH}/#{DISCOVER_MEDIA_FILES[index % DISCOVER_MEDIA_FILES.length]}",
          thumbnail_theme: {
            start: theme_start,
            end: theme_end,
            accent: THEME_PAIRS[(index + 2) % THEME_PAIRS.length].first,
          },
          taxonomy: card.fetch(:taxonomy),
          native_type: card.fetch(:native_type),
          price_cents: card.fetch(:price_cents),
          currency_code: "usd",
          is_pay_what_you_want: index % 11 == 0,
          sales_count_label: "#{(index + 2) * 113}+ sales",
        }
      end
    end
end
