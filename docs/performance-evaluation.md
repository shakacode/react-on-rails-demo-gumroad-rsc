# RSC Performance Evaluation

## What this is

This repo contains two production-shaped public buyer-page comparisons:

- product `Inertia` control route: `/public_product/inertia_demo`
- product React Server Components via React on Rails Pro route: `/public_product/rsc_demo`
- Discover `Inertia` control route: `/public_product/discover_inertia_demo`
- Discover React Server Components via React on Rails Pro route: `/public_product/discover_rsc_demo`

These are the value-proof surfaces because they are logged out, SEO-sensitive, conversion-sensitive, mobile-heavy, and visible without a demo account.

The [RSC lab benchmark contract v1](./rsc-lab-benchmark-contract-v1.md) is the normative boundary for fixture identity, serialized execution, evidence classification, and deferred final-release validation. In particular, “production-shaped” describes a measurable fixture, not production traffic or a field-performance claim.

Use `--public` with the benchmark runner for these pairs so measurements avoid login and dashboard cookies.

The older dashboard comparison is still useful technical proof:

- `Inertia` control route: `/dashboard/inertia_demo`
- React Server Components via React on Rails Pro route: `/dashboard/rsc_demo`

That pair uses the same reduced creator-home presenter surface and the same outer `inertia` layout. It proves integration, asset isolation, and benchmark discipline; it is not the main value proof for SEO or conversion.

The goal is not to prove that "RSC is always faster."
The goal is to measure whether a bounded RSC surface can produce a meaningful user-visible win that justifies the added complexity.

## Shareable references

