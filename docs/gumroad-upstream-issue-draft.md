# Gumroad Upstream Issue Draft

## Goal

The right upstream goal is narrow:

- show bounded, measurable public buyer-page comparison surfaces
- avoid proposing a broad migration
- ask whether Gumroad would review a focused experiment branch or PR if the public-page performance case becomes stronger

Do not post this upstream yet. First fix or explicitly accept the two current
ShakaPerf regressions, restore production-equivalent delivery, collect field
corroboration, and update package version references.

The current best candidates are the logged-out public product and Discover comparisons:

- product `Inertia` control: `/public_product/inertia_demo`
- product React Server Components via React on Rails Pro demo: `/public_product/rsc_demo`
- Discover `Inertia` control: `/public_product/discover_inertia_demo`
- Discover React Server Components via React on Rails Pro demo: `/public_product/discover_rsc_demo`

## Paste-ready issue draft

```md
## Proposal

I put together a public experiment repo that tracks Gumroad and compares matched Inertia controls against bounded React Server Components implementations using `react_on_rails`, React on Rails Pro, and React 19 on logged-out public buyer-page surfaces:

- Repo: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc
- VP Engineering summary: https://gumroad.reactonrails.com/rsc-demo
- Detailed evidence lab: https://gumroad.reactonrails.com/rsc-demo/evidence#native-shakaperf-result
- Product Inertia control: https://gumroad.reactonrails.com/public_product/inertia_demo
- Product React Server Components route: https://gumroad.reactonrails.com/public_product/rsc_demo
- Discover Inertia control: https://gumroad.reactonrails.com/public_product/discover_inertia_demo
- Discover React Server Components route: https://gumroad.reactonrails.com/public_product/discover_rsc_demo
- Public result docs and fixture-provenance notes: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/public-product-rsc-demo.md

The goal is not to argue for a broad rewrite.
The goal is to determine whether public, buyer-facing product and Discover pages can get enough SEO, conversion, browse, and loading-performance benefit to justify the extra complexity.

## What the current experiment shows

The hosted lab now has production-shaped synthetic fixtures for the public pages that should matter most:

- product detail: product story, price, reviews, seller context, CTA framing, FAQ, and recommendations
- Discover marketplace: dense product grid, taxonomy/category context, filters, collections, prices, ratings, and seller cards
- both route pairs are logged out and visible without a demo account
- both route pairs use the same fixture data for Inertia and React Server Components
- the fixtures were shaped from public Gumroad page structure without committing copied creator content
- the fixture now uses local synthetic media so the demo pages load image elements without copying creator-owned images
- the current control route is a custom Inertia benchmark surface, not yet the production `Discover/Index` or `Products/Discover/Show` component migrated one-for-one

The current branch A/B result is mixed but useful enough to keep testing on the page type that matters most for Gumroad:

- public product pages
- public Discover pages
- SEO-sensitive initial HTML and metadata
- conversion-sensitive buyer loading
- browse-to-product discovery
- client JavaScript reduction

Current ShakaPerf CLI results from `2026-08-12` use ten simultaneous mobile Lighthouse measurements per side and native product:

| Product            |                       FCP |                        LCP |         Lighthouse |        JS requests |                       Downloads |
| ------------------ | ------------------------: | -------------------------: | -----------------: | -----------------: | ------------------------------: |
| Microsoft 365      | `7.71s -> 1.85s` (`-76%`) | `13.92s -> 3.64s` (`-74%`) | `35 -> 77` (`+42`) | `41 -> 3` (`-93%`) | `2152.2KB -> 3361.7KB` (`+56%`) |
| Residential Design | `7.81s -> 1.85s` (`-76%`) | `16.88s -> 8.63s` (`-49%`) | `43 -> 71` (`+28`) | `41 -> 3` (`-93%`) | `3425.7KB -> 4643.4KB` (`+36%`) |

The command exits `1` with `FAILED: 2 perf regressions`. `TTFB` regresses `35%/39%`, JavaScript transfer grows `206%`, and Microsoft `TBT` moves `0 -> 199ms`. This is evidence of faster paint and fewer requests, not overall superiority.

This is an end-to-end route result, not an estimate of RSC alone. The RSC route intentionally skips legacy application JavaScript and uses an isolated bundle; the Inertia route also loads analytics/tag-manager scripts omitted by RSC. A clean pair and a production-shaped third-party-matched pair are still required before making a causal claim.

The live-Gumroad-versus-demo PageSpeed/Lighthouse links remain in the lab for diagnostics, but I am not quoting the current scores as evidence. Resource audits confirm that live Gumroad loads far more mixed-format media, different chrome, caching/CDN behavior, fonts, and third-party services. The next proof step is to document a production-parity target and capture mobile-throttled or field-relevant corroboration, especially for `INP` and mobile score.

The supporting local and review-app ShakaPerf runs are linked from the demo docs for reproducibility. This is not the final adoption claim yet.

The dashboard comparison remains useful as a technical proof, but it should not carry the Gumroad value case because logged-in dashboard pages are not the public buyer path.

## Why this may be worth reviewing

- the comparison uses logged-out public product and Discover routes rather than admin/dashboard routes
- the RSC routes can be benchmarked against matched Inertia controls on the same data
- the demo is real enough to discuss architecture tradeoffs with code and measurements, not just theory
- the next measurement step is explicit: reduce payload and TTFB, restore production parity, rerun ShakaPerf, then add field corroboration
- the paint result is large enough to justify that next step, while the failed-suite status and delivery regressions stay visible

## What I am not claiming

- that the full Gumroad dashboard is already faster under RSC
- that RSC is a better fit for every Inertia page
- that the current live-Gumroad-versus-demo PageSpeed/Lighthouse numbers are valid proof before media and production surface parity are documented

## What I want feedback on

1. Are these public product and Discover comparison surfaces interesting enough to discuss further?
2. If yes, would Gumroad prefer that follow-up stay in the public experiment repo, or would a small upstream draft PR for the demo route be more useful?
3. If a follow-up is worth it, what would be the minimum proof needed to make this more than a curiosity?

## Links

- Public product demo details: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/public-product-rsc-demo.md
- Public buyer-page performance results and fixture sampling notes: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/63
- Historical dashboard/bundler findings: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/performance-findings.md
- Performance evaluation notes: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/performance-evaluation.md
```

## If converted into an upstream PR

The PR should stay even narrower than the issue.

Recommended framing:

- add one public buyer-page comparison surface only, starting with the surface Gumroad maintainers think is most valuable
- keep the current Inertia control route in the same PR
- keep the RSC route clearly labeled as an experiment
- do not mix in broad React 19 type cleanup
- do not pitch a migration in the PR body

Recommended PR title:

- `Add a bounded public buyer-page rendering experiment`

Recommended PR summary:

- add a matched control route and experiment route
- keep the scope to one logged-out public buyer page
- include measurement docs and explicit caveats

## What would make the upstream case stronger

- production-equivalent responsive media fixtures, cache headers, and CDN behavior in the demo
- PageSpeed API or field-data reports for the public product and Discover URL pairs after media parity
- measured `LCP`, `TBT`, `INP`, client JavaScript, payload, and navigation wins on the public routes
- a cleaner explanation of where the remaining server cost comes from
- one short screen recording showing the side-by-side difference
- a clear statement of where Inertia still wins

## What would weaken the upstream case

- treating `Rspack` as if it explains the page-level runtime win
- treating the dashboard proof as the Gumroad value case
- making architecture claims that outrun the actual measurements
- proposing multiple migrations at once instead of one comparison surface
