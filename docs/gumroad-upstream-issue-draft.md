# Gumroad Upstream Issue Draft

## Goal

The right upstream goal is narrow:

- show one bounded, measurable public product-page comparison surface
- avoid proposing a broad migration
- ask whether Gumroad would review a focused experiment branch or PR if the public-page performance case becomes stronger

The current best candidate is the logged-out public product comparison:

- `Inertia` control: `/public_product/inertia_demo`
- React Server Components via React on Rails Pro demo: `/public_product/rsc_demo`

## Paste-ready issue draft

```md
## Proposal

I put together a public experiment repo that tracks Gumroad and compares a matched Inertia control against a bounded React Server Components implementation using `react_on_rails`, React on Rails Pro, and React 19 on a logged-out public product-page surface:

- Repo: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc
- Live demo: https://gumroad.reactonrails.com/rsc-demo
- Inertia control: https://gumroad.reactonrails.com/public_product/inertia_demo
- React Server Components route: https://gumroad.reactonrails.com/public_product/rsc_demo
- Comparison docs: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/performance-findings.md

The goal is not to argue for a broad rewrite.
The goal is to determine whether public, buyer-facing product pages can get enough SEO, conversion, and loading-performance benefit to justify the extra complexity.

## What the current experiment shows

On the hosted public product-page lab, the current route-level payload comparison shows:

- Inertia route readable JavaScript: `880.8 KB`
- React Server Components route readable JavaScript: `340.4 KB`
- Inertia serialized `data-page` payload: `6.4 KB`
- React Server Components serialized `data-page` payload: none
- both routes are logged out and visible without a demo account

So the current result is not yet a final adoption claim. It is a visible reason to keep testing on the page type that matters most for Gumroad:

- public product pages
- SEO-sensitive initial HTML and metadata
- conversion-sensitive buyer loading
- client JavaScript reduction
- measured mobile `LCP`, `TBT`, `INP`, and navigation wins

The dashboard comparison remains useful as a technical proof, but it should not carry the Gumroad value case because logged-in dashboard pages are not the public buyer path.

## Why this may be worth reviewing

- the comparison uses a logged-out product route rather than an admin/dashboard route
- the RSC route removes the Inertia `data-page` payload for this public surface
- the RSC route materially reduces route JavaScript in the hosted lab sample
- the demo is real enough to discuss architecture tradeoffs with code and measurements, not just theory
- the next measurement step is straightforward: mobile ShakaPerf/Lighthouse-style A/B testing on the public product route pair

## What I am not claiming

- that the full Gumroad dashboard is already faster under RSC
- that RSC is a better fit for every Inertia page
- that the current payload result is enough to justify adoption by itself without mobile LCP/navigation evidence

## What I want feedback on

1. Is this public product-page comparison surface interesting enough to discuss further?
2. If yes, would Gumroad prefer that follow-up stay in the public experiment repo, or would a small upstream draft PR for the demo route be more useful?
3. If a follow-up is worth it, what would be the minimum proof needed to make this more than a curiosity?

## Links

- Public product demo details: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/public-product-rsc-demo.md
- Performance findings: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/performance-findings.md
- Performance evaluation notes: https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/blob/main/docs/performance-evaluation.md
```

## If converted into an upstream PR

The PR should stay even narrower than the issue.

Recommended framing:

- add one public product-page comparison surface only
- keep the current Inertia control route in the same PR
- keep the RSC route clearly labeled as an experiment
- do not mix in broad React 19 type cleanup
- do not pitch a migration in the PR body

Recommended PR title:

- `Add a bounded public product-page rendering experiment`

Recommended PR summary:

- add a matched control route and experiment route
- keep the scope to one logged-out public product page
- include measurement docs and explicit caveats

## What would make the upstream case stronger

- a mobile ShakaPerf/Lighthouse-style A/B report for the public product route pair
- measured `LCP`, `TBT`, `INP`, and navigation wins on the public route
- a cleaner explanation of where the remaining server cost comes from
- one short screen recording showing the side-by-side difference
- a clear statement of where Inertia still wins

## What would weaken the upstream case

- treating `Rspack` as if it explains the page-level runtime win
- treating the dashboard proof as the Gumroad value case
- making architecture claims that outrun the actual measurements
- proposing multiple migrations at once instead of one comparison surface
