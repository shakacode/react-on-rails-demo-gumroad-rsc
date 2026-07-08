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
See [docs/public-page-fixture-sampling.md](public-page-fixture-sampling.md) for
the sanitized shape artifact and the fixture sanitation policy.

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
The current comparison uses real-page-shaped synthetic fixtures:

- Discover listing page: a dense grid of product cards, categories, synthetic cover placeholders, prices, ratings, and recommendation context comparable to `https://gumroad.com/discover`
- Product detail page: a public product landing page with synthetic media placeholders, seller profile data, description length, recommendations, purchase framing, and mobile above-the-fold content
- Matched implementations: one route rendered with the current Inertia approach and one route rendered with React Server Components via React on Rails Pro
- Same data, same host, same measurement harness, so benchmark results reflect rendering architecture rather than fixture differences

Public Gumroad pages expose enough metadata, HTML, and Inertia page data to build these fixtures from a small set of public examples. For a public demo repository, prefer curated and sanitized fixture data or production-shaped synthetic data over broad scraping or wholesale copied creator content. Use real Gumroad URLs as external shape references, not as unreviewed committed content or the apples-to-apples A/B baseline.

The current "before" implementation intentionally uses a custom Inertia benchmark
surface rather than Gumroad's full production `Discover/Index` or
`Products/Discover/Show` components. That keeps the route pair same-data and
easy to measure while proving the React on Rails Pro rendering path. It should
not be overclaimed as a completed production component migration. A stronger
follow-up is to reuse the existing public Gumroad components with sanitized
production-shaped props where feasible, then compare those to an RSC equivalent.
Another stronger follow-up is to add sanitized local image/media fixtures and
rerun the benchmark, because the current committed route uses synthetic cover
placeholders rather than real creator media.

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
