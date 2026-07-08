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

## Latest Hosted Public Result

Captured on `2026-06-23 HST` / `2026-06-24 UTC` against
`https://gumroad.reactonrails.com` with local headless Chrome `149`, `8`
alternating cycles, and `2` warmup requests per measured run.

| Surface | Median nav duration | Median LCP start | JS requests |
| --- | ---: | ---: | ---: |
| Product detail | `811.50ms` -> `272.25ms` (`-66.5%`) | `368.00ms` -> `304.00ms` (`-17.4%`) | `7` -> `1` |
| Discover marketplace | `796.95ms` -> `283.75ms` (`-64.4%`) | `360.00ms` -> `322.00ms` (`-10.6%`) | `7` -> `1` |

This is favorable hosted browser-navigation evidence. It is not yet the final
mobile adoption claim.

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
- Hosted result details are in
  [public-buyer-page-performance-results.md](./public-buyer-page-performance-results.md).
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
