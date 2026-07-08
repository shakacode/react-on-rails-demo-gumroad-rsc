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

Shared evidence now has two layers:

- Current branch ShakaPerf run (`2026-07-08 UTC`, local headless Chrome, 6
  alternating cycles, same Tendon Book fixture, see
  [summary.json](./performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json)):
  product navigation `392.70ms` -> `212.80ms` (`-45.8%`), product
  `responseEnd` `337.40ms` -> `171.30ms` (`-49.2%`), product LCP
  `416.00ms` -> `224.00ms` (`-46.2%`); Discover navigation `375.45ms` ->
  `303.70ms` (`-19.1%`), Discover `responseEnd` `313.60ms` -> `245.25ms`
  (`-21.8%`), and Discover LCP `400.00ms` -> `322.00ms` (`-19.5%`).
- Historical hosted headless-Chrome run (`2026-06-24 UTC`, 8 alternating cycles
  against `https://gumroad.reactonrails.com`, see
  [summary.json](./performance-artifacts/hosted-public-buyer-pages-2026-06-24/summary.json)):
  JavaScript request count moved from `7` to `1` on both public route pairs and
  transfer dropped about `54%`, but this run predates the Tendon Book fixture and
  should be treated as supporting context rather than the current headline.

The remaining gaps below are what still make the final Gumroad-facing proof
harder: the current local run records stronger navigation/response/LCP evidence,
the hosted review-app run records current public-network navigation/LCP/JS
evidence with a response-end tradeoff, and the Lighthouse fallback is favorable;
PageSpeed API or field-data scores, RSC payload timing, CDN-safe streaming
timing, and hydration/interactivity marks still need first-class measurement.

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

Server time-to-last-byte regressions (the demo shows a ~3.2% Discover
`responseEnd` gap) can't be diagnosed without per-phase timing. Today there is no
first-class way to see where streamed RSC server time goes once a CDN is in front
of the app.

---

## Issue 3 — Hydration / interactivity performance marks for client islands

### What

React on Rails Pro does not emit standardized `performance.mark` / `measure`
entries at hydration boundaries (when a streamed server component's client
islands become interactive). The lab's live in-browser A/B race can measure
first-streamed-bytes and full-response download, but not the JavaScript execution
and hydration cost — which is exactly where the Inertia control is heaviest
(179 KB JS across 7 requests vs 1 for RSC).

- Emit opt-in hydration marks (per island and/or per page) that a client-side
  benchmark can read.

### Why

A fair client-side A/B benchmark must include hydration cost. Without these
marks, raw download-completion time misleadingly favors the smaller Inertia
document, hiding the RSC interactivity win. These marks let adopters measure
time-to-interactive directly.
