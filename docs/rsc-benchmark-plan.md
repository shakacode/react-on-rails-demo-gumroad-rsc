# Public Product RSC Benchmark Plan

## Goal

Decide whether a `React on Rails Pro + React 19 + RSC` public product page is worth the extra complexity compared with a matched `Inertia` public product page.

The question is not whether `Rspack` is faster to build with. That is already established.

The question is whether `RSC` can make the logged-out, buyer-facing page better enough to matter for SEO, initial rendering, and conversion-sensitive loading behavior.

## Apples-to-apples rule

Compare the same public product-like surface:

- baseline: `Inertia` control at `/public_product/inertia_demo`
- candidate: `React on Rails Pro + RSC` at `/public_product/rsc_demo`

Keep these constant where possible:

- same local database
- same product-like data
- same Docker-backed services
- same nginx and browser setup
- same measurement harness

Run the harness in public mode:

`ruby scripts/perf/compare_dashboard_routes.rb --public --base-url https://gumroad.dev --measure-base-url https://gumroad.dev --path /public_product/inertia_demo --path /public_product/rsc_demo --label public-product-demo-alternating-4 --cycles 4 --server-warmup-requests 1 --require-driver-match`

## What should change in the candidate

The candidate should be narrow.

Target changes:

- keep the public product page intent and UI broadly the same
- replace the Inertia route with a React on Rails Pro route for this page only
- use `RSC` for product facts, description, media framing, creator context, and other read-heavy sections
- keep only truly interactive pieces as client components

## First candidate sections

Bias toward sections that are mostly display and data shaping:

- product title, description, and media
- creator and social-proof context
- price, availability, and purchase framing
- SEO-relevant metadata and canonical URL
- related static trust or policy content

Avoid spending the first pass on sections that are already cheap:

- admin-only controls
- dashboard-only state
- seller management flows

## Primary metrics

These are the metrics that matter for the first decision:

- initial product HTML and metadata completeness
- total public product JS transferred
- largest public product JS chunk
- public product `LCP`
- total public product navigation duration

## Secondary metrics

These help explain the result:

- HTML document size
- count of JS requests
- serialized page-prop payload size
- crawlable title, description, canonical URL, and product content
- server response end
- `/rsc_payload/` resource duration, response end, transfer size, and any resource-level `Server-Timing`
- route-level `Server-Timing` split between Rails/presenter work and renderer dispatch

## Suggested success bar

The first public `RSC` demo should be considered a meaningful performance win only if it can show something like:

- at least `20%` less public product JS transferred
- at least `10%` smaller largest client chunk
- equal or better SEO-relevant initial HTML and metadata
- equal or better `LCP`
- no meaningful regression in total navigation duration

If the page gets only marginally better while becoming much more complex, that is not a win.

## Qualitative checks

The performance result is not enough by itself. Also record:

- whether the server/client boundary is easier to reason about
- whether the page avoids sending product content as one large client-only payload
- whether the implementation isolates client interactivity more cleanly
- whether the review story looks believable for a bounded upstream discussion

## Dashboard technical proof

The existing dashboard pair remains useful:

- `/dashboard/inertia_demo`
- `/dashboard/rsc_demo`

Use it to validate integration, asset isolation, React on Rails Pro renderer boot, and benchmark harness behavior. Do not use it as the main SEO or conversion proof.

## Production-like follow-up pass

The local development benchmark is useful for direction, but it is not enough for a stronger performance claim.

The first production-like local pass was measured on the dashboard technical-proof pair. Treat it as benchmark-method history and integration evidence, not as the public product-page result.

That pass removed the dev-server as a confounder:

- build Shakapacker assets with `RENDERER_PASSWORD=benchmarkRendererPassword RAILS_ENV=production NODE_ENV=production bin/shakapacker`
- build the standalone RSC demo bundles with `RENDERER_PASSWORD=benchmarkRendererPassword RAILS_ENV=production NODE_ENV=production npm run build:rsc-demo`
- run Rails against compiled packs instead of the Shakapacker dev server
- run the Node renderer as a dedicated process with an explicit `RENDERER_PASSWORD`, `RENDERER_PORT`, `RENDERER_WORKERS_COUNT`, and `RENDERER_LOG_LEVEL`
- keep Chrome and ChromeDriver on the same major version and use `--require-driver-match`
- use the alternating comparison runner instead of grouped batches

Result from `production-like-alternating-8-reindexed`:

- median navigation: Inertia `775.40ms`, RSC `607.15ms`, `-21.7%`
- median `LCP`: Inertia `794.00ms`, RSC `634.00ms`, `-20.2%`
- median `responseEnd`: Inertia `644.80ms`, RSC `588.80ms`, `-8.7%`
- median `action_total`: Inertia `346.87ms`, RSC `339.20ms`, `-2.2%`
- JS request count: Inertia `6`, RSC `1`, `-83.3%`
- p95 `responseEnd`: Inertia `730.62ms`, RSC `768.25ms`, `+5.2%`

The benchmark JSON now records `/rsc_payload/` resource details separately from top-level navigation when the browser sees such a resource:

- aggregate payload transfer, encoded, and decoded bytes
- payload `duration`, `responseStart`, and `responseEnd`
- payload resource-level `serverTiming` entries when the browser exposes them
- primary comparison deltas for payload duration, payload response end, and payload transfer size

The current `/dashboard/rsc_demo` implementation streams the RSC payload inline, so it does not emit a browser resource named `/rsc_payload/` on the initial page load. In this run the new resource timing fields are therefore empty. That is still useful: it tells us the next profiling step should either expose a separate RSC payload resource for measurement or add renderer-internal `Server-Timing` in the React on Rails Pro streaming path.

## Decision outcomes

If the candidate wins:

- use it as the core case study for React on Rails Pro plus RSC positioning
- keep the upstream story narrow and evidence-backed

If the candidate does not win:

- keep the repo as a positioning and product-learning experiment
- do not pitch a migration story
- still use the repo to support `Shakapacker + Rspack` messaging for Inertia users
