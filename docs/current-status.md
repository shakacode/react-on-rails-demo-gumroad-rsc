# Current Status

## Short answer

The stable public deployment now serves deterministic, media-bearing Product and Discover route pairs:

- Inertia controls: `/public_product/inertia_demo` and `/public_product/discover_inertia_demo`
- React Server Components via React on Rails Pro candidates: `/public_product/rsc_demo` and `/public_product/discover_rsc_demo`

PR 69 is merged and deployed. The exact media gate passes on `https://gumroad.reactonrails.com`; the first cold attempt received a transient `503`, so deployment warm-up remains a reproducibility concern.

The versioned [RSC lab benchmark contract v1](./rsc-lab-benchmark-contract-v1.md) defines the fixture identity, serialized ShakaPerf protocol, evidence hierarchy, and the deferred final-release gates behind this result.

## Current stable result

Captured July 10, 2026 UTC against the stable host with Chrome `150.0.7871.49`, ChromeDriver `150.0.7871.115`, two independent batches of eight alternating cycles per pair, and two server warmups before each measured run.

| Surface | Median navigation | Median response end | Median LCP | JS transfer | Inertia payload |
| --- | ---: | ---: | ---: | ---: | ---: |
| Product | `1123.5ms` -> `575.0ms` (`-48.8%`) | `504.85ms` -> `509.55ms` (`+0.9%`) | `662ms` -> `602ms` (`-9.1%`) | `162,696 B` -> `82,228.5 B` (`-49.5%`) | `15,040 B` -> none |
| Discover | `1097.9ms` -> `630.45ms` (`-42.6%`) | `473.9ms` -> `492.8ms` (`+4.0%`) | `768ms` -> `648ms` (`-15.6%`) | `162,696 B` -> `82,223 B` (`-49.5%`) | `33,966 B` -> none |

The defensible conclusion is narrower than the previous PR 69 review-app result:

- Full-navigation duration is clearly better for the deployed RSC candidate on both surfaces.
- Product LCP is modestly better. Discover LCP is directionally better but noisier: two of 16 paired cycles regressed and the two batch medians differ materially.
- Response end is not an RSC win.
- RSC's combined-median encoded HTML body (compressed, headers excluded) is 80.4% larger on Product and 100.2% larger on Discover; it sends about half the JavaScript, one route script instead of nine, and no duplicated Inertia data-page payload.

The current artifact and all 64 underlying measurements are in [performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md).

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
2. Upgrade the demo to final, deploy it, rerun the media gate, and repeat the two-batch stable ShakaPerf protocol with exact Chrome/driver versions recorded.
3. Resolve or explicitly frame the analytics/legacy-bundle asymmetry with the clean and production-shaped variants above.
4. Decide the production-parity target for image counts, formats, dimensions, responsive behavior, fonts, chrome, caching/CDN, and third parties; rerun mobile diagnostics against that documented target.
5. Confirm the result on a mobile-throttled harness or field-relevant setup. The current ShakaPerf run is unthrottled desktop headless Chrome.
6. Keep PageSpeed comparisons diagnostic unless all remaining service/media differences are controlled or disclosed; do not substitute a favorable score for the matched A/B result.

The current evidence justifies continuing the bounded experiment. It does not justify a wholesale Gumroad migration claim.
