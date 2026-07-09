# Gumroad Upstream Issue Draft

## Goal

The right upstream goal is narrow:

- show bounded, measurable public buyer-page comparison surfaces
- avoid proposing a broad migration
- ask whether Gumroad would review a focused experiment branch or PR if the public-page performance case becomes stronger

Do not post this upstream yet. Hold until React on Rails Pro `17.0.0` is final,
then refresh the deployed demo, media-parity evidence, PageSpeed/PageSpeed-style
diagnostics, and package version references before opening the issue.

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
- Live demo: https://gumroad.reactonrails.com/rsc-demo
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

The current branch A/B result is favorable enough to keep testing on the page type that matters most for Gumroad:

- public product pages
- public Discover pages
- SEO-sensitive initial HTML and metadata
- conversion-sensitive buyer loading
- browse-to-product discovery
- client JavaScript reduction

Current media-bearing ShakaPerf results from `2026-07-09 UTC` on the PR 69 review app:

| Public surface       |                   Median nav duration |                 Median response end |                    Median LCP start |           JS requests |
| -------------------- | ------------------------------------: | ----------------------------------: | ----------------------------------: | --------------------: |
| Product detail       |  `1292.15ms` -> `731.70ms` (`-43.4%`) | `137.10ms` -> `170.15ms` (`+24.1%`) | `992.00ms` -> `382.00ms` (`-61.5%`) | `9` -> `1` (`-88.9%`) |
| Discover marketplace | `1423.70ms` -> `1054.30ms` (`-25.9%`) | `140.65ms` -> `261.60ms` (`+86.0%`) | `960.00ms` -> `602.00ms` (`-37.3%`) | `9` -> `1` (`-88.9%`) |

This result is useful because it compares both route pairs after the demo gained local media fixtures. It also keeps the important tradeoff visible: RSC streams more complete HTML, so the claim is faster browser completion, faster LCP, and fewer JavaScript requests, not universally lower server TTLB or lower JavaScript bytes.

The live-Gumroad-versus-demo PageSpeed/Lighthouse links remain in the lab for diagnostics, but I am not quoting the current scores as evidence. The earlier URL-pair run looked favorable, but a timeline review showed the comparison was not apples-to-apples: live Gumroad loaded production product imagery and chrome that the demo did not yet match. The next proof step is to document production-equivalent media parity, rerun PageSpeed API or pinned Lighthouse reports on those same public URL pairs, and capture field-data corroboration where possible, especially for `INP` and mobile score.

The supporting local and review-app ShakaPerf runs are linked from the demo docs for reproducibility. This is not the final adoption claim yet.

The dashboard comparison remains useful as a technical proof, but it should not carry the Gumroad value case because logged-in dashboard pages are not the public buyer path.

## Why this may be worth reviewing

- the comparison uses logged-out public product and Discover routes rather than admin/dashboard routes
- the RSC routes can be benchmarked against matched Inertia controls on the same data
- the demo is real enough to discuss architecture tradeoffs with code and measurements, not just theory
- the next measurement step is straightforward: redeploy the media-bearing demo to the stable public host, add production-equivalent media parity, then capture PageSpeed API or field-data corroboration on the same public URL pairs
- the media-bearing same-fixture browser-navigation and LCP result is already large enough to justify that next step

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
