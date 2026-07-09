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

## Current PR 69 Media-Bearing Result

Captured on `2026-07-09 UTC` against the PR 69 review app
`https://rails-6rbrymb4tqrb6.cpln.app` with local headless Chrome `150`, `8`
alternating cycles per route pair, and `2` warmup requests per measured run.
This run includes the local synthetic media fixtures added to the product and
Discover pages.

| Surface              |                   Median nav duration |                 Median response end |                    Median LCP start |           JS requests |
| -------------------- | ------------------------------------: | ----------------------------------: | ----------------------------------: | --------------------: |
| Product detail       |  `1292.15ms` -> `731.70ms` (`-43.4%`) | `137.10ms` -> `170.15ms` (`+24.1%`) | `992.00ms` -> `382.00ms` (`-61.5%`) | `9` -> `1` (`-88.9%`) |
| Discover marketplace | `1423.70ms` -> `1054.30ms` (`-25.9%`) | `140.65ms` -> `261.60ms` (`+86.0%`) | `960.00ms` -> `602.00ms` (`-37.3%`) | `9` -> `1` (`-88.9%`) |

This is the current headline same-fixture evidence because it measures the
media-bearing fixture. It shows median navigation, median LCP, and JavaScript
request-count wins on both public route pairs. The tradeoff is also clearer:
RSC sends much larger HTML, has a larger media-bearing route bundle in this run,
and has slower response-end because the route streams more complete
server-rendered HTML.

## Supporting Stable, Local, And Review-App Results

The stable deployed, earlier local, and PR 63 review-app results remain useful
chronology and reproducibility context, but they predate the local media fixture
change or were captured on earlier PRs. Rerun against
`https://gumroad.reactonrails.com` after this PR lands before calling the stable
deployment current again.

## Deployed Lighthouse URL-Pair Diagnostic

Because the PageSpeed Insights API returned HTTP `429` from this environment,
the external URL comparison was captured with local `lighthouse@12.8.2` instead.
The deployed rerun uses `3` runs per URL per mobile/desktop strategy.

Do not quote the current live-Gumroad-versus-demo scores as evidence. A timeline
review showed this URL-pair run was not apples-to-apples: live Gumroad loaded
production imagery and chrome that the demo did not yet match. Keep the artifact
for auditability and use the PageSpeed links to diagnose parity gaps. The
controlled same-data architecture proof remains the ShakaPerf route-pair run.
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
- Current PR 69 media-bearing result details are in
  [performance-artifacts/hosted-review-pr69-media-public-buyer-pages-2026-07-09/summary.json](./performance-artifacts/hosted-review-pr69-media-public-buyer-pages-2026-07-09/summary.json).
- Stable deployed pre-media result details are in
  [performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json).
- Supporting local result details are in
  [performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json).
- Supporting PR 63 result details are in
  [performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json).
- Diagnostic Lighthouse URL-pair details are in
  [performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json).
- Rspack is framed as build/tooling infrastructure only; the runtime performance
  premise is React Server Components via React on Rails Pro.

## Remaining Proof Gates

- Capture PageSpeed Insights API reports or field data for `INP` and mobile
  score once API quota is available and the demo has production-equivalent
  media parity. The latest API probe is HTTP `429` `RESOURCE_EXHAUSTED`, and
  the local Lighthouse fallback does not provide field data.
- If using Pro 17 static RSC caching, add it as a separately named cached static
  route variant rather than folding it into the headline matched route pair.
- Rerun the media-bearing benchmark against the stable deployed demo after this
  PR lands, and add production-equivalent responsive image/CDN parity before
  using live PageSpeed numbers as evidence.
- For a stronger Gumroad-maintainer case, wire sanitized production-shaped props
  into the real public `Discover/Index` and `Products/Discover/Show` components
  where feasible, then compare those with an RSC equivalent.

## Current Position

The result is strong enough to continue the Gumroad-facing pitch and ask
maintainers what proof they would need next. It is still not enough to claim
Gumroad should adopt the architecture wholesale; the response-end tradeoff,
media-parity caveat, and lack of PageSpeed field data should stay visible.
