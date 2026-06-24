# RSC Performance Evaluation

## What this is

This repo contains two production-shaped public buyer-page comparisons:

- product `Inertia` control route: `/public_product/inertia_demo`
- product React Server Components via React on Rails Pro route: `/public_product/rsc_demo`
- Discover `Inertia` control route: `/public_product/discover_inertia_demo`
- Discover React Server Components via React on Rails Pro route: `/public_product/discover_rsc_demo`

These are the value-proof surfaces because they are logged out, SEO-sensitive, conversion-sensitive, mobile-heavy, and visible without a demo account.

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

The production-shaped public buyer-page result is **now directionally favorable on the hosted app**, but it is not yet the final Gumroad adoption proof.

What is already true:

- product and Discover pages now have matched Inertia and React Server Components via React on Rails Pro routes
- both route pairs use the same synthetic production-shaped fixture data, host, route-scoped CSS, and measurement harness
- the fixtures were shaped from public Gumroad `Discover/Index` and `Products/Discover/Show` page structure without committing copied creator content
- the sanitized shape sampling notes are documented in [docs/public-page-fixture-sampling.md](public-page-fixture-sampling.md)
- all public comparison routes are logged out, so the comparison can be evaluated without a demo account
- these public buyer pages are the correct surfaces for SEO, conversion-sensitive loading, client JavaScript cost, and mobile buyer performance
- the first hosted headless-Chrome A/B run shows large median navigation wins and a 7-to-1 reduction in JS requests on both public route pairs

What still needs proof:

- mobile ShakaPerf/Lighthouse-style A/B reports for both product and Discover pairs showing meaningful `LCP`, `TBT`, `INP`, navigation, payload, route JavaScript, and mobile-score wins
- production-grade renderer and streaming-path profiling for the public routes
- that the measured mobile public-route win is large enough to justify React Server Components via React on Rails Pro complexity for Gumroad

## Latest Hosted Public Buyer-Page Result

Captured on `2026-06-23 HST` / `2026-06-24 UTC` against `https://gumroad.reactonrails.com` with local headless Chrome `149`, `8` alternating cycles, `2` server warmup requests per measured run, `--public`, and `--require-driver-match`.

| Surface | Median nav duration | Median LCP start | JS requests | Serialized Inertia payload |
| --- | ---: | ---: | ---: | ---: |
| Product detail | `811.50ms` -> `272.25ms` (`-66.5%`) | `368.00ms` -> `304.00ms` (`-17.4%`) | `7` -> `1` (`-85.7%`) | `12,183 B` -> none |
| Discover marketplace | `796.95ms` -> `283.75ms` (`-64.4%`) | `360.00ms` -> `322.00ms` (`-10.6%`) | `7` -> `1` (`-85.7%`) | `24,960 B` -> none |

Supporting details are in [public-buyer-page-performance-results.md](./public-buyer-page-performance-results.md) and [performance-artifacts/hosted-public-buyer-pages-2026-06-24/summary.json](./performance-artifacts/hosted-public-buyer-pages-2026-06-24/summary.json).

Interpretation:

- the public-page RSC path is now worth continuing because the deployed browser-navigation win is large
- the strongest win is reduced client work: one route-scoped RSC pack instead of seven JS requests plus an Inertia `data-page` payload
- RSC increases HTML transfer because it streams rendered content in the document
- Discover has a small median `responseEnd` regression, so renderer/streaming instrumentation is still required
- this is a hosted headless desktop run, not yet a mobile-throttled Lighthouse result

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
- the new production-shaped product and Discover routes have supplied a deployed headless-browser benchmark, but not yet mobile-throttled benchmark evidence

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

1. Repeat the comparison against the deployed review/staging app once the Control Plane environment is stable.
   The production-like local rerun is complete and is now the strongest local evidence; the next question is whether the RSC advantage holds with deployed network, container, and renderer behavior.

2. Instrument the React on Rails Pro renderer and streaming path.
   We now have route-scoped Rails timing, but not renderer-internal timing.
   The benchmark harness now also records `/rsc_payload/` resource duration, response start/end, transfer sizes, and resource-level `Server-Timing` when exposed by the browser.
   That does not replace renderer-internal profiling, but it gives evaluators a cleaner artifact for separating document navigation cost from the RSC payload path.

3. Test whether finer-grained Suspense boundaries improve time-to-first-meaningful HTML without regressing final paint.

4. Move more section-level composition into server components instead of one relatively coarse route-level tree.

5. Measure Node renderer overhead separately from React render time and Rails template/render overhead.

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
