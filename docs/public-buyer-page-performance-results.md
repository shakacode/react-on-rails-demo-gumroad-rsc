# Public Buyer-Page Performance Results

## Current Stable Media-Bearing A/B Run

Captured July 10, 2026 UTC from `https://gumroad.reactonrails.com` at main
commit `cc61125b02ec0282ec455c044240e97b6a33b741`.

Method: two independent batches per surface, eight alternating cycles per
batch, two server warmups per measured run, public mode, and an enforced Chrome
`150.0.7871.49` / ChromeDriver `150.0.7871.115` major-version match. The run is
unthrottled desktop headless Chrome, not mobile field data.

| Public surface | Median navigation | Median response end | Median LCP | JS transfer | Inertia payload |
| --- | ---: | ---: | ---: | ---: | ---: |
| Product detail | `1123.5ms` -> `575.0ms` (`-48.8%`) | `504.85ms` -> `509.55ms` (`+0.9%`) | `662ms` -> `602ms` (`-9.1%`) | `162,696 B` -> `82,228.5 B` (`-49.5%`) | `15,040 B` -> none |
| Discover marketplace | `1097.9ms` -> `630.45ms` (`-42.6%`) | `473.9ms` -> `492.8ms` (`+4.0%`) | `768ms` -> `648ms` (`-15.6%`) | `162,696 B` -> `82,223 B` (`-49.5%`) | `33,966 B` -> none |

Verdict: full navigation is clearly faster for the RSC candidate. Product LCP
is modestly better; Discover LCP is directionally better but noisy. Response
end is a tie/inconclusive, not an RSC win. RSC's combined-median encoded HTML
body (compressed, headers excluded) is 80.4% larger on Product and 100.2%
larger on Discover, while JavaScript transfer is roughly halved.

This is an end-to-end route result, not a clean estimate of RSC in isolation.
The RSC route uses an isolated bundle and skips legacy application JavaScript;
the Inertia control also loads analytics and tag-manager resources omitted by
the RSC route. Preserve that limitation when quoting the result.

The summary, four comparison manifests, 64 underlying run files, and desktop/mobile
resource audits are in
[performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md).

## Historical Hosted A/B Run

Captured: `2026-06-23 23:56-23:58 HST` (`2026-06-24 UTC`)

Host: `https://gumroad.reactonrails.com`

Browser: local headless Chrome `149.0.7827.158` with ChromeDriver `149.0.7827.155`

Method: `8` alternating cycles per route pair, `2` server warmup requests per measured run, `--public`, and `--require-driver-match`.

These results compare the same synthetic production-shaped fixture data on the same deployed host as of June 24, 2026. They predate the Tendon Book attributed fixture added on July 8, 2026, so treat them as historical hosted evidence for JavaScript request and transfer deltas, not the current headline same-fixture result. The current stable media-bearing artifact is [performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json); the previous stable pre-media artifact remains historical at [performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json).

Note: this run predates the React on Rails Pro 17 stream observability toggle now enabled on the public RSC routes. The current stable media-bearing run preserves the same route pairs while capturing streamed shell and Node renderer prepare attribution in `Server-Timing`.

Fixture provenance: [docs/public-page-fixture-sampling.md](public-page-fixture-sampling.md) documents the sanitized public Gumroad shape sampling used to build the synthetic Discover and product fixtures. The benchmark does not commit creator copy, seller URLs, product URLs, or real product names. Newer branches add local synthetic image fixtures; this historical run predates that media.

## Historical Results

| Public surface       | Inertia route                           | RSC route                           |                 Median nav duration |                    Median LCP start |           JS requests |    Inertia payload |
| -------------------- | --------------------------------------- | ----------------------------------- | ----------------------------------: | ----------------------------------: | --------------------: | -----------------: |
| Product detail       | `/public_product/inertia_demo`          | `/public_product/rsc_demo`          | `811.50ms` -> `272.25ms` (`-66.5%`) | `368.00ms` -> `304.00ms` (`-17.4%`) | `7` -> `1` (`-85.7%`) | `12,183 B` -> none |
| Discover marketplace | `/public_product/discover_inertia_demo` | `/public_product/discover_rsc_demo` | `796.95ms` -> `283.75ms` (`-64.4%`) | `360.00ms` -> `322.00ms` (`-10.6%`) | `7` -> `1` (`-85.7%`) | `24,960 B` -> none |

## Supporting Metrics

| Surface              | Metric                |       Inertia |         RSC |    Delta |
| -------------------- | --------------------- | ------------: | ----------: | -------: |
| Product detail       | Average nav duration  |    `930.56ms` |  `339.15ms` | `-63.6%` |
| Product detail       | p95 nav duration      |  `1,401.38ms` |  `637.69ms` | `-54.5%` |
| Product detail       | Median response end   |    `215.60ms` |  `214.10ms` |  `-0.7%` |
| Product detail       | Median HTML transfer  |     `5,702 B` |   `9,105 B` | `+59.7%` |
| Product detail       | Median JS transfer    |   `178,955 B` |  `82,759 B` | `-53.8%` |
| Product detail       | Median decoded JS/CSS | `1,174,356 B` | `611,242 B` | `-48.0%` |
| Discover marketplace | Average nav duration  |    `798.69ms` |  `287.42ms` | `-64.0%` |
| Discover marketplace | p95 nav duration      |    `817.90ms` |  `319.44ms` | `-60.9%` |
| Discover marketplace | Median response end   |    `211.50ms` |  `218.20ms` |  `+3.2%` |
| Discover marketplace | Median HTML transfer  |     `7,643 B` |  `14,019 B` | `+83.4%` |
| Discover marketplace | Median JS transfer    |   `178,955 B` |  `82,780 B` | `-53.7%` |
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

- Repeat with PageSpeed API or field data after production-equivalent media parity so the report includes `INP` and mobile score beyond local Lighthouse.
- Profile the React on Rails Pro renderer and streaming path beyond the top-level streamed shell and Node renderer prepare timing now captured in `Server-Timing`.
- Add any Pro 17 static RSC caching as a separately labeled route variant rather than folding it into this matched uncached result.
- Add separately named lab-clean and production-shaped variants to control the current third-party/legacy-script asymmetry.
- Upgrade, deploy, and rerun after React on Rails Pro `17.0.0` final before posting an upstream Gumroad issue.
- Document production-equivalent responsive media/CDN/chrome parity before using live PageSpeed numbers as evidence.
- If the mobile run preserves the navigation/LCP/client-JS advantage, convert this into a Gumroad-facing proposal focused on public product and Discover pages.
- For a stronger Gumroad-maintainer proof, wire sanitized production-shaped props into the real public `Discover/Index` and `Products/Discover/Show` components where feasible, then compare those pages with an RSC equivalent.
