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

The headline routes use static, synthetic, production-shaped fixtures so the
public benchmark is stable, logged out, and same-origin. A small shape sampler inspected public Gumroad
`Discover/Index` and `Products/Discover/Show` pages to identify field and layout
shape. The committed fixture does not copy creator text, seller URLs, product
thumbnails, or real product names.

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

## Production-Shaped Fixtures

The early small product route was useful for validating the rendering path, but
it was too small to settle whether Gumroad should consider adopting this stack.
The current comparison uses real-page-shaped synthetic fixtures:

- Discover listing page: a dense grid of product cards, categories, thumbnails, prices, ratings, and recommendation context comparable to `https://gumroad.com/discover`
- Product detail page: a public product landing page with realistic media, seller profile data, description length, recommendations, purchase framing, and mobile above-the-fold content
- Matched implementations: one route rendered with the current Inertia approach and one route rendered with React Server Components via React on Rails Pro
- Same data, same host, same measurement harness, so ShakaPerf results reflect rendering architecture rather than fixture differences

Public Gumroad pages expose enough metadata, HTML, and Inertia page data to build these fixtures from a small set of public examples. For a public demo repository, prefer curated and sanitized fixture data or production-shaped synthetic data over broad scraping or wholesale copied creator content. Use real Gumroad URLs as external shape references, not as unreviewed committed content or the apples-to-apples A/B baseline.

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
