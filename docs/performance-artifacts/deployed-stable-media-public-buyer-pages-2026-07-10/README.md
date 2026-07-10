# Stable media-bearing public buyer-page evidence (2026-07-10)

This directory is a fresh, independent capture from the stable public deployment at commit `cc61125b02ec0282ec455c044240e97b6a33b741`. It does not replace any historical evidence.

## Headline result

Across two independent batches per surface (8 alternating cycles per batch, 16 samples per route), the bounded RSC candidate reduced median full-navigation duration by 48.8% on Product and 42.6% on Discover. Product LCP improved 9.1%; Discover LCP improved 15.6% in the combined median but had visibly higher run-to-run noise. Response end was effectively tied on Product and inconclusive on Discover.

These results establish an end-to-end result for the routes as deployed. They do **not** isolate RSC as the only cause: the RSC routes use a dedicated client bundle and skip the legacy application JavaScript and third-party analytics loaded by the Inertia controls. Bundle isolation is part of the candidate architecture, but the third-party asymmetry is a parity gap that needs a separate controlled experiment.

## Method

- Stable host: <https://gumroad.reactonrails.com>
- Public mode, matching Chrome/ChromeDriver major version required
- Chrome 150.0.7871.49; ChromeDriver 150.0.7871.115; Selenium 4.45.0
- Apple M5 Max, 128 GiB, macOS 26.5.1, arm64; Ruby 3.4.3
- Two server warmup requests before each measured run
- Two independent batches of eight alternating cycles for Product and Discover
- Unthrottled desktop headless Chrome from Hawaii

The exact aggregate values and caveats are in [`summary.json`](summary.json). Each comparison JSON records cycle order, environment, browser versions, and paths to the 16 underlying run files.

In the captured comparison manifests, the historical `htmlTransferBytes` key is sourced from `PerformanceNavigationTiming.encodedBodySize`: it is the compressed response-body size and excludes response headers. Future manifests use the more precise `htmlEncodedBodyBytes` key. The raw manifests are preserved rather than rewritten. Likewise, the raw Discover runs share the legacy title `Gumroad Discover RSC benchmark` across both arms; route paths are authoritative, and the source now uses the equal-byte neutral title `Gumroad Discover A/B benchmark` for future captures.

## Files

- `deployed-stable-media-*-batch*-comparison.json`: four comparison manifests
- `deployed-stable-media-*-batch*-runs/`: 64 per-route measurements
- `public-page-resource-audit-mobile.json`: 390 x 844 mobile-emulated resource and image audit
- `public-page-resource-audit-desktop.json`: exact 1440 x 1100 resource and image audit

The resource audit intentionally records only source URLs, hosts, MIME types, dimensions, cache policy, and transfer metadata. No creator-owned media is copied into this repository.

## Reproduction

```bash
node scripts/perf/assert_public_demo_media_parity.mjs \
  --base-url "${TARGET_BASE_URL:-https://gumroad.reactonrails.com}"

ruby scripts/perf/compare_dashboard_routes.rb --public \
  --base-url https://gumroad.reactonrails.com \
  --measure-base-url https://gumroad.reactonrails.com \
  --path /public_product/inertia_demo \
  --path /public_product/rsc_demo \
  --label deployed-stable-media-product-YYYY-MM-DD-batch1 \
  --cycles 8 --server-warmup-requests 2 --require-driver-match --timeout 90

ruby scripts/perf/compare_dashboard_routes.rb --public \
  --base-url https://gumroad.reactonrails.com \
  --measure-base-url https://gumroad.reactonrails.com \
  --path /public_product/discover_inertia_demo \
  --path /public_product/discover_rsc_demo \
  --label deployed-stable-media-discover-YYYY-MM-DD-batch1 \
  --cycles 8 --server-warmup-requests 2 --require-driver-match --timeout 90

ruby scripts/perf/audit_public_page_resources.rb \
  --url https://gumroad.reactonrails.com/public_product/inertia_demo \
  --url https://gumroad.reactonrails.com/public_product/rsc_demo \
  --url https://gumroad.reactonrails.com/public_product/discover_inertia_demo \
  --url https://gumroad.reactonrails.com/public_product/discover_rsc_demo \
  --url 'https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search' \
  --url https://gumroad.com/discover \
  --output docs/performance-artifacts/DATE/public-page-resource-audit-mobile.json \
  --width 390 --height 844 --mobile --settle-seconds 3 --require-driver-match
```

Use a new dated directory and distinct batch labels for every rerun. Repeat each comparison command with a `batch2` label so batch-to-batch noise remains visible.

## Interpretation limits

The synthetic fixtures preserve public source attribution, but they are not byte-for-byte production replicas. Live Gumroad currently loads substantially more and more varied media, additional chrome, and many third-party requests. PageSpeed comparisons against live Gumroad are therefore diagnostic only until those factors are explicitly controlled or documented.
