# ShakaPerf A/B testing

The default ShakaPerf suite compares the Legacy/Inertia and Next/RSC product
surfaces at the same current source revision and with the same deterministic
database catalog. The renderer selected by each twin is the experimental
variable; routes, product identities, copy, and seed data are held constant.

## Current seeded-product suite

[`abtests.config.ts`](../abtests.config.ts) points both `controlDir` and
`experimentDir` at the current checkout. Set `SHAKAPERF_CURRENT_DIR` to use a
different checkout, but the single value still applies to both twins. The
dedicated Compose file forces these runtime contracts:

| Side       |   Port | Surface env                        | Creator root                                                                                   |
| ---------- | -----: | ---------------------------------- | ---------------------------------------------------------------------------------------------- |
| Control    | `3100` | `GUMROAD_RENDERING_SURFACE=legacy` | `SHAKAPERF_TWIN_SERVERS=true`, `SHAKAPERF_CREATOR_ROOT_DOMAIN=legacy.gumroad.reactonrails.com` |
| Experiment | `3200` | `GUMROAD_RENDERING_SURFACE=next`   | `SHAKAPERF_TWIN_SERVERS=true`, `SHAKAPERF_CREATOR_ROOT_DOMAIN=next.gumroad.reactonrails.com`   |

The browser maps both wildcard creator-host domains to `127.0.0.1`. Tests use
ShakaPerf's supported absolute `startingPath` and
`experimentPathOverride`, so navigation goes directly to the intended seller
host and port. It does not rely on a root-host redirect, `CUSTOM_DOMAIN`, an
`rsc=1` query parameter, or a hand-written comparison route.

The five default comparisons are derived programmatically from
[`config/development_staging_products.yml`](../config/development_staging_products.yml):

| Catalog category            | Control                                                                             | Experiment                                                                        |
| --------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| demo                        | `http://seller.legacy.gumroad.reactonrails.com:3100/l/demo`                         | `http://seller.next.gumroad.reactonrails.com:3200/l/demo`                         |
| film                        | `http://gumbofilm.legacy.gumroad.reactonrails.com:3100/l/demo_films`                | `http://gumbofilm.next.gumroad.reactonrails.com:3200/l/demo_films`                |
| audio                       | `http://gumboaudio.legacy.gumroad.reactonrails.com:3100/l/demo_audio`               | `http://gumboaudio.next.gumroad.reactonrails.com:3200/l/demo_audio`               |
| design                      | `http://gumbodesign.legacy.gumroad.reactonrails.com:3100/l/demo_design`             | `http://gumbodesign.next.gumroad.reactonrails.com:3200/l/demo_design`             |
| merchandise / fiction-books | `http://gumbomerchandise.legacy.gumroad.reactonrails.com:3100/l/demo_fiction_books` | `http://gumbomerchandise.next.gumroad.reactonrails.com:3200/l/demo_fiction_books` |

The TypeScript catalog reader consumes the YAML names, seller usernames,
surface hosts, and Legacy/Next paths. Do not copy those identities into another
test definition. Each runtime test verifies the
`X-Gumroad-Rendering-Surface` response header through a same-origin browser
`fetch` (so Chromium's wildcard resolver is honored), requires the Legacy
`script[data-page="app"]` marker or Next `#next-rsc-page-root` marker as
appropriate, refuses the opposite marker, and waits for the catalog product
heading and product article.

## Identical isolated databases

Each side has private MySQL, MongoDB, and Redis services. ShakaPerf loads a
fresh schema and runs
[`scripts/seed_development_staging_products.rb`](../scripts/seed_development_staging_products.rb)
inside both Rails containers. That runner uses the normal development/staging
seed files and their YAML catalog, verifies that all 16 canonical permalinks
exist, and skips Elasticsearch work because the product comparison does not
run an Elasticsearch service. The runner and underlying reconciliation are
idempotent.

The twin runner freezes time at `2026-08-12 12:00:00 UTC`; canonical products,
purchases, reviews, sellers, profiles, and offer codes therefore have matching
render-relevant snapshots in independently seeded databases. Taxonomy offer
codes use stable `seed_<permalink>` values, and seller public IDs derive from
catalog emails. BCrypt password hashes retain random salts by design, but
authentication secrets never reach `ProductPresenter`. Opaque IDs derived from
database primary keys are outside the content snapshot; the two clean twins use
the same seed order and Compose cipher keys.

## Local commands

Install the repository dependencies, then run from the repository root:

```shell
npx shaka-perf servers build
npx shaka-perf servers start-containers
npx shaka-perf servers start-servers
```

Keep `start-servers` running and use another terminal:

```shell
npx shaka-perf compare
```

The default `shared.testPathPattern` discovers only
[`ab-tests/seeded-product-surfaces.abtest.ts`](../ab-tests/seeded-product-surfaces.abtest.ts).
To select one product, pass part of its test name, for example:

```shell
npx shaka-perf compare --filter 'Seeded film product'
```

Useful cheap checks that do not build or start the twins are:

```shell
npm run test:shakaperf
npx shaka-perf servers get-config ports.control
npx shaka-perf servers get-config ports.experiment
npx shaka-perf servers get-config controlDir
```

Stop and remove the containers when finished:

```shell
npx shaka-perf servers stop-containers
```

Override ports with `SHAKAPERF_CONTROL_PORT` and
`SHAKAPERF_EXPERIMENT_PORT`; the absolute product URLs and Compose mappings
derive from the same values.

## Historical revision-pinned suite

The August 12, 2026 tests and results remain available as historical evidence,
but their `/public_product/*`, `O365IT`, and `bgfjk` workloads do not prove the
current same-revision/same-catalog goal. Commit `2f00b1ac` removed the custom
public-product routes and the query-selected native RSC implementation from the
current source.

Those definitions now live under [`ab-tests/historical`](../ab-tests/historical)
and use the explicit
[`shakaperf-historical/abtests.config.ts`](../shakaperf-historical/abtests.config.ts).
They are excluded from normal discovery and retain the pinned control checkout
and native fixture seeder used for the recorded artifacts. Run them only from
the exact revisions. Prepare the pinned worktrees first (the script refuses an
existing path at the wrong SHA):

```shell
export SHAKAPERF_CONTROL_DIR="$PWD/.shakaperf-historical-control"
export SHAKAPERF_EXPERIMENT_DIR="$PWD/.shakaperf-historical-experiment"
./twin-servers/prepare-historical-checkouts
git -C "$SHAKAPERF_CONTROL_DIR" rev-parse HEAD
# e720df1b4f13781af1b1b14efd10fe8a31e76641
git -C "$SHAKAPERF_EXPERIMENT_DIR" rev-parse HEAD
# 0c16a6cd36a2e2c89a7090e21c838a013b4d2654
```

The historical config validates both SHAs while loading and fails before a
build or measurement if either directory is missing or incompatible. Keep the
two directory variables exported and pass the archival config explicitly:

```shell
npx shaka-perf servers -c shakaperf-historical/abtests.config.ts build
npx shaka-perf compare -c shakaperf-historical/abtests.config.ts
```

The historical result summary and raw JSON remain in
[`docs/performance-artifacts/native-product-rsc-shakaperf-2026-08-12`](performance-artifacts/native-product-rsc-shakaperf-2026-08-12/README.md).
