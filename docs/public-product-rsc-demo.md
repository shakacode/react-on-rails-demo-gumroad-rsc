# Public Product RSC Demo

## Purpose

The next RSC comparison should make the value visible on a logged-out, public, product-like page.

Implemented routes:

- VP Engineering summary: `/rsc-demo`
- performance lab: `/rsc-demo/evidence` or `/public_product/performance_demo`
- product `Inertia` control: `/public_product/inertia_demo`
- product React Server Components via React on Rails Pro demo: `/public_product/rsc_demo`
- Discover `Inertia` control: `/public_product/discover_inertia_demo`
- Discover React Server Components via React on Rails Pro demo: `/public_product/discover_rsc_demo`

The summary, lab, and all implementation routes render without requiring login.
The summary should be opened first for the bounded recommendation, measured
benefits, HTML and operational costs, evidence quality, and remaining production
gates. It does not run a browser race. The detailed lab auto-loads the matched product and
Discover route pairs, then shows first streamed bytes, complete response timing,
HTML response size, route script bytes, and serialized Inertia payload size in
the page itself.

The lab is intentionally shaped like an evidence article rather than a link
directory. The persistent navigation stays on the primary story: home,
performance lab, the two RSC candidates, and the stable deployed demo. Supporting
source links, benchmark artifacts, and PageSpeed rerun links live in expandable
reproducibility panels so a Gumroad reviewer can read the claim first and still
get exact URLs for independent checks.

Naming on the lab page should stay explicit:

- "matched Inertia control" means the same-fixture baseline route inside this
  demo app, not live Gumroad production.
- "this host RSC demo" means the RSC route on the host currently in the address
  bar, such as a review app or local server.
- "stable deployed RSC demo" means
  `https://gumroad.reactonrails.com/public_product/rsc_demo` and its Discover
  counterpart.
- "live Gumroad" means the real Gumroad product or Discover URL used for
  PageSpeed diagnostics, not the same-data A/B baseline.

The headline routes use stable, logged-out, same-origin fixtures. The product
fixture is now source-attributed to
[Tendon Book by Jacked Athlete](https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search):
title, seller, price, ebook type, rating summary, source link, and a synthetic
local cover image are preserved or represented, while longer descriptive copy is
lightly rewritten for this public demo. The Discover fixture remains synthetic
but production-shaped and now includes local synthetic card media. A small shape sampler
inspected public Gumroad `Discover/Index` and `Products/Discover/Show` pages to
identify field and layout shape.
See [docs/public-page-fixture-sampling.md](public-page-fixture-sampling.md) for
the source-attribution and fixture sanitation policy.

These public demo routes are not populated from database product rows. The
fixture contract currently lives in `PublicProductRscDemoPresenter` and committed
local files under `public/public-product-rsc-demo/media/`. For this branch,
"seeded correctly" means the deployed host is running the same presenter data
and static media assets as the measured branch. Before quoting PageSpeed or a
deployed ShakaPerf run, check the target host:

```bash
node scripts/perf/assert_public_demo_media_parity.mjs \
  --base-url https://gumroad.reactonrails.com
```

PR 69 is merged and the stable deployment passes this check. A first cold probe
received a transient `503` while the deployment woke, so warm the host and record
any failure before benchmarking; do not reinterpret a failed gate as proof that
the fixture has disappeared.

### Native Discover branch review surface

Control Plane branch apps also expose the application's native Inertia
`/discover` and card-specific `Products/Discover/Show` pages as a review surface.
Those pages are not another benchmark arm. A persistent branch-only notice labels
them as native Inertia backed by staging data and committed synthetic media, with
links back to the A/B evidence and the bounded RSC Discover candidate. Product and
seller navigation stays on the branch host so reviewers do not silently leave the
seeded environment; canonical production and non-branch staging redirects remain
unchanged.

The native seed is aligned to the versioned benchmark fixture without changing
the four measured `/public_product/*` routes or their output:

- 36 card-specific products with the benchmark names, sellers, prices,
  descriptions, and taxonomy distribution
- 10 deterministic synthetic reviews per product (360 total), producing the
  benchmark's 4.2–4.8 rating range from real seeded review rows
- 8 committed synthetic SVG covers reused in a deterministic round-robin, 7,572
  raw bytes total, with no creator-owned media or external image dependency

This makes the native page useful for identity, navigation, content-shape, and
review-app smoke testing. It does not make it resource-equivalent to live
Gumroad. Remaining production gaps include responsive image variants and formats,
CDN/cache headers, production fonts and global chrome, buyer-local currency,
live inventory and recommendation services, and third-party scripts. Live
Gumroad PageSpeed remains diagnostic only; the controlled claim continues to be
the same-host, same-fixture ShakaPerf A/B.

