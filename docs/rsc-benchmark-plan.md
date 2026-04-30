# Dashboard RSC Benchmark Plan

## Goal

Decide whether a `React on Rails Pro + React 19 + RSC` dashboard is worth the extra complexity compared with the current `Inertia` dashboard.

The question is not whether `Rspack` is faster to build with. That is already established.

The question is whether `RSC` can make the page itself better enough to matter.

## Apples-to-apples rule

Compare the same route:

- baseline: current `Inertia` dashboard
- candidate: `React on Rails Pro + RSC` dashboard

Keep these constant where possible:

- same local database
- same logged-in seller
- same Docker-backed services
- same nginx and browser setup
- same measurement harness

## What should change in the candidate

The candidate should be narrow.

Target changes:

- keep the dashboard page intent and UI broadly the same
- replace the Inertia route with a React on Rails Pro route for this page only
- use `RSC` for read-heavy sections
- keep only truly interactive pieces as client components

## First candidate sections

Bias toward sections that are mostly display and data shaping:

- best-selling products table
- activity feed
- tax form and verification messages
- checklist container, with client-only controls if needed

Avoid spending the first pass on sections that are already cheap:

- simple stats cards

## Primary metrics

These are the metrics that matter for the first decision:

- total dashboard JS transferred
- largest dashboard JS chunk
- dashboard LCP
- total dashboard navigation duration

## Secondary metrics

These help explain the result:

- HTML document size
- count of JS requests
- serialized page-prop payload size
- server response end
- `/rsc_payload/` resource duration, response end, transfer size, and any resource-level `Server-Timing`
- route-level `Server-Timing` split between Rails/presenter work and renderer dispatch

## Suggested success bar

The first `RSC` demo should be considered a meaningful performance win only if it can show something like:

- at least `20%` less dashboard JS transferred
- at least `10%` smaller largest client chunk
- equal or better `LCP`
- no meaningful regression in total navigation duration

If the page gets only marginally better while becoming much more complex, that is not a win.

## Qualitative checks

The performance result is not enough by itself. Also record:

- whether the server/client boundary is easier to reason about
- whether the page stops depending on one large `creator_home` client payload
- whether the implementation isolates client interactivity more cleanly
- whether the review story looks believable for a bounded upstream discussion

## Production-like follow-up pass

The local development benchmark is useful for direction, but it is not enough for a stronger performance claim.

The first production-like local pass removed the dev-server as a confounder:

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
