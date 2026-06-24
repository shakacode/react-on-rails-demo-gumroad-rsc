# Public Buyer-Page Performance Results

## Latest Hosted A/B Run

Captured: `2026-06-23 23:56-23:58 HST` (`2026-06-24 UTC`)

Host: `https://gumroad.reactonrails.com`

Browser: local headless Chrome `149.0.7827.158` with ChromeDriver `149.0.7827.155`

Method: `8` alternating cycles per route pair, `2` server warmup requests per measured run, `--public`, and `--require-driver-match`.

These results compare the same synthetic production-shaped fixture data on the same deployed host. They are not a Lighthouse mobile-throttling result yet, so treat them as strong browser-navigation evidence and not the final mobile adoption claim.

Fixture provenance: [docs/public-page-fixture-sampling.md](public-page-fixture-sampling.md) documents the sanitized public Gumroad shape sampling used to build the synthetic Discover and product fixtures. The benchmark does not commit creator copy, seller URLs, product URLs, image URLs, or real product names.

## Headline Results

| Public surface | Inertia route | RSC route | Median nav duration | Median LCP start | JS requests | Inertia payload |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| Product detail | `/public_product/inertia_demo` | `/public_product/rsc_demo` | `811.50ms` -> `272.25ms` (`-66.5%`) | `368.00ms` -> `304.00ms` (`-17.4%`) | `7` -> `1` (`-85.7%`) | `12,183 B` -> none |
| Discover marketplace | `/public_product/discover_inertia_demo` | `/public_product/discover_rsc_demo` | `796.95ms` -> `283.75ms` (`-64.4%`) | `360.00ms` -> `322.00ms` (`-10.6%`) | `7` -> `1` (`-85.7%`) | `24,960 B` -> none |

## Supporting Metrics

| Surface | Metric | Inertia | RSC | Delta |
| --- | --- | ---: | ---: | ---: |
| Product detail | Average nav duration | `930.56ms` | `339.15ms` | `-63.6%` |
| Product detail | p95 nav duration | `1,401.38ms` | `637.69ms` | `-54.5%` |
| Product detail | Median response end | `215.60ms` | `214.10ms` | `-0.7%` |
| Product detail | Median HTML transfer | `5,702 B` | `9,105 B` | `+59.7%` |
| Product detail | Median JS transfer | `178,955 B` | `82,759 B` | `-53.8%` |
| Product detail | Median decoded JS/CSS | `1,174,356 B` | `611,242 B` | `-48.0%` |
| Discover marketplace | Average nav duration | `798.69ms` | `287.42ms` | `-64.0%` |
| Discover marketplace | p95 nav duration | `817.90ms` | `319.44ms` | `-60.9%` |
| Discover marketplace | Median response end | `211.50ms` | `218.20ms` | `+3.2%` |
| Discover marketplace | Median HTML transfer | `7,643 B` | `14,019 B` | `+83.4%` |
| Discover marketplace | Median JS transfer | `178,955 B` | `82,780 B` | `-53.7%` |
| Discover marketplace | Median decoded JS/CSS | `1,174,357 B` | `611,242 B` | `-48.0%` |

## Interpretation

This is the first deployed result that is compelling enough to keep pursuing the Gumroad-facing pitch.

- RSC wins the visible browser-navigation story on both public surfaces by about `64-66%` median navigation duration.
- RSC reduces route JS request count from `7` to `1` and cuts transferred route JS by about `54%`.
- RSC removes the Inertia `data-page` JSON payload from these public pages.
- RSC sends larger HTML because it streams rendered content instead of serializing a client-owned Inertia page payload.
- Discover has a small median `responseEnd` regression (`+3.2%`), so renderer and streaming-path profiling still matter.

## Reproduction Commands

```bash
ruby scripts/perf/compare_dashboard_routes.rb \
  --public \
  --base-url https://gumroad.reactonrails.com \
  --measure-base-url https://gumroad.reactonrails.com \
  --path /public_product/inertia_demo \
  --path /public_product/rsc_demo \
  --label hosted-public-product-alternating-8 \
  --cycles 8 \
  --server-warmup-requests 2 \
  --require-driver-match \
  --timeout 90

ruby scripts/perf/compare_dashboard_routes.rb \
  --public \
  --base-url https://gumroad.reactonrails.com \
  --measure-base-url https://gumroad.reactonrails.com \
  --path /public_product/discover_inertia_demo \
  --path /public_product/discover_rsc_demo \
  --label hosted-public-discover-alternating-8 \
  --cycles 8 \
  --server-warmup-requests 2 \
  --require-driver-match \
  --timeout 90
```

## Next Proof Gates

- Repeat as a mobile-throttled Lighthouse/ShakaPerf report with `LCP`, `TBT`, `INP`, total blocking time, and mobile score.
- Add renderer-internal timing for the React on Rails Pro streaming path.
- Repeat after adding a more realistic product-media payload, because images and responsive media are a major public product-page cost.
- If the mobile run preserves the navigation/LCP/client-JS advantage, convert this into a Gumroad-facing proposal focused on public product and Discover pages.
- For a stronger Gumroad-maintainer proof, wire sanitized production-shaped props into the real public `Discover/Index` and `Products/Discover/Show` components where feasible, then compare those pages with an RSC equivalent.
