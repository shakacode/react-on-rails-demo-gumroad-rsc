# Current Status

## Short Answer

The demo now has logged-out public product and Discover route pairs that compare
the same production-shaped synthetic fixture data through:

- Inertia controls: `/public_product/inertia_demo` and
  `/public_product/discover_inertia_demo`
- React Server Components via React on Rails Pro candidates:
  `/public_product/rsc_demo` and `/public_product/discover_rsc_demo`

The public homepage and `/rsc-demo` lab intentionally focus on buyer-facing
pages because those are SEO-sensitive, conversion-sensitive, mobile-heavy, and
visible without a demo account. Dashboard routes remain technical integration
proof only.

## Deployed Public Result

Captured on `2026-07-09 UTC` against `https://gumroad.reactonrails.com`
with local headless Chrome `150`, `8` alternating cycles per route pair, and
`2` warmup requests per measured run.

| Surface              |                 Median nav duration |                 Median response end |                    Median LCP start |           JS requests |
| -------------------- | ----------------------------------: | ----------------------------------: | ----------------------------------: | --------------------: |
| Product detail       | `883.90ms` -> `267.25ms` (`-69.8%`) |  `206.45ms` -> `206.60ms` (`+0.1%`) | `354.00ms` -> `304.00ms` (`-14.1%`) | `9` -> `1` (`-88.9%`) |
| Discover marketplace | `867.15ms` -> `300.30ms` (`-65.4%`) | `201.70ms` -> `243.30ms` (`+20.6%`) |  `362.00ms` -> `350.00ms` (`-3.3%`) | `9` -> `1` (`-88.9%`) |

This is the current headline same-fixture hosted evidence. It shows a large
browser-navigation and client-JavaScript reduction on both public route pairs.
The tradeoff is still visible: Discover response-end is slower under RSC
because the route streams more complete server-rendered HTML.

## Supporting Local And Review-App Results

The earlier local and PR 63 review-app results remain useful chronology and
reproducibility context, but they are no longer the hosted headline evidence.

## Deployed Lighthouse URL-Pair Comparator

Because the PageSpeed Insights API returned HTTP `429` from this environment,
the external URL comparison was captured with local `lighthouse@12.8.2` instead.
The deployed rerun uses `3` runs per URL per mobile/desktop strategy.

| Surface              | Strategy |           Live -> demo score |                         Live -> demo LCP |       Live -> demo TBT |           Live -> demo total byte weight |
| -------------------- | -------- | ---------------------------: | ---------------------------------------: | ---------------------: | ---------------------------------------: |
| Product detail       | Mobile   | `0.57` -> `0.98` (`+41 pts`) | `15,590.34ms` -> `2,422.79ms` (`-84.5%`) |  `74.00ms` -> `0.00ms` |  `4,053,575 B` -> `242,140 B` (`-94.0%`) |
| Discover marketplace | Mobile   | `0.58` -> `0.97` (`+39 pts`) | `27,210.88ms` -> `2,476.85ms` (`-90.9%`) | `149.00ms` -> `0.00ms` | `12,584,127 B` -> `246,901 B` (`-98.0%`) |

These URL pairs compare the public RSC demo host to live Gumroad pages. They are
external credibility evidence, not the controlled same-data architecture proof.
The older hosted `2026-06-24` run remains historical support for JavaScript
request and transfer deltas, but it predates the Tendon Book fixture.

## What Is Done

- Public product and Discover fixtures are synthetic but shaped from public
  Gumroad `Discover/Index` and `Products/Discover/Show` page structure.
- The repo now documents the fixture sanitation policy in
  [public-page-fixture-sampling.md](./public-page-fixture-sampling.md).
- The public lab shows same-origin route timing, response size, route script
  bytes, and serialized Inertia payload differences.
- The public RSC routes opt into React on Rails Pro stream observability, so
  `Server-Timing` can expose streamed shell and Node renderer prepare
  attribution when available.
- Current result details are in
  [performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json).
- Supporting local result details are in
  [performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json).
- Supporting PR 63 result details are in
  [performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json).
- Lighthouse URL-pair details are in
  [performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json).
- Rspack is framed as build/tooling infrastructure only; the runtime performance
  premise is React Server Components via React on Rails Pro.

## Remaining Proof Gates

- Capture PageSpeed Insights API reports or field data for `INP` and mobile
  score once API quota is available. The latest API probe is HTTP `429`
  `RESOURCE_EXHAUSTED`, and the local Lighthouse fallback does not provide
  field data.
- If using Pro 17 static RSC caching, add it as a separately named cached static
  route variant rather than folding it into the headline matched route pair.
- Add sanitized local image/media fixtures and rerun the benchmark, because the
  current committed fixture uses synthetic cover placeholders.
- For a stronger Gumroad-maintainer case, wire sanitized production-shaped props
  into the real public `Discover/Index` and `Products/Discover/Show` components
  where feasible, then compare those with an RSC equivalent.

## Current Position

The result is strong enough to continue the Gumroad-facing pitch and ask
maintainers what proof they would need next. It is still not enough to claim
Gumroad should adopt the architecture wholesale; the response-end tradeoff and
lack of PageSpeed field data should stay visible.
