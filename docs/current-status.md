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

## Current Branch Public Result

Captured on `2026-07-08 UTC` against `http://app.test.gumroad.com:31338`
with local headless Chrome `149`, `6` alternating cycles per route pair, and
`2` warmup requests per measured run.

| Surface | Median nav duration | Median response end | Median LCP start |
| --- | ---: | ---: | ---: |
| Product detail | `392.70ms` -> `212.80ms` (`-45.8%`) | `337.40ms` -> `171.30ms` (`-49.2%`) | `416.00ms` -> `224.00ms` (`-46.2%`) |
| Discover marketplace | `375.45ms` -> `303.70ms` (`-19.1%`) | `313.60ms` -> `245.25ms` (`-21.8%`) | `400.00ms` -> `322.00ms` (`-19.5%`) |

This is favorable same-fixture browser-navigation evidence from the local test
host.

## Hosted Review-App Result

Captured on `2026-07-08 UTC` against the PR 63 review app
`https://rails-ejbbntm539k6r.cpln.app` with headless Chrome `149`, `6`
alternating cycles per route pair, `2` warmup requests per measured run,
`--public`, and `--require-driver-match`.

| Surface | Median nav duration | Median response end | Median LCP start | JS requests |
| --- | ---: | ---: | ---: | ---: |
| Product detail | `602.75ms` -> `502.20ms` (`-16.7%`) | `153.00ms` -> `193.00ms` (`+26.1%`) | `500.00ms` -> `394.00ms` (`-21.2%`) | `7` -> `1` (`-85.7%`) |
| Discover marketplace | `605.30ms` -> `529.25ms` (`-12.6%`) | `152.10ms` -> `357.25ms` (`+134.9%`) | `508.00ms` -> `430.00ms` (`-15.4%`) | `7` -> `1` (`-85.7%`) |

The hosted review-app run confirms the browser-navigation, LCP, and JavaScript
request-count direction on the current PR. It also exposes the important server
tradeoff: RSC response-end and HTML transfer are higher on the hosted review app
because the rendered content is streamed in the document.

## Lighthouse URL-Pair Comparator

Because the PageSpeed Insights API returned HTTP `429` from this environment,
the external URL comparison was captured with local `lighthouse@12.8.2` instead.
It uses `3` runs per URL per mobile/desktop strategy.

| Surface | Strategy | Score | LCP | TBT | Total byte weight |
| --- | --- | ---: | ---: | ---: | ---: |
| Product detail | Mobile | `0.56` -> `0.99` (`+43 pts`) | `14,741.13ms` -> `2,122.72ms` (`-85.6%`) | `56.00ms` -> `0.00ms` | `4,059,130 B` -> `369,328 B` (`-90.9%`) |
| Discover marketplace | Mobile | `0.58` -> `0.96` (`+38 pts`) | `11,990.70ms` -> `2,647.96ms` (`-77.9%`) | `114.50ms` -> `0.00ms` | `12,811,991 B` -> `372,678 B` (`-97.1%`) |

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
  [performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json).
- Hosted PR 63 result details are in
  [performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json).
- Lighthouse URL-pair details are in
  [performance-artifacts/lighthouse-public-comparator-2026-07-08/summary.json](./performance-artifacts/lighthouse-public-comparator-2026-07-08/summary.json).
- Rspack is framed as build/tooling infrastructure only; the runtime performance
  premise is React Server Components via React on Rails Pro.

## Remaining Proof Gates

- Capture PageSpeed Insights API reports or field data for `INP` and mobile
  score once API quota is available; the local Lighthouse fallback does not
  provide field data.
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
Gumroad should adopt the architecture wholesale; the response-end tradeoff,
temporary review-app host, and lack of PageSpeed field data should stay visible.
