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

This is favorable same-fixture browser-navigation evidence. It is not yet the
final hosted mobile adoption claim. The older hosted `2026-06-24` run remains
historical support for JavaScript request and transfer deltas, but it predates
the Tendon Book fixture.

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
- Rspack is framed as build/tooling infrastructure only; the runtime performance
  premise is React Server Components via React on Rails Pro.

## Remaining Proof Gates

- Repeat the public route-pair comparison with mobile-throttled
  Lighthouse/ShakaPerf metrics: `LCP`, `TBT`, `INP`, mobile score, route
  JavaScript, and serialized payload.
- Rerun the hosted benchmark after the Pro 17 / React 19.2 observability update
  so the report includes streamed shell and renderer prepare attribution.
- If using Pro 17 static RSC caching, add it as a separately named cached static
  route variant rather than folding it into the headline matched route pair.
- Add sanitized local image/media fixtures and rerun the benchmark, because the
  current committed fixture uses synthetic cover placeholders.
- For a stronger Gumroad-maintainer case, wire sanitized production-shaped props
  into the real public `Discover/Index` and `Products/Discover/Show` components
  where feasible, then compare those with an RSC equivalent.

## Current Position

The result is strong enough to continue the Gumroad-facing pitch, but not strong
enough to claim Gumroad should adopt the architecture yet. The next decision
should be based on mobile-throttled public buyer-page evidence, not dashboard
performance or bundler speed.