## Why this page matters

Dashboard routes are useful technical proofs, but they are not the strongest product proof.

Public product and Discover pages are where rendering quality can affect:

- search indexing and metadata quality
- first meaningful content for logged-out visitors
- share previews and landing-page credibility
- conversion-sensitive product storytelling
- browse-to-product discovery
- client JavaScript cost before a visitor decides whether to buy

That makes public buyer pages the better place to compare Gumroad/Inertia-style rendering with React Server Components via React on Rails Pro.

## What to compare

Keep the routes similar enough that the result is about rendering architecture, not page design.

The comparison should include:

- a visible lab page that explains what difference a reviewer should notice before they open DevTools
- identical or near-identical product title, description, media, pricing, creator, and call-to-action content
- identical or near-identical Discover product cards, taxonomy/category context, prices, ratings, filters, and collection cards
- SEO-relevant HTML and metadata emitted in the initial document
- equivalent above-the-fold content and layout
- route-scoped demo assets so unrelated Gumroad pages do not pay for the experiment
- no login requirement, dashboard state, admin-only data, or seller-only controls

The current RSC route demonstrates a bounded streamed server tree and bundle
isolation. It does not contain client islands or Suspense boundaries today. Add
genuinely interactive controls only in a separately reviewed iteration so the
benchmark workload change is explicit.

## React on Rails Pro 17 / React 19.2 Notes

This demo is pinned to React 19.2.7, React DOM 19.2.7, React on Rails Pro gem `17.0.0.rc.12`, React on Rails Pro npm `17.0.0-rc.12`, and `react-on-rails-rsc` `19.2.1`. The final Pro `17.0.0` release does not yet exist.

The public RSC routes opt into `rsc_stream_observability`, so the lab and external benchmark harnesses can inspect Pro stream attribution in `Server-Timing`, including streamed shell and Node renderer prepare timing when available. This replaces the older caveat that streamed RSC had no browser-visible renderer timing.

Pro 17's buffered/static RSC helpers are relevant to Gumroad-style public marketplace pages, but they change the benchmark claim. The headline route pair should stay matched and uncached; if the demo adds a cached stream helper, it should be exposed as a separately named cached static RSC variant and measured against an appropriately labeled control.

There are no Suspense boundaries, async server-component data fetches, or
client islands in this route tree. React 19.2 Suspense batching, request cache
APIs, partial pre-rendering/resume, and Activity therefore cannot explain the
current result. They should only be tested with a workload that exercises them.

The public Gumroad upstream has moved since the fixture was first sampled. Useful status-quo context now includes buyer-local currency, richer public product/profile JSON endpoints, custom HTML product pages, and Discover category fixes. Those are fixture/adoption inputs, not a reason to merge upstream wholesale into this demo branch because upstream also carries broad unrelated Vite and product-editor churn.

## Production-Shaped Fixtures

The early small product route was useful for validating the rendering path, but
it was too small to settle whether Gumroad should consider adopting this stack.
The current comparison uses real-page-shaped fixtures:

- Discover listing page: a dense grid of product cards, categories, local synthetic cover images, prices, ratings, and recommendation context comparable to `https://gumroad.com/discover`
- Product detail page: an attributed fixture based on [Tendon Book by Jacked Athlete](https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search), preserving the source title, seller, price, ebook type, rating summary, and source link while rewriting long body copy
- Matched implementations: one route rendered with the current Inertia approach and one route rendered with React Server Components via React on Rails Pro
- Same data, same host, same measurement harness, so benchmark results reflect rendering architecture rather than fixture differences

Public Gumroad pages expose enough metadata, HTML, and Inertia page data to build these fixtures from a small set of public examples. For a public demo repository, prefer curated source attribution plus rewritten copy, or production-shaped synthetic data, over broad scraping or wholesale copied creator content. Use real Gumroad URLs as external comparators and PageSpeed targets, not as the same-data A/B baseline.

The current "before" implementation intentionally uses a custom Inertia benchmark
surface rather than Gumroad's full production `Discover/Index` or
`Products/Discover/Show` components. That keeps the route pair same-data and
easy to measure while proving the React on Rails Pro rendering path. It should
not be overclaimed as a completed production component migration. A stronger
follow-up is to reuse the existing public Gumroad components with sanitized
production-shaped props where feasible, then compare those to an RSC equivalent.
The current branch adds sanitized local image/media fixtures so the buyer pages
visibly load image elements without copying creator media. The next stronger
follow-up is production-equivalent media parity: representative responsive image
sizes, cache headers, and CDN behavior should be documented before quoting
live-Gumroad-versus-demo PageSpeed numbers.