- repo: [shakacode/react-on-rails-demo-gumroad-rsc](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc)
- consolidated demo PR: [react-on-rails-demo-gumroad-rsc#11](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/11)
- follow-up PR: [react-on-rails-demo-gumroad-rsc#10](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/10)
- production-like benchmark PR: [react-on-rails-demo-gumroad-rsc#12](https://github.com/shakacode/react-on-rails-demo-gumroad-rsc/pull/12)
- React on Rails hub issue: [react_on_rails#3128](https://github.com/shakacode/react_on_rails/issues/3128)
- benchmark and positioning issue: [react_on_rails#3144](https://github.com/shakacode/react_on_rails/issues/3144)

## Current Conclusion

The stable media-bearing result supports a bounded end-to-end RSC navigation
win, but it is not yet a Gumroad adoption proof.

What is independently verified:

- PR 69 is merged and deployed; the stable media gate passes.
- Both route pairs use the same deterministic presenter props and shared UI.
- Two independent stable-deployment batches show clear full-navigation wins,
  about half the JavaScript transfer, and one route script instead of nine.
- Product LCP is modestly better. Discover LCP is directionally better but
  noisy. Response end is a tie/inconclusive and must not be claimed as a win.
- The live Gumroad PageSpeed comparison remains diagnostic because media,
  chrome, caching/CDN behavior, fonts, and third-party requests differ sharply.

The causal limit is important: the RSC route intentionally skips legacy
application JavaScript and uses an isolated client bundle, while the Inertia
route also loads analytics/tag-manager resources omitted from RSC. Bundle
isolation is part of the candidate architecture; third-party omission is a
parity gap. The result should be described as “these deployed routes” rather
than “RSC alone.”

Before measuring a deployment, run:

```bash
node scripts/perf/assert_public_demo_media_parity.mjs \
  --base-url "${TARGET_BASE_URL:-https://gumroad.reactonrails.com}"
```

A first cold probe received a transient `503`, then the exact command passed
after deployment warm-up. Record HTTP failures and keep the two explicit
warmups in every measured run.

## Current Stable Media-Bearing Public Buyer-Page Result

Captured July 10, 2026 UTC against `https://gumroad.reactonrails.com` at main
commit `cc61125b02ec0282ec455c044240e97b6a33b741`. Environment: Chrome
`150.0.7871.49`, ChromeDriver `150.0.7871.115`, Selenium `4.45.0`, Ruby `3.4.3`,
Apple M5 Max, 128 GiB, macOS 26.5.1. Method: two independent batches, eight
alternating cycles per batch, two warmups per measured run, public mode, and
required Chrome/driver major-version match.

| Surface | Median navigation | Median response end | Median LCP | JS transfer | Inertia payload |
| --- | ---: | ---: | ---: | ---: | ---: |
| Product | `1123.5ms` -> `575.0ms` (`-48.8%`) | `504.85ms` -> `509.55ms` (`+0.9%`) | `662ms` -> `602ms` (`-9.1%`) | `162,696 B` -> `82,228.5 B` (`-49.5%`) | `15,040 B` -> none |
| Discover | `1097.9ms` -> `630.45ms` (`-42.6%`) | `473.9ms` -> `492.8ms` (`+4.0%`) | `768ms` -> `648ms` (`-15.6%`) | `162,696 B` -> `82,223 B` (`-49.5%`) | `33,966 B` -> none |

The combined-median encoded HTML body (compressed, headers excluded) is larger
(`+80.4%` Product, `+100.2%` Discover), while combined-median decoded
JavaScript + CSS is `53.2%` lower. Product renderer-prepare / stream-shell
medians are `2.3ms` / `33.03ms`; Discover medians are `3.62ms` / `130.65ms`.

The summary, four batch manifests, 64 underlying run files, and desktop/mobile
resource audits are in
[performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md).

The PR 69 review-app artifact, pre-media stable artifact, local run, PR 63 run,
and June hosted run remain historical chronology. They are not the current
headline and must not be mixed with the stable aggregate.

## Supporting PR 63 Review-App Public Buyer-Page Result

Captured on `2026-07-08 UTC` against PR 63 review app
`https://rails-ejbbntm539k6r.cpln.app` with headless Chrome `149`, `6`
alternating cycles per route pair, `2` server warmup requests per measured run,
`--public`, and `--require-driver-match`.

| Surface              |                 Median nav duration |                  Median response end |                    Median LCP start |           JS requests |
| -------------------- | ----------------------------------: | -----------------------------------: | ----------------------------------: | --------------------: |
| Product detail       | `602.75ms` -> `502.20ms` (`-16.7%`) |  `153.00ms` -> `193.00ms` (`+26.1%`) | `500.00ms` -> `394.00ms` (`-21.2%`) | `7` -> `1` (`-85.7%`) |
| Discover marketplace | `605.30ms` -> `529.25ms` (`-12.6%`) | `152.10ms` -> `357.25ms` (`+134.9%`) | `508.00ms` -> `430.00ms` (`-15.4%`) | `7` -> `1` (`-85.7%`) |

Supporting details are in
[performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json](./performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json).

Interpretation:

- the supporting review-app result preserved the same direction for median browser navigation and LCP before merge
- the RSC route reliably cuts route JavaScript requests from `7` to `1`
- RSC loses median response-end on the review app, especially on Discover, because the server streams more complete HTML
- this makes the honest pitch sharper: faster browser completion and less client JavaScript, not universally lower server TTLB

## Deployed Lighthouse Public URL-Pair Diagnostic

The PageSpeed Insights API returned HTTP `429` from this environment, so the
external comparator was captured with local `lighthouse@12.8.2` and `3` runs
per URL per mobile/desktop strategy. The deployed artifact includes
`pagespeed-api-probe.json` with the API response.

Supporting details are in
[performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json](./performance-artifacts/lighthouse-public-comparator-deployed-2026-07-08/summary.json).

Interpretation:

- do not quote the current live-Gumroad-versus-demo score or LCP deltas as evidence
- a resource audit confirmed the comparison is not apples-to-apples: live Gumroad loads far more mixed-format media, different chrome, caching/CDN policies, fonts, and third-party services
- use this artifact as an audit trail and a reproducible diagnostic until those differences are controlled or explicitly documented
- the next external proof step is a documented production-parity target plus mobile-throttled or field-relevant corroboration, especially for `INP`

The dashboard RSC implementation is also **promising but not fully optimized**.

What is already true:

- the RSC route wins on total navigation duration
- the RSC route wins on `LCP`
- the production-like compiled-asset alternating local benchmark has the RSC route ahead on median navigation duration, median `LCP`, and median `responseEnd`
- the RSC route reduces page-specific JS requests from `6` to `1` in the latest balanced pass
- the demo JS and CSS are route-scoped, so unrelated pages are not paying for the experiment
- the raw RSC HTML transfer is now close to the Inertia control after the response-end pass
- the dashboard result is useful for proving the stack, but the public product and Discover routes must carry the SEO and conversion story

What is not yet proven:

- the strongest result is still a local measurement, not a deployed production measurement
- one earlier headline run used a mismatched local Chrome and chromedriver pair, and the later matched-driver repeat exposed a development-asset outlier on one RSC run
- measurement order affects cache state enough that grouped batches can overstate the gap
- `p95 responseEnd` is still modestly worse for the RSC route on the production-like local run
- the current route streams the RSC payload inline, so browser `/rsc_payload/` resource timing remains empty until we expose a separate resource or renderer timing
- the production-shaped product and Discover routes now have stable media-bearing desktop evidence, but not valid mobile-throttled causal evidence against live Gumroad

## Latest production-like alternating local result

Measured with:

- production-built Shakapacker/Rspack assets: `RENDERER_PASSWORD=benchmarkRendererPassword RAILS_ENV=production NODE_ENV=production bin/shakapacker`
- production-built RSC demo bundles: `RENDERER_PASSWORD=benchmarkRendererPassword RAILS_ENV=production NODE_ENV=production npm run build:rsc-demo`
- local Docker-backed services with Elasticsearch indexes recreated via `DevTools.delete_all_indices_and_reindex_all`
- Rails running without `bin/shakapacker-dev-server`
- standalone React on Rails Pro Node renderer with `RENDERER_PASSWORD=benchmarkRendererPassword`, `RENDERER_PORT=3800`, `RENDERER_WORKERS_COUNT=2`, and `RENDERER_LOG_LEVEL=warn`
- matching `Chrome 147` and `ChromeDriver 147`
- `8` alternating cycles with one explicit warmup request per measured run

The first long run wrote `14` of `16` samples and then hit a Selenium `Net::ReadTimeout` while loading the RSC route. The comparison was completed with `--reuse-existing`, which reused the completed JSON files and measured the two missing samples.

Artifacts:

- tracked comparison JSON: `docs/performance-artifacts/production-like-alternating-8-reindexed/comparison.json`
- tracked raw metrics directory: `docs/performance-artifacts/production-like-alternating-8-reindexed/runs`

### Browser metrics

| Metric                     | Inertia demo |   RSC demo |    Delta |
| -------------------------- | -----------: | ---------: | -------: |
| Median navigation duration |   `775.40ms` | `607.15ms` | `-21.7%` |
| Median response end        |   `644.80ms` | `588.80ms` |  `-8.7%` |
| Median LCP                 |   `794.00ms` | `634.00ms` | `-20.2%` |
| Median HTML transfer       |   `14,223` B | `12,373` B | `-13.0%` |
| JS request count           |          `6` |        `1` | `-83.3%` |
| p95 response end           |   `730.62ms` | `768.25ms` |  `+5.2%` |

### Route-scoped server timings

| Metric                           | Inertia demo |   RSC demo |    Delta |
| -------------------------------- | -----------: | ---------: | -------: |
| Median controller `action_total` |   `346.87ms` | `339.20ms` |  `-2.2%` |
| Median presenter `compare_props` |   `311.50ms` | `294.38ms` |  `-5.5%` |
| Median `sql.active_record`       |   `130.74ms` | `128.87ms` |  `-1.4%` |
| Median `render_dispatch`         |    `30.01ms` |  `26.18ms` | `-12.8%` |
| p95 `sql.active_record`          |   `151.58ms` | `164.19ms` |  `+8.3%` |

This is the strongest local evidence so far. It keeps the user-visible RSC win after removing the Shakapacker dev server as a confounder and makes the remaining caution precise: tail response timing still needs profiling.

## Previous clean-port development result

Measured with:

- one explicit server warmup request
- local Docker-backed services
- local logged-in seller
- standalone React on Rails Pro Node renderer running on a dedicated port for this pass
- Rails and `bin/shakapacker-dev-server` both restarted with `SHAKAPACKER_DEV_SERVER_PORT=3036` after discovering another repo had reclaimed the default `3035` port
- manual browser verification of both demo routes after the clean-port restart
- matching `Chrome 147` and `ChromeDriver 147`

### Browser metrics

This is the stricter comparison to use from this pass:

- `scripts/perf/compare_dashboard_routes.rb`
- `8` cycles with route order rotated each cycle: `AB`, `BA`, `AB`, `BA`, `AB`, `BA`, `AB`, `BA`
- one explicit warmup request per measured run

| Metric                 |      Inertia demo |         RSC demo |    Delta |
| ---------------------- | ----------------: | ---------------: | -------: |
| Navigation duration    |        `457.16ms` |       `402.29ms` | `-12.0%` |
| Response end           |        `320.70ms` |       `335.96ms` |  `+4.8%` |
| LCP                    |        `501.00ms` |       `421.00ms` | `-16.0%` |
| HTML response transfer | `14,332.38` bytes | `15,265.0` bytes |  `+6.5%` |
| JS request count       |               `6` |              `1` | `-83.3%` |

### Route-scoped server timings

| Metric                           | Inertia demo |   RSC demo |    Delta |
| -------------------------------- | -----------: | ---------: | -------: |
| Controller `action_total`        |   `163.10ms` | `169.74ms` |  `+4.1%` |
| Presenter `compare_props`        |   `144.80ms` | `145.49ms` |  `+0.5%` |
| Presenter `compare_creator_home` |   `134.52ms` | `136.14ms` |  `+1.2%` |
| `sql.active_record`              |    `76.67ms` |  `77.10ms` |  `+0.6%` |
| `render_dispatch`                |    `15.76ms` |  `18.63ms` | `+18.2%` |

### Position sensitivity

The alternating run also captures how much each route changes based on whether it runs first or second in the cycle:

- Inertia when first: navigation `486.62ms`
- Inertia when second: navigation `427.70ms`
- RSC when first: navigation `420.25ms`
- RSC when second: navigation `384.33ms`

That makes two things clearer:

- route order mattered enough to invalidate grouped-batch claims as the headline benchmark method
- the route split is still sensitive to execution order, but the balanced aggregate now leaves only a modest server-side gap in Inertia's favor while keeping a strong user-visible RSC win

### Corrected local setup note

This headline run is stronger than the earlier local headline because it fixed a real environment problem first.

- another local repo had reclaimed port `3035` with a plain-HTTP webpack dev server
- Rails was proxying `https://app.gumroad.dev/packs/...` requests to that wrong process, which broke browser verification
- after adding JS-side `SHAKAPACKER_DEV_SERVER_*` override support, restarting both Rails and the dev server on `3036`, and manually rechecking both pages, the balanced comparison still favored the RSC route on user-visible metrics

### Raw response reduction achieved earlier in the pass

The response-end pass reduced the RSC route from roughly:

- raw response: `36.9KB` -> `15.1KB`
- inline RSC script: `25.4KB` -> `8.9KB`

That means the current user-visible advantage is not coming from a smaller HTML transfer alone.
It also means the current server-side tradeoff is not explained by response size alone, because the HTML transfer is already close while `responseEnd` and `action_total` remain slightly worse under the balanced method.

## Matched-driver repeat

A later `8`-cycle repeat used a matching `Chrome 147` and `ChromeDriver 147` pair and recovered the final comparison JSON from the completed per-run files.

The useful part of that rerun:

- median navigation duration still favored RSC: `544.80ms` vs `396.65ms`
- median `responseEnd` slightly favored RSC: `385.55ms` vs `375.75ms`
- median `LCP` still favored RSC: `568.00ms` vs `426.00ms`

The reason it is not the headline benchmark:

- one RSC run reported a cached `dashboard_rsc_demo_styles.css` duration of about `19.3s` with `0` transfer bytes
- that left `responseEnd` normal but poisoned mean `navigation` and `LCP`
- the dev-asset outlier makes the repeat useful as a diagnostic and discipline check, not as the clean headline result
- it predates the corrected clean-port local rerun above, so it is better treated as an outlier-detection artifact than as the current summary benchmark

## How optimized is the current RSC implementation?

Short answer:

- it is **moderately optimized for a fair comparison**
- it is **not fully optimized for maximum RSC advantage**

What is already optimized:

- comparison surface is reduced to read-heavy creator-home content
- same presenter-backed data shape is used for both routes
- the RSC route was stripped of wrapper-heavy UI components and icon-heavy server output
- empty demo props are omitted
- the dedicated RSC/server bundles are built separately from the main Inertia pack
- CSP and nonce handling are wired correctly for streamed inline payloads

What is not yet heavily leveraged:

- nested async server-component trees
- aggressive Suspense segmentation for meaningful partial streaming
- deeper per-section server data fetching co-located with server components
- deployed renderer tuning and production-grade profiling
- targeted renderer instrumentation inside the React on Rails Pro streaming path

## Are we heavily leveraging RSC?

No, not yet.

This is a **conservative RSC proof-of-value pass**, not a maximal RSC architecture.

Today the implementation mostly proves:

- you can move a read-heavy slice out of a large client-rendered Inertia payload
- you can reduce page-specific client JS materially
- you can win on user-visible metrics on a bounded surface
- you can now inspect route-scoped server work and position sensitivity instead of arguing only from grouped browser batches

It does **not** yet prove the full upside of RSC as an architecture.

## Highest-value next optimization targets

If the next performance review should be high signal, focus here:

1. Keep the review-app, deployed-demo, and live Gumroad PageSpeed URLs visible.
   The July 10 stable media-bearing ShakaPerf run is the current headline evidence; the PR 69 review-app run, stable pre-media run, and Lighthouse URL-pair artifact are historical diagnostics. The lab generates current-host PageSpeed links for review apps plus stable deployed-demo links for `https://gumroad.reactonrails.com`.

2. Deepen React on Rails Pro renderer and streaming-path instrumentation.
   We now have route-scoped Rails timing plus renderer prepare and stream-shell timing, but not a full internal phase breakdown.
   The benchmark harness now also records `/rsc_payload/` resource duration, response start/end, transfer sizes, and resource-level `Server-Timing` when exposed by the browser.
   That does not replace renderer-internal profiling, but it gives evaluators a cleaner artifact for separating document navigation cost from the RSC payload path.

3. Add separately named lab-clean and production-shaped variants so analytics/legacy-script asymmetry is controlled before trying to isolate an “RSC alone” effect.

4. Test whether finer-grained Suspense boundaries improve time-to-first-meaningful HTML without regressing final paint, using a real async workload rather than synthetic delay.

5. Upgrade to React on Rails Pro `17.0.0` final, deploy, and rerun the same two-batch stable protocol before drafting a Gumroad issue.

## Documentation entry points

Start here:

- [current-status.md](./current-status.md)
- [public-product-rsc-demo.md](./public-product-rsc-demo.md)
- [performance-findings.md](./performance-findings.md)
- [rsc-benchmark-plan.md](./rsc-benchmark-plan.md)
- [rsc-comparison-plan.md](./rsc-comparison-plan.md)
- [dashboard-experiment-brief.md](./dashboard-experiment-brief.md)
- [positioning-notes.md](./positioning-notes.md)

## CI validation status

This repo now has a GitHub-hosted demo validation path aimed specifically at the public experiment workflow.

That validation covers:

- the `Rspack`-backed Shakapacker development build
- the standalone `npm run build:rsc-demo` bundle path
- the targeted public product and dashboard demo controller specs
- headless browser smoke specs that visit both public product comparison routes and both dashboard technical proof routes
- the React on Rails Pro Node renderer boot path needed for the RSC route

The heavier internal Gumroad matrix still exists for the original codebase shape, but this public repo now has a reviewable CI path that does not depend on the private `ubicloud` runner pool.

## Key artifacts

- matched comparison JSON: `output/playwright/dashboard-perf/warmed-matched-inertia-vs-rsc-comparison.json`
- Inertia metrics JSON: `output/playwright/dashboard-perf/inertia-demo-control-warm-trimmed-3-dashboard-inertia-demo-metrics.json`
- RSC metrics JSON: `output/playwright/dashboard-perf/rsc-demo-warm-trimmed-3-dashboard-rsc-demo-metrics.json`
- balanced alternating comparison JSON: `output/playwright/dashboard-perf/dashboard-demo-alternating-4-comparison.json`
- corrected clean-port alternating comparison JSON: `output/playwright/dashboard-perf/dashboard-demo-alternating-4-clean-driver-port-3036-matched-driver-comparison.json`
- corrected clean-port `8`-cycle comparison JSON: `output/playwright/dashboard-perf/dashboard-demo-alternating-8-clean-driver-port-3036-matched-driver-comparison.json`
- instrumented Inertia rerun JSON: `output/playwright/dashboard-perf/inertia-demo-server-timing-3-post-rsc-dashboard-inertia-demo-metrics.json`
- instrumented RSC JSON: `output/playwright/dashboard-perf/rsc-demo-server-timing-3-dashboard-rsc-demo-metrics.json`
- clean-driver repeat comparison JSON: `output/playwright/dashboard-perf/dashboard-demo-alternating-8-clean-driver-comparison.json`
- tracked production-like comparison JSON: `docs/performance-artifacts/production-like-alternating-8-reindexed/comparison.json`
- tracked production-like raw metrics directory: `docs/performance-artifacts/production-like-alternating-8-reindexed/runs`

## Public sharing status

The repo, hosted demo, and evaluation docs are public and can be shared with:

- teams evaluating React on Rails for Rails/React architecture
- teams evaluating ShakaCode for performance consulting
- Gumroad maintainers evaluating whether the public product and Discover page case is worth deeper review

The artifact paths listed above are local benchmark outputs, so they are shareable through a repo checkout and branch work, but not through GitHub artifact hosting.
The measurement script also now records browser/version provenance and percentile-style summary stats in those JSON outputs so the performance evaluation is less dependent on ad hoc environment notes.
The alternating comparison JSON now also includes average, median, and `p95` primary-metric deltas plus per-path slowest pack resources, so outliers like the `19.3s` cached CSS load are visible without opening every per-run file.
The earlier 3-run grouped batches are still useful diagnostic artifacts, but the alternating comparison above is the benchmark result that should be circulated because it explicitly balances route order.
