# React on Rails upstream issues from the performance lab

Surfaced while building the public buyer-page performance lab in this repo, and
filed against `shakacode/react_on_rails` — the active monorepo where React on
Rails Pro is now developed (the `shakacode/react_on_rails_pro` repo is
historical/read-only). Each follows the repo issue structure (What / Why).

Filed:

- Expose the RSC flight payload as an inspectable browser resource with timing →
  https://github.com/shakacode/react_on_rails/issues/4205
- Provide CDN-safe, streaming-compatible renderer/route Server-Timing for
  streamed RSC responses → https://github.com/shakacode/react_on_rails/issues/4206
- Emit hydration / interactivity performance marks for client islands →
  https://github.com/shakacode/react_on_rails/issues/4207

Shared evidence now has three layers:

- Current native-product ShakaPerf CLI run (`2026-08-12`, ten simultaneous
  mobile Lighthouse measurements per side): FCP improves `76%` on both products,
  LCP improves `74%/49%`, Lighthouse rises `35 -> 77` and `43 -> 71`, and
  JavaScript requests fall `41 -> 3`. The cost is `TTFB +35%/+39%`, JavaScript
  transfer `+206%`, downloads `+56%/+36%`, and Microsoft `TBT 0 -> 199ms`.
  The command exits `1` with two performance regressions. See the
  [artifact](./performance-artifacts/native-product-rsc-shakaperf-2026-08-12/README.md).
- The July Ruby/Selenium public-demo run, PR 69 review app, stable pre-media,
  local, and PR 63 runs remain useful historical chronology. They are not the
  current headline and must not be labeled ShakaPerf CLI output.
- Deployed Lighthouse URL-pair diagnostic (`lighthouse@12.8.2`, 3 runs per URL
  and strategy, see
  [summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json)):
  keep this as an audit trail and parity check, not as current proof. A timeline
  review showed the live Gumroad pages loaded production imagery and chrome that
  the demo did not yet match.

The remaining gaps below are what still make the final Gumroad-facing proof
harder: the native run records strong paint and request-count evidence, but the
suite fails its transfer/TTFB gates. The analytics/legacy-bundle asymmetry also
limits causal attribution.
PageSpeed API or field-data scores after production-equivalent media parity,
RSC payload timing, CDN-safe streaming timing, and hydration/interactivity marks
still need first-class measurement.

---

## Issue 1 — Expose the RSC flight payload as an inspectable browser resource

### What

When streaming server components with `stream_react_component`, the serialized
RSC flight payload is inlined into the streamed document, so the browser has no
named resource and no Resource Timing entry for it. The performance lab can
measure the Inertia control's serialized `data-page` payload (12–25 KB) but has
no equivalent measurement for the RSC route.

- Provide a supported way to measure the RSC payload: a named/fetchable resource,
  or an emitted byte-size + flush-timing value via a documented hook or
  `Server-Timing` entry.
- Make it work for the streaming (`auto_load_bundle: false`) path used here.

### Why

RSC removes the Inertia JSON payload but adds inline flight data. Adopters can't
make an honest before/after payload claim — or list "RSC payload timing" as a
real metric — while that payload is unmeasurable from the browser.

---

## Issue 2 — CDN-safe, streaming-compatible renderer/route Server-Timing

### What

For streamed RSC responses (`ActionController::Live` +
`stream_view_containing_react_components`), a trailing `Server-Timing` header
cannot be set after the body has started streaming, so renderer/route timing
never reaches the browser. Behind a CDN (Cloudflare on the hosted demo) only the
edge's own `Server-Timing` survives; the app's `render_dispatch` / `action_total`
marks are absent client-side.

- Offer a supported way to emit RSC render + flush phase timing for streamed
  responses: HTTP trailers, an inline timing mark in the streamed document, or a
  `PerformanceObserver`-readable marker.
- Document CDN considerations (header stripping, trailer support).

### Why

Server time-to-last-byte behavior cannot be fully diagnosed without per-phase
timing. The current stable Discover aggregate is within the 5% tie band, but
its batch direction flips and stream-shell timing is variable. A first-class
phase breakdown is still useful once a CDN is in front of the app.

---

## Issue 3 — Hydration / interactivity performance marks for client islands

### What

React on Rails Pro does not emit standardized `performance.mark` / `measure`
entries at hydration boundaries (when a streamed server component's client
islands become interactive). The current public demo has no client islands, so
this is not a blocker for its present headline. A future interactive variant's
live in-browser A/B race can measure
first-streamed-bytes and full-response download, but not the JavaScript execution
and hydration cost — which is exactly where the Inertia control is heaviest
(41 JavaScript requests for the control vs 3 for the experiment in the current
native-product ShakaPerf run).

- Emit opt-in hydration marks (per island and/or per page) that a client-side
  benchmark can read.

### Why

A fair client-side A/B benchmark must include hydration cost. Without these
marks, raw download-completion time can overemphasize the smaller Inertia
document and under-measure the client-work savings from the RSC route. These
marks let adopters measure time-to-interactive directly.
