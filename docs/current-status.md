# Current Status

## Short answer

The demo pair is implemented, measurable, and now useful for positioning.

It is **not** ready for an upstream pitch yet, but it is no longer just a compile-and-run experiment.

This repository has moved past pure planning, through the Rspack migration branch, and into a matched Inertia-versus-React on Rails Pro comparison surface.

## Shareable references

- repo: [shakacode/react-on-rails-demo-gumroad-rsc](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc)
- consolidated demo PR: [react-on-rails-demo-gumroad-rsc#11](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/11)
- follow-up PR: [react-on-rails-demo-gumroad-rsc#10](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/10)
- React on Rails hub issue: [react_on_rails#3128](https://github.com/shakacode/react_on_rails/issues/3128)
- benchmark and positioning issue: [react_on_rails#3144](https://github.com/shakacode/react_on_rails/issues/3144)

The earlier review stack ([#1](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/1), [#2](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/2), [#3](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/3), [#6](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/6), [#7](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/7), [#8](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/8), [#9](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/9)) was closed unmerged after the work was consolidated into [#11](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/11).

## What is already done

- Created the public experiment repo under `shakacode/react-on-rails-demo-gumroad-rsc`
- Seeded it from current `antiwork/gumroad`
- Preserved `upstream` so the experiment stays grounded in the real app
- Documented the comparison plan in [rsc-comparison-plan.md](./rsc-comparison-plan.md)
- Documented the runtime pass/fail rubric in [rsc-benchmark-plan.md](./rsc-benchmark-plan.md)
- Documented positioning, adjacent ideas, and IP guardrails in [positioning-notes.md](./positioning-notes.md)
- Added a single performance handoff doc for review circulation in [performance-team-handoff.md](./performance-team-handoff.md)
- Selected `Dashboard` as the first comparison surface
- Documented the first implementation-facing brief in [dashboard-experiment-brief.md](./dashboard-experiment-brief.md)
- Documented measured results in [performance-findings.md](./performance-findings.md)
- Added a browser-level smoke spec that renders both `/dashboard/inertia_demo` and `/dashboard/rsc_demo` through a real headless browser in CI
- Added route-scoped `Server-Timing` instrumentation to both comparison routes and to the benchmark output
- Added an alternating benchmark runner in `scripts/perf/compare_dashboard_routes.rb` so route order is balanced across cycles
- Added benchmark runner support for `--require-driver-match` and `--reuse-existing` so headline runs fail fast on browser-driver mismatch and long runs can be recovered without remeasuring completed samples
- Added median and `p95` primary-metric deltas plus slowest-pack-resource summaries to the alternating comparison output so dev-asset outliers are obvious without manual per-run digging
- Added a shared JS Shakapacker config loader so the custom Webpack and Rspack config honors `SHAKAPACKER_DEV_SERVER_*` overrides the same way Ruby/Shakapacker already does
- Added `/rsc_payload/` resource timing, transfer-size, and resource-level `Server-Timing` summaries to the benchmark JSON so renderer-adjacent overhead is easier to isolate
- Installed Ruby gems locally
- Installed `node_modules` locally
- Brought up the Docker-backed local services
- Confirmed the targeted dashboard controller and presenter spec surface passes locally once required seed data exists
- Upgraded `shakapacker` to `10.0.0`
- Upgraded React and React DOM to `19.2.5`
- Switched the local Shakapacker bundler path from Webpack to Rspack
- Added a real `config/rspack/` config tree instead of relying on the deprecated webpack-config fallback
- Confirmed `bin/shakapacker` builds successfully in both development and production with Rspack
- Confirmed `bin/shakapacker-dev-server` boots successfully on its default `https://gumroad.dev:3035/` endpoint and on an overridden clean port for local verification
- Removed an obsolete `patch-package` patch for `react-dom@18.3.1` because React 19 already includes the needed `inert` support
- Added React on Rails Pro and the Node renderer configuration locally
- Added a dedicated `/dashboard/rsc_demo` route backed by the existing `CreatorHomePresenter`
- Added a matching `/dashboard/inertia_demo` route using the same reduced seller-data surface
- Built a bounded React on Rails Pro plus RSC dashboard surface that reuses real seller data
- Built a matched Inertia control surface that shares the same reduced UI intent
- Isolated the RSC route from the main Inertia `base` pack so the comparison surface is actually separate
- Kept the demo-only JS and CSS route-scoped so non-demo pages do not download the comparison assets
- Wired React on Rails nonce handling into Gumroad's `SecureHeaders` setup so streamed inline RSC payload scripts are allowed under CSP
- Regenerated `js-routes` so the comparison routes are available to both the Inertia and RSC demo code
- Added explicit development host allowlisting for the local Gumroad domains so the benchmark/login flow works again on `gumroad.dev:3000`
- Captured successful browser measurements for the matched Inertia and RSC demo routes
- Manually verified both demo routes in a signed-in browser session and captured comparison screenshots in `docs/images/`
- Fixed the standalone RSC demo test-build path so `RAILS_ENV=test` writes the client manifest and browser bundle to `public/packs-test`, which made browser-level CI validation of the RSC route possible
- Reduced the raw RSC comparison response from about `36.9KB` to about `15.1KB` by trimming server markup, compacting demo props, and rebuilding the dedicated RSC bundles
- Re-ran `spec/presenters/product_presenter/product_props_spec.rb` after seeding merchant accounts in test: `26 examples, 0 failures`
- Re-ran `spec/presenters/creator_home_presenter_spec.rb`: `22 examples, 0 failures`

## What is not done yet

- the React 19 type fallout has not been cleaned up yet across the app
- the broad React 19 cleanup still needs its own reviewable branch strategy
- the full current `/dashboard` route is still too noisy for a fair RSC-versus-Inertia story
- production-like local benchmarking now exists, but a deployed repeat and renderer-internal profiling are still missing
- the demo has not yet been reduced to a compelling upstream-review story

## What "demo ready" means

The demo should not be considered upstream-ready until it can show all of the following:

- one clearly chosen page or flow
- a matched Inertia implementation running as the control
- a bounded React on Rails Pro implementation of the same surface
- enough React 19 or RSC usage to make the comparison meaningful
- disciplined measurements for loading behavior and developer tradeoffs
- a short written conclusion that says where Inertia wins and where React on Rails Pro wins

## Measured findings

The matched comparison measurements now exist, and the latest local pass now includes route-scoped `Server-Timing`.

Short version:

- Rspack is a strong developer-performance win here
- no route-level runtime win was expected from the bundler swap by itself
- the stricter production-like alternating local benchmark has the `RSC` route ahead on median navigation duration, median `LCP`, and median `responseEnd`
- the latest pass still has a caution: `p95 responseEnd` is modestly worse for the `RSC` route
- route order and warm-state effects are real enough that the alternating runner is now the benchmark method that matters

That means the demo is now real, the user-visible story is favorable, and the remaining tradeoff is specific enough to hand to performance engineers.

The missing piece is no longer "can this compile?" or "does it survive a production-like local pass?" The missing piece is "does the favorable local result survive a deployed repeat and renderer profiling?"

The benchmark rubric for that decision now lives in [rsc-benchmark-plan.md](./rsc-benchmark-plan.md).

## Environment readiness

Current local state:

- Docker is available
- Docker-backed services are running
- `node_modules` is installed
- gems are installed
- Rails boots locally on port `3000`
- the Rspack-backed Shakapacker dev server boots locally on port `3035`, and the same setup now works on an overridden clean port such as `3036`
- production-built Shakapacker/Rspack assets build locally with `RAILS_ENV=production NODE_ENV=production bin/shakapacker`
- production-built RSC demo bundles build locally with `RAILS_ENV=production NODE_ENV=production npm run build:rsc-demo`
- `bin/dev` now boots the standalone React on Rails Pro Node Renderer on port `3800`
- local nginx now boots once `helperai.dev` cert files exist

That means the repository is now ready for comparison work on this machine.

## Setup findings that matter

- `RAILS_ENV=test bin/rails db:prepare` was not enough for the dashboard spec surface because the test database had no `MerchantAccount` rows.
- Loading the three merchant-account seed files in `RAILS_ENV=test` fixed that hidden prerequisite and made the targeted dashboard suite pass.
- `make local` initially left nginx down because `docker/local-nginx/helperai_dev.crt` and `.key` were missing.
- The repository already includes `bin/generate_ssl_certificates` for this, but on macOS it may fail at `mkcert -install` if local sudo access is not available.
- For local-only boot, generating the `helperai.dev` cert files without installing the CA is sufficient to get nginx running, though browsers may still warn about trust.
- A later manual verification pass found that another local repo's plain-HTTP webpack dev server had reclaimed port `3035`, which made Rails proxy `https://app.gumroad.dev/packs/...` asset requests to the wrong process and return `500`.
- The fix was to make the custom JS bundler config honor `SHAKAPACKER_DEV_SERVER_PORT`, then restart both Puma and `bin/shakapacker-dev-server` with the same override on a clean port such as `3036`.
- After that correction, both `/dashboard/inertia_demo` and `/dashboard/rsc_demo` rendered cleanly in a signed-in browser session again.
- An older mixed-port repeat with matching `Chrome 147` and `ChromeDriver 147` removed the earlier browser-driver mismatch, but one RSC dev-asset load still reported a `~19.3s` zero-transfer CSS duration.
- Fresh local Docker volumes need Elasticsearch indexes before the dashboard demo routes are stable; run `DISABLE_SPRING=1 OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES bin/rails runner 'DevTools.delete_all_indices_and_reindex_all'` after `bin/rails db:prepare`.
- The corrected clean-port `8`-cycle repeat on `3036` did not reproduce that outlier, which makes the older run more useful as a diagnostic than as the current headline.

## Verified implementation state

- Development build: `RAILS_ENV=development NODE_ENV=development bin/shakapacker --mode development`
  Result: successful Rspack build for both the main app bundles and widget bundles
- Production build: `RAILS_ENV=production NODE_ENV=production bin/shakapacker`
  Result: successful Rspack build with asset-size warnings but no compilation failures
- Dev server: `RAILS_ENV=development NODE_ENV=development bin/shakapacker-dev-server`
  Result: boots successfully on `https://gumroad.dev:3035/`
- Override-friendly dev server: `SHAKAPACKER_DEV_SERVER_PORT=3036 RAILS_ENV=development NODE_ENV=development bin/shakapacker-dev-server`
  Result: serves `https://gumroad.dev:3036/`, and Rails asset proxy requests succeed when Puma is started with the same `SHAKAPACKER_DEV_SERVER_PORT=3036`
- Standalone RSC build: `npm run build:rsc-demo`
  Result: successful React on Rails Pro bundle build
- Manual browser verification: signed-in local session on `https://gumroad.dev/dashboard/inertia_demo` and `https://gumroad.dev/dashboard/rsc_demo`
  Result: both routes render their expected demo headings after the clean-port override fix

## Current blocker for calling the branch "review ready"

The build path is working and the matched comparison surface is running, but two blockers remain before this is review ready as a persuasive stacked branch:

- React 19 adoption still exposes broad TypeScript cleanup work across the app.
- The strictest local result is now a compiled-asset measurement, but it is still local and renderer-internal profiling is still missing.

Current `npx tsc --noEmit` results still show app-wide errors in categories like:

- stricter React 19 `ref` typing
- callback refs that return values instead of `void`
- implicit `any` in callbacks that previously slipped through
- at least one `isolatedModules`-related type-only import fix

That means the branch has crossed the important threshold of "Rspack migration is viable here" and "a matched React on Rails Pro comparison is feasible here", but it has not yet crossed the threshold of "this is an easy upstream review with deployed, production-grade runtime-performance evidence."

## Latest production-like alternating local comparison result

The strictest current local comparison uses `scripts/perf/compare_dashboard_routes.rb`, which rotates route order by cycle instead of relying on separate grouped batches.

Short version:

- the `RSC` demo works end to end under React on Rails Pro
- the `Inertia` control works end to end on the same reduced data surface
- the latest balanced alternating run uses compiled Shakapacker/Rspack assets, compiled RSC demo bundles, no Shakapacker dev server, and a dedicated Node renderer
- the run used matching `Chrome 147` and `ChromeDriver 147`
- under that method, the `RSC` route is faster on median navigation duration, median `LCP`, median `responseEnd`, and median route-level `action_total`
- the main caution is `p95 responseEnd`, where the RSC route is still modestly worse
- the current story is now favorable enough for performance-team review, but not yet enough for a production-performance claim

Useful numbers:

- median Inertia navigation duration: `775.40ms`
- median RSC navigation duration: `607.15ms`
- median Inertia LCP: `794.00ms`
- median RSC LCP: `634.00ms`
- median Inertia response end: `644.80ms`
- median RSC response end: `588.80ms`
- median Inertia `action_total`: `346.87ms`
- median RSC `action_total`: `339.20ms`
- median Inertia `compare_props`: `311.50ms`
- median RSC `compare_props`: `294.38ms`
- median Inertia HTML transfer: `14,223` bytes
- median RSC HTML transfer: `12,373` bytes
- p95 Inertia response end: `730.62ms`
- p95 RSC response end: `768.25ms`

So the current conclusion is:

- the comparison surface is real
- the user-visible win is still real on the matched surface after moving to compiled assets and a dedicated renderer process
- the latest stricter method has median navigation, median `LCP`, median `responseEnd`, and median `action_total` in the RSC route's favor
- the `p95 responseEnd` caution remains, so the performance story should not be oversold
- measurement order still matters, and the alternating runner remains the defensible local method
- the older dev-server 8-cycle repeats are still useful outlier-detection artifacts, but the compiled-asset 8-cycle run is the better current headline
- the performance pitch is promising, but it still needs a deployed repeat or renderer-internal profiling before an upstream migration proposal

## Recommended next step

The next real step is to keep the claims and branches narrow.

Recommended order:

1. Preserve this branch as the "Shakapacker 10 plus Rspack viability" branch.
2. Decide whether React 19 type cleanup belongs in the same branch or in a follow-up stacked branch.
3. Treat `/dashboard/inertia_demo` as the primary Inertia control, not the full dashboard.
4. Keep `/dashboard/rsc_demo`, but use the alternating runner and route-scoped `Server-Timing` together when making any performance claim.
5. Keep CI honest with the GitHub-hosted demo validation workflow for this public repo: it validates the Rspack build, the targeted demo controller specs, and the standalone `npm run build:rsc-demo` path.
   It now also boots the Node renderer and runs a headless browser smoke spec for both demo routes.
6. Repeat the production-like alternating comparison on a stable deployed environment, ideally Control Plane, before using the numbers externally.
7. Add renderer-internal timing or expose a separate `/rsc_payload/` browser resource; the current route streams the RSC payload inline, so the browser resource timing fields stay empty.
8. Only then decide whether a deeper upstream migration story is warranted.

## Suggested branch sequence

- `jg-codex/baseline-dashboard`
- `jg-codex/react19-rspack`
- `jg-codex/react19-type-cleanup` if the type fallout is too noisy for the bundler branch
- `jg-codex/react-on-rails-pro-demo`
- `jg-codex/demo-server-timing`
- `jg-codex/benchmark-headline-metrics`

## Adjacent ideas to keep documented but out of scope for the first demo

- a clean-room Inertia extension that improves React 19 SSR behavior
- a React 19 compatibility guide for Inertia users
- a Shakapacker plus Rspack positioning story that works for both Inertia and React on Rails users

## Decision rule

If the matched React on Rails Pro plus RSC comparison cannot keep the user-visible win while making the server-response tradeoff understandable, then the right output is better positioning insight, not a migration pitch.
