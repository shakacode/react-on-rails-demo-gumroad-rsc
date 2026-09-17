# Current Status

## Short answer

The stable public deployment now serves deterministic, media-bearing Product and Discover route pairs:

- Inertia controls: `/public_product/inertia_demo` and `/public_product/discover_inertia_demo`
- React Server Components via React on Rails Pro candidates: `/public_product/rsc_demo` and `/public_product/discover_rsc_demo`

PR 69 is merged and deployed. The exact media gate passes on `https://gumroad.reactonrails.com`; the first cold attempt received a transient `503`, so deployment warm-up remains a reproducibility concern.

The latest evidence is the native-product [ShakaPerf CLI artifact](./performance-artifacts/native-product-rsc-shakaperf-2026-08-12/README.md). The older [RSC lab benchmark contract v1](./rsc-lab-benchmark-contract-v1.md) describes the historical public-demo Ruby/Selenium experiment.

## Current ShakaPerf result

Captured August 12, 2026 with `shaka-perf v0.2.4`, Chrome `151.0.7922.109`, and ten simultaneous mobile Lighthouse measurements per side and product.

| Product            |                       FCP |                        LCP |         Lighthouse |        JS requests |                       Downloads |
| ------------------ | ------------------------: | -------------------------: | -----------------: | -----------------: | ------------------------------: |
| Microsoft 365      | `7.71s -> 1.85s` (`-76%`) | `13.92s -> 3.64s` (`-74%`) | `35 -> 77` (`+42`) | `41 -> 3` (`-93%`) | `2152.2KB -> 3361.7KB` (`+56%`) |
| Residential Design | `7.81s -> 1.85s` (`-76%`) | `16.88s -> 8.63s` (`-49%`) | `43 -> 71` (`+28`) | `41 -> 3` (`-93%`) | `3425.7KB -> 4643.4KB` (`+36%`) |

Paint is materially faster, but delivery is heavier: `TTFB` regresses `+35%/+39%`, JavaScript transfer grows `724.3KB -> 2219.7KB` (`+206%`) on both products, and Microsoft `TBT` moves `0 -> 199ms`. The command exits `1` with `FAILED: 2 perf regressions`. This is a mixed result, not proof that RSC is better overall.

## Historical July Ruby/Selenium result

Captured July 10, 2026 UTC against the stable host with Chrome `150.0.7871.49`, ChromeDriver `150.0.7871.115`, two independent batches of eight alternating cycles per pair, and two server warmups before each measured run.

| Surface  |                   Median navigation |                Median response end |                    Median LCP |                            JS transfer |    Inertia payload |
| -------- | ----------------------------------: | ---------------------------------: | ----------------------------: | -------------------------------------: | -----------------: |
| Product  |  `1123.5ms` -> `575.0ms` (`-48.8%`) | `504.85ms` -> `509.55ms` (`+0.9%`) |  `662ms` -> `602ms` (`-9.1%`) | `162,696 B` -> `82,228.5 B` (`-49.5%`) | `15,040 B` -> none |
| Discover | `1097.9ms` -> `630.45ms` (`-42.6%`) |   `473.9ms` -> `492.8ms` (`+4.0%`) | `768ms` -> `648ms` (`-15.6%`) |   `162,696 B` -> `82,223 B` (`-49.5%`) | `33,966 B` -> none |

The defensible conclusion is narrower than the previous PR 69 review-app result:

- Full-navigation duration is clearly better for the deployed RSC candidate on both surfaces.
- Product LCP is modestly better. Discover LCP is directionally better but noisier: two of 16 paired cycles regressed and the two batch medians differ materially.
- Response end is not an RSC win.
- RSC's combined-median encoded HTML body (compressed, headers excluded) is 80.4% larger on Product and 100.2% larger on Discover; it sends about half the JavaScript, one route script instead of nine, and no duplicated Inertia data-page payload.

The historical artifact and all 64 underlying measurements are in [performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md). This run came from `scripts/perf/compare_dashboard_routes.rb`, not the `shaka-perf` CLI.

## Causal limit

This is a valid end-to-end comparison of the routes as deployed, not a clean estimate of “RSC alone.” Both routes share presenter props and UI, but the RSC controller intentionally skips the legacy application JavaScript and uses an isolated client bundle. The Inertia route also loads analytics/tag-manager scripts that the RSC route omits.

Bundle isolation is an intended architecture benefit. Third-party omission is a parity gap. A follow-up should benchmark separately named variants:

1. a lab-clean pair with third parties disabled on both routes;
2. a production-shaped pair with required analytics enabled on both routes.

Changing the current pair silently would change the meaning of the historical experiment, so this pass documents the limit instead.

## Live Gumroad parity audit

The synthetic demo now has images, but it is not production-equivalent media:

- Demo Product fetches five small synthetic SVGs (~11 KB); the sampled live product fetched roughly 2.3-3.2 MB of mixed WebP/PNG/SVG media and additional description/chrome assets.
- Demo Discover fetches eight unique synthetic SVGs (~17 KB); sampled live Discover runs fetched roughly 11-16 MB across about 100 image requests, including WebP, PNG, JPEG, GIF, and SVG.
- The demo uses explicit eager/lazy loading but no `srcset`/`sizes`. The sampled live pages also exposed no responsive-image attributes, but their media/card dimensions and content changed between captures.
- Demo media/fonts were Cloudflare hits with four-hour caching. Most live `public-files` media used one-year caching, while other assets used shorter policies.
- The Inertia demo loaded Google Tag Manager, Google Analytics, Facebook, and Cloudflare Insights; the RSC demo loaded only demo-host and Cloudflare resources. Live Gumroad loaded substantially more production chrome and third-party services.

The exact 390 x 844 and 1440 x 1100 captures are stored beside the benchmark. They record source URLs and metadata only; no creator-owned media was copied.

## React 19.2 / Pro 17 status

- Actually used: one streamed RSC tree per route, Node renderer, isolated client/server/RSC bundles, `rsc_stream_observability`, and uncached page responses.
- Available but unused: Suspense boundaries, async server-component data fetching, cached stream helpers, React request-cache APIs, partial pre-rendering/resume, and client islands.
- Inappropriate for the headline pair: adding static RSC caching or synthetic Suspense work would create a different experiment and must be a separately named variant.

The RC validation candidate is pinned to React on Rails Pro gem `17.0.0.rc.9`, React on Rails Pro npm `17.0.0-rc.9`, and `react-on-rails-rsc` `19.2.1-rc.1`. Validate that stack in the deployed artifact, then upgrade, redeploy, and rerun after Pro `17.0.0` final.

## Remaining gates before a Gumroad issue

Do not post the upstream Gumroad issue yet. Required blockers are:

1. React on Rails Pro `17.0.0` final is publicly available.
2. Upgrade the demo to final, deploy it, rerun the media gate, and repeat the native ShakaPerf protocol with exact Chrome versions recorded.
3. Resolve or explicitly frame the analytics/legacy-bundle asymmetry with the clean and production-shaped variants above.
4. Decide the production-parity target for image counts, formats, dimensions, responsive behavior, fonts, chrome, caching/CDN, and third parties; rerun mobile diagnostics against that documented target.
5. Confirm the mobile Lighthouse result with production-equivalent delivery and field data; the current ShakaPerf result is synthetic lab data.
6. Keep PageSpeed comparisons diagnostic unless all remaining service/media differences are controlled or disclosed; do not substitute a favorable score for the matched A/B result.

The current evidence justifies continuing the bounded experiment. It does not justify a wholesale Gumroad migration claim.
