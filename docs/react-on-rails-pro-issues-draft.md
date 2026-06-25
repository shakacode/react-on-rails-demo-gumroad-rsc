# React on Rails Pro upstream issue drafts

Drafts for `shakacode/react_on_rails_pro`, surfaced while building the public
buyer-page performance lab in this repo. Each follows the repo issue structure
(What / Why).

Filed:

- Issue 1 → https://github.com/shakacode/react_on_rails_pro/issues/586
- Issue 2 → https://github.com/shakacode/react_on_rails_pro/issues/587
- Issue 3 → https://github.com/shakacode/react_on_rails_pro/issues/588

Shared evidence (hosted headless Chrome, 8 alternating cycles, against
`https://gumroad.reactonrails.com`, see
[summary.json](performance-artifacts/hosted-public-buyer-pages-2026-06-24/summary.json)):
RSC wins navigation duration (-66% / -64%), LCP (-17% / -11%), JavaScript
transfer (-54%), and request count (7 -> 1), and removes the serialized Inertia
payload. The only places Inertia is not behind are HTML transfer size (RSC sends
more rendered HTML) and Discover `responseEnd` (+3.2%, inside the tie band). The
three gaps below are what blocked measuring and closing those last items.

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