## Reproducible PageSpeed Diagnostic Pairs

The lab exposes ready-to-click PageSpeed links for the public URL pairs that
will matter for an upstream Gumroad issue after media parity is validated:

- Product detail this-host demo: `/public_product/rsc_demo` on the request host
- Product detail stable deployed demo: `https://gumroad.reactonrails.com/public_product/rsc_demo`
- Product detail live comparator: `https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search`
- Discover this-host demo: `/public_product/discover_rsc_demo` on the request host
- Discover stable deployed demo: `https://gumroad.reactonrails.com/public_product/discover_rsc_demo`
- Discover live comparator: `https://gumroad.com/discover`

Use mobile PageSpeed/Lighthouse reports to inspect remaining production gaps and
desktop as a sanity check. Do not quote the current live-Gumroad-versus-demo
scores as performance evidence: the earlier timeline comparison was not
apples-to-apples because the demo and live Gumroad page did not load equivalent
media and production chrome. The controlled architecture proof is still the
alternating same-host Inertia-vs-RSC benchmark, where both variants use the same
fixture data.
On review apps, the lab generates this-host PageSpeed links from the request
host and keeps separate stable-deployed links back to
`https://gumroad.reactonrails.com`, so reviewers can compare the PR, deployed
demo, and live Gumroad status quo without editing URLs by hand.

Current artifacts:

- Current stable media-bearing same-fixture ShakaPerf and resource audits:
  [performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md)
- Historical PR 69 review-app media-bearing ShakaPerf:
  [performance-artifacts/hosted-review-pr69-media-public-buyer-pages-2026-07-09/summary.json](./performance-artifacts/hosted-review-pr69-media-public-buyer-pages-2026-07-09/summary.json)
- Historical stable pre-media same-fixture ShakaPerf:
  [performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json)
- Same-fixture local ShakaPerf:
  [performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json)
- Same-fixture supporting PR 63 review-app ShakaPerf:
  [performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json)
- Diagnostic deployed-demo-vs-live Lighthouse comparator, not valid claim evidence until media parity:
  [performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json)

Before rerunning the current artifact against any host, run the media parity
gate:

```bash
node scripts/perf/assert_public_demo_media_parity.mjs \
  --base-url https://gumroad.reactonrails.com
```

The stable host currently passes. If a future check fails, capture the HTTP
status and warm the deployment before concluding that media parity regressed.

The PageSpeed Insights API returned HTTP `429` from the benchmark environment
on July 9, 2026 UTC, so the external URL-pair artifact uses a pinned local
`lighthouse@12.8.2` run. The deployed Lighthouse artifact includes
`pagespeed-api-probe.json` with the API response. Keep that artifact for
reproducibility and audit trail, but treat it as a diagnostic until the fixture
has production-equivalent media and the PageSpeed reports are rerun.

To re-sample public page shape without committing scraped content:

```bash
scripts/perf/sample_public_gumroad_shapes.mjs
```

The script reports component names, top-level prop keys, selected field shapes,
and counts. It intentionally does not write product copy or image assets into
the repository.

## Benchmark focus

Measure the public route pairs with the same disciplined alternating benchmark method.

Primary metrics:

- initial HTML completeness for product content and metadata
- total page-specific JavaScript transferred
- largest page-specific JavaScript chunk
- `LCP`
- total navigation duration
- `responseEnd`

Secondary metrics:

- HTML transfer size
- JS request count
- serialized Inertia payload size on the control route
- RSC payload timing when exposed as a browser resource
- route-level and renderer-level `Server-Timing`
- Lighthouse or equivalent SEO checks for crawlable title, description, canonical URL, and product content

The result should be written as a tradeoff, not a blanket claim. A useful win is lower client cost or better initial product HTML without a meaningful load-time regression.

## Dashboard Routes Are Not the Value Proof

The existing dashboard routes remain useful:

- `/dashboard/inertia_demo`
- `/dashboard/rsc_demo`

They prove that the React Server Components via React on Rails Pro path can run inside this app, use real data, isolate demo assets, and be measured against a matched Inertia control.

They should not be presented as the main SEO or conversion proof. Logged-in dashboard pages are not crawlable product landing pages, and they do not directly test the buyer-facing path where public rendering matters most.
