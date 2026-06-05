# Public Product RSC Demo

## Purpose

The next RSC comparison should make the value visible on a logged-out, public, product-like page.

Implemented route pair:

- `Inertia` control: `/public_product/inertia_demo`
- `React on Rails Pro + RSC` demo: `/public_product/rsc_demo`

Both routes render the same seeded public product content without requiring login.

The route intentionally selects the `demo` product owned by the seeded
`seller@gumroad.com` account and requires that product to be alive and
non-draft. If that seeded product is unavailable, the comparison routes 404
instead of silently falling back to another seller's permalink. Product
descriptions are passed through Gumroad's existing `Link#html_safe_description`
sanitizer before the React component renders the HTML string.

## Why this page matters

Dashboard routes are useful technical proofs, but they are not the strongest product proof.

A public product page is where rendering quality can affect:

- search indexing and metadata quality
- first meaningful content for logged-out visitors
- share previews and landing-page credibility
- conversion-sensitive product storytelling
- client JavaScript cost before a visitor decides whether to buy

That makes the public product route the better place to compare Gumroad/Inertia-style rendering with React on Rails Pro + RSC.

## What to compare

Keep the routes similar enough that the result is about rendering architecture, not page design.

The comparison should include:

- identical or near-identical product title, description, media, pricing, creator, and call-to-action content
- SEO-relevant HTML and metadata emitted in the initial document
- equivalent above-the-fold content and layout
- route-scoped demo assets so unrelated Gumroad pages do not pay for the experiment
- no login requirement, dashboard state, admin-only data, or seller-only controls

The RSC route should demonstrate server/client composition where it matters: product facts, purchase framing, and mostly static content can be server-rendered, while genuinely interactive controls stay client-side.

## Benchmark focus

Measure the public route pair with the same discipline used for the dashboard comparison.

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

They prove that the React on Rails Pro + RSC path can run inside this app, use real data, isolate demo assets, and be measured against a matched Inertia control.

They should not be presented as the main SEO or conversion proof. Logged-in dashboard pages are not crawlable product landing pages, and they do not directly test the buyer-facing path where public rendering matters most.
