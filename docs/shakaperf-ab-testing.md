# ShakaPerf A/B testing

This integration uses the globally installed `shaka-perf` CLI and its actual
`abTest` API. It is separate from the historical Ruby/Selenium benchmark
artifacts elsewhere in this repository; those older numbers were not produced
by ShakaPerf.

## Page pairs

The architecture comparison is
[`ab-tests/public-product-rsc.abtest.ts`](../ab-tests/public-product-rsc.abtest.ts).
It compares the two existing implementations directly:

| Side       | Host URL                                            | Implementation          |
| ---------- | --------------------------------------------------- | ----------------------- |
| Control    | `http://localhost:3100/public_product/inertia_demo` | Inertia                 |
| Experiment | `http://localhost:3200/public_product/rsc_demo`     | React Server Components |

In the test definition, `startingPath` selects the Inertia route for control
and `experimentPathOverride` selects the RSC route for experiment. The test
waits for the shared `.dd-product-hero` surface and its heading to render,
captures that surface for visual regression, checks accessibility, and runs
ten simultaneous mobile Lighthouse measurements per side.

The database-backed branch comparison is
[`ab-tests/native-product-page.abtest.ts`](../ab-tests/native-product-page.abtest.ts).
It loads the same native Gumroad product route on both twins:

| Side       | Host URL                                                                     | Data source                                             |
| ---------- | ---------------------------------------------------------------------------- | ------------------------------------------------------- |
| Control    | `http://localhost:3100/l/O365IT?layout=discover&recommended_by=search`       | Isolated control database                               |
| Experiment | `http://localhost:3200/l/O365IT?layout=discover&recommended_by=search&rsc=1` | Isolated experiment database, native React on Rails RSC |

Before either server starts, ShakaPerf runs
[`scripts/seed_native_product_page.rb`](../scripts/seed_native_product_page.rb)
inside each container. The idempotent seed creates two creators, five products,
259 synthetic purchases and reviews, and local deterministic cover and
description images. The additional media-heavy fixture is tested by
[`ab-tests/residential-product-page.abtest.ts`](../ab-tests/residential-product-page.abtest.ts):

| Side       | Host URL                                                                    | Implementation                         |
| ---------- | --------------------------------------------------------------------------- | -------------------------------------- |
| Control    | `http://localhost:3100/l/bgfjk?layout=discover&recommended_by=search`       | Pinned Inertia product page            |
| Experiment | `http://localhost:3200/l/bgfjk?layout=discover&recommended_by=search&rsc=1` | Native React on Rails RSC product page |

It includes five product previews, English and Spanish options, and the live
listing's displayed rating distribution. Both tests exercise Gumroad's genuine
`Products/Discover/Show` components rather than the presenter-backed RSC demo.

For the August 12, 2026 comparison, the control checkout is pinned to
`e720df1b4f13781af1b1b14efd10fe8a31e76641`, immediately before the native RSC
page implementation, while the experiment includes the native RSC commits
through `0c16a6cd`. The `rsc=1` query parameter is intentionally present only on
the experiment URLs; it selects the streamed RSC response while preserving the
same product, layout, and recommendation context.

## Ports

The host ports are fixed in [`abtests.config.ts`](../abtests.config.ts):

- control: `3100`
- experiment: `3200`

Each Rails server listens on port `3000` inside its own Docker container. The
ShakaPerf Compose configuration maps the two internal `3000` ports to the host
ports above. Each side also gets a private, unexposed MySQL 8.0.32 database, so
control and experiment cannot affect one another. Nothing in this integration
binds host port `3000`.

## Why the response says `shakaperf`

The twin-server Docker image sets `BRANCH=shakaperf` and `REVISION=shakaperf`
as local runtime labels. Those values identify the disposable benchmark image;
they are not the Git revisions being compared and, by themselves, do not prove
which benchmark runner was used. The reproducible identities are the pinned
control commit above, the experiment commit, the two test definitions, and the
generated CLI report. Historical July 2026 tables were produced by
`scripts/perf/compare_dashboard_routes.rb` with Ruby/Selenium even though the UI
called them “ShakaPerf.” The August native-product run uses the actual globally
installed `shaka-perf@0.2.4` CLI.

## Run it

From the repository root:

```shell
shaka-perf servers build
shaka-perf servers start-containers
shaka-perf servers start-servers
```

Keep `start-servers` running, then use another terminal:

```shell
shaka-perf compare --filter ab-tests/public-product-rsc.abtest.ts
shaka-perf compare --filter ab-tests/native-product-page.abtest.ts
shaka-perf compare --filter ab-tests/residential-product-page.abtest.ts
```

The generated full report is `compare-results/full-report.html`; the compact,
shareable report is `compare-results/self-contained-performance-report.html`.

## August 12, 2026 result

The recorded two-product run used:

```shell
shaka-perf compare --filter 'Microsoft 365 product,Residential Design product' --full-report-zip
```

It completed all five stages and generated the reports, then exited `1` with
`FAILED: 2 perf regressions`. RSC improved FCP, LCP, CLS, Lighthouse score, and
request count on both products, but regressed TTFB and transferred bytes on both
and TBT on Microsoft. The committed [result summary and raw JSON](performance-artifacts/native-product-rsc-shakaperf-2026-08-12/README.md)
contain the exact estimator values and p-values. This is evidence of specific
RSC wins and costs, not proof of unconditional superiority.

Stop and remove the twin containers when finished:

```shell
shaka-perf servers stop-containers
```

To inspect the pages manually while the servers are running, open the URLs in
the tables above. To verify the resolved port mapping without starting
anything:

```shell
shaka-perf servers get-config ports.control
shaka-perf servers get-config ports.experiment
```
