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

- PR 69 media-bearing ShakaPerf run (`2026-07-09 UTC`, headless Chrome 150, 8
  alternating cycles against `https://rails-6rbrymb4tqrb6.cpln.app`, same
  Tendon Book fixture plus local synthetic media, see
  [summary.json](./performance-artifacts/hosted-review-pr69-media-public-buyer-pages-2026-07-09/summary.json)):
  product navigation `1292.15ms` -> `731.70ms` (`-43.4%`), product
  `responseEnd` `137.10ms` -> `170.15ms` (`+24.1%`), product LCP
  `992.00ms` -> `382.00ms` (`-61.5%`), and product JS requests `9` -> `1`;
  Discover navigation `1423.70ms` -> `1054.30ms` (`-25.9%`), Discover
  `responseEnd` `140.65ms` -> `261.60ms` (`+86.0%`), Discover LCP
  `960.00ms` -> `602.00ms` (`-37.3%`), and Discover JS requests `9` -> `1`.
- Stable deployed, local, and PR 63 review-app ShakaPerf runs from
  `2026-07-08` and `2026-07-09 UTC`, linked from
  [public-product-rsc-demo.md](./public-product-rsc-demo.md), remain useful
  chronology but predate the current media-bearing fixture or were captured on
  earlier PRs.
- Deployed Lighthouse URL-pair diagnostic (`lighthouse@12.8.2`, 3 runs per URL
  and strategy, see
  [summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json)):
  keep this as an audit trail and parity check, not as current proof. A timeline
  review showed the live Gumroad pages loaded production imagery and chrome that
  the demo did not yet match.

The remaining gaps below are what still make the final Gumroad-facing proof
harder: the media-bearing run records strong browser navigation, LCP, and JS
request-count evidence with honest response-end and payload-size tradeoffs.
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

Server time-to-last-byte regressions (the PR 69 media-bearing run shows a
`+86.0%` Discover `responseEnd` gap) can't be diagnosed without per-phase
timing. Today there is no first-class way to see where streamed RSC server time
goes once a CDN is in front of the app.

---

## Issue 3 — Hydration / interactivity performance marks for client islands

### What

React on Rails Pro does not emit standardized `performance.mark` / `measure`
entries at hydration boundaries (when a streamed server component's client
islands become interactive). The lab's live in-browser A/B race can measure
first-streamed-bytes and full-response download, but not the JavaScript execution
and hydration cost — which is exactly where the Inertia control is heaviest
(9 JS requests for Inertia vs 1 for RSC in the PR 69 media-bearing ShakaPerf run).

- Emit opt-in hydration marks (per island and/or per page) that a client-side
  benchmark can read.

### Why

A fair client-side A/B benchmark must include hydration cost. Without these
marks, raw download-completion time can overemphasize the smaller Inertia
document and under-measure the client-work savings from the RSC route. These
marks let adopters measure time-to-interactive directly.
