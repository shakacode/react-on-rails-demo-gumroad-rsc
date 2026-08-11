# ShakaPerf A/B testing

This integration uses the globally installed `shaka-perf` CLI and its actual
`abTest` API. It is separate from the historical Ruby/Selenium benchmark
artifacts elsewhere in this repository; those older numbers were not produced
by ShakaPerf.

## Page pair

The single test is
[`ab-tests/public-product-rsc.abtest.ts`](../ab-tests/public-product-rsc.abtest.ts).
It compares the two existing implementations directly:

| Side | Host URL | Implementation |
| --- | --- | --- |
| Control | `http://localhost:3100/public_product/inertia_demo` | Inertia |
| Experiment | `http://localhost:3200/public_product/rsc_demo` | React Server Components |

In the test definition, `startingPath` selects the Inertia route for control
and `experimentPathOverride` selects the RSC route for experiment. The test
waits for the shared `.dd-product-hero` surface and its heading to render,
captures that surface for visual regression, checks accessibility, and runs
seven alternating mobile Lighthouse measurements per side.

Both images intentionally build the same checkout because this is a route-level
A/B test. `SHAKAPERF_CONTROL_DIR` and `SHAKAPERF_EXPERIMENT_DIR` can point at
separate checkouts when a branch-level comparison is needed.

## Ports

The host ports are fixed in [`abtests.config.ts`](../abtests.config.ts):

- control: `3100`
- experiment: `3200`

Each Rails server listens on port `3000` inside its own Docker container. The
bundled ShakaPerf Compose configuration maps the two internal `3000` ports to
the host ports above. Nothing in this integration binds host port `3000`.

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
```

The generated report is `compare-results/report.html`. Stop and remove the
twin containers when finished:

```shell
shaka-perf servers stop-containers
```

To inspect the pages manually while the servers are running, open the two URLs
in the table above. To verify the resolved port mapping without starting
anything:

```shell
shaka-perf servers get-config ports.control
shaka-perf servers get-config ports.experiment
```
