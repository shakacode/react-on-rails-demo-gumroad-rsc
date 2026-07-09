# Public Product RSC Demo

## Purpose

The next RSC comparison should make the value visible on a logged-out, public, product-like page.

Implemented routes:

- performance lab: `/rsc-demo` or `/public_product/performance_demo`
- product `Inertia` control: `/public_product/inertia_demo`
- product React Server Components via React on Rails Pro demo: `/public_product/rsc_demo`
- Discover `Inertia` control: `/public_product/discover_inertia_demo`
- Discover React Server Components via React on Rails Pro demo: `/public_product/discover_rsc_demo`

The lab and all implementation routes render without requiring login.
The lab should be opened first because it auto-loads the matched product and
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

The RSC route should demonstrate server/client composition where it matters: product facts, purchase framing, and mostly static content can be server-rendered, while genuinely interactive controls stay client-side.

## React on Rails Pro 17 / React 19.2 Notes

As of July 8, 2026, this demo is aligned with the React on Rails Pro 17 RC RSC line: React 19.2.7, React DOM 19.2.7, React on Rails Pro 17.0.0-rc.7, and `react-on-rails-rsc` 19.2.1-rc.0.

The public RSC routes opt into `rsc_stream_observability`, so the lab and external benchmark harnesses can inspect Pro stream attribution in `Server-Timing`, including streamed shell and Node renderer prepare timing when available. This replaces the older caveat that streamed RSC had no browser-visible renderer timing.

Pro 17's buffered/static RSC helpers are relevant to Gumroad-style public marketplace pages, but they change the benchmark claim. The headline route pair should stay matched and uncached; if the demo adds `cached_static_rsc_component`, it should be exposed as a separately named cached static RSC variant and measured against an appropriately labeled control.

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

- Same-fixture deployed ShakaPerf:
  [performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/deployed-public-buyer-pages-2026-07-08/summary.json)
- Same-fixture local ShakaPerf:
  [performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json)
- Same-fixture supporting PR 63 review-app ShakaPerf:
  [performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json)
- Diagnostic deployed-demo-vs-live Lighthouse comparator, not valid claim evidence until media parity:
  [performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json)

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
