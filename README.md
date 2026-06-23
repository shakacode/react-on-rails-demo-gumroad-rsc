<p align="center">
  <picture>
    <source srcset="https://public-files.gumroad.com/logo/gumroad-dark.svg" media="(prefers-color-scheme: dark)">
    <source srcset="https://public-files.gumroad.com/logo/gumroad.svg" media="(prefers-color-scheme: light)">
    <img src="https://public-files.gumroad.com/logo/gumroad.svg" width="714" alt="Gumroad logo">
  </picture>
</p>

<p align="center">
  <strong>Sell your stuff. See what sticks.</strong>
</p>

<p align="center">
  <a href="https://gumroad.com">Gumroad</a> is an e-commerce platform that enables creators to sell products directly to consumers. This repository contains the source code for the Gumroad web application.
</p>

> [!IMPORTANT]
> This is not Gumroad's canonical repository. It is a public ShakaCode demo derived from [`antiwork/gumroad`](https://github.com/antiwork/gumroad) to answer one practical performance question:
>
> Can React Server Components delivered through `react_on_rails` and React on Rails Pro make Gumroad's public, buyer-facing pages meaningfully faster than the current `Inertia` implementation, especially on mobile?

## React on Rails Pro Consumer-Page Performance Experiment

This repository tracks [antiwork/gumroad](https://github.com/antiwork/gumroad) and is being used by ShakaCode as a focused public demo comparing a current Inertia-style public product page against a React Server Components candidate implemented with `react_on_rails`, React on Rails Pro, and React 19.

The priority is consumer-facing performance: public product pages, mobile buyers, SEO, first meaningful content, conversion, and route-level JavaScript cost. Dashboard pages are useful technical proof that the stack works, but they are not the value proof.

### Start here

- Hosted homepage with an explicit experiment callout: <https://gumroad.reactonrails.com>
- Live A/B performance lab: <https://gumroad.reactonrails.com/rsc-demo>
- Before, matched Inertia route: <https://gumroad.reactonrails.com/public_product/inertia_demo>
- After, React Server Components via React on Rails Pro route: <https://gumroad.reactonrails.com/public_product/rsc_demo>
- React on Rails docs: <https://reactonrails.com/>
- React on Rails source: <https://github.com/shakacode/react_on_rails>
- ShakaCode: <https://www.shakacode.com/>
- Book a ShakaCode consultation: <https://meetings.hubspot.com/justingordon/30-minute-consultation>
- Performance evaluation notes: [docs/performance-evaluation.md](docs/performance-evaluation.md)
- Public product demo details: [docs/public-product-rsc-demo.md](docs/public-product-rsc-demo.md)
- Current findings and benchmark artifacts: [docs/performance-findings.md](docs/performance-findings.md)
- Benchmark and positioning issue: [React on Rails issue #3144](https://github.com/shakacode/react_on_rails/issues/3144)

### Who this demo is for

- Teams evaluating `react_on_rails`: inspect how React Server Components can run inside a real Rails app without turning the whole product page into a client-only island.
- Teams evaluating ShakaCode: use the demo, benchmark method, and tradeoff notes to judge how we approach Rails plus React performance work.
- Gumroad maintainers: focus on whether the public product page case is compelling enough to justify trying these technologies in Gumroad itself.

### Public evaluation bar

The demo only matters if it proves a meaningful buyer-page advantage.

- The public product page is the primary surface because it is logged out, SEO-sensitive, conversion-sensitive, and mobile-heavy.
- The first supported claim is payload reduction: less route JavaScript and no serialized Inertia `data-page` payload on the RSC route.
- The next required claim is mobile performance: ShakaPerf/Lighthouse-style A/B reports must show a meaningful improvement in metrics such as `LCP`, `TBT`, `INP`, and mobile score.
- If the mobile public-page report is not favorable enough to justify extra architecture complexity, treat this as an integration demo rather than a Gumroad adoption recommendation.

### React Server Components via React on Rails, not Rspack, is the performance premise

Do not read this demo as "Rspack makes Gumroad pages faster."
That is not the claim.

- `Rspack` is supporting build infrastructure and a developer-experience improvement.
- `Shakapacker` is the Rails/Webpack-or-Rspack integration layer that lets the app move modern React assets through Rails cleanly.
- React Server Components delivered through `react_on_rails` and React on Rails Pro are the runtime architecture being tested for public buyer-page performance.

If the consumer-facing page wins, it should be because React Server Components through React on Rails reduce client JavaScript, serialized payload, hydration work, or mobile render cost enough to matter.
If the consumer-facing page does not win, faster bundling does not save the adoption case.

### Current public buyer-page evidence

Latest hosted lab sample from <https://gumroad.reactonrails.com/rsc-demo>:

| Public product route metric |                     Before: Inertia | After: React Server Components via React on Rails Pro | Result                                                                |
| --------------------------- | ----------------------------------: | ----------------------------------------------------: | --------------------------------------------------------------------- |
| Readable route JavaScript   |                          `880.8 KB` |                                            `340.4 KB` | about `61%` less route JS                                             |
| Serialized page payload     |                  `6.4 KB data-page` |                                                  none | RSC removes the route-level Inertia payload                           |
| Login required              |                                  no |                                                    no | both routes are buyer-visible without auth                            |
| Product content             | metadata plus serialized page props |                      streamed in initial RSC document | RSC makes the server-rendered buyer content explicit before hydration |

This is a strong reason to keep testing, but it is not the final upstream claim.
The final claim needs a ShakaPerf/Lighthouse-style A/B report focused on mobile buyer-page metrics.

### Live demo surface

Open the hosted public demo first:

- `https://gumroad.reactonrails.com`
- `https://gumroad.reactonrails.com/rsc-demo`
- `https://gumroad.reactonrails.com/public_product/inertia_demo`
- `https://gumroad.reactonrails.com/public_product/rsc_demo`

The hosted homepage is intentionally modified so Rails teams, ShakaCode prospects, and Gumroad maintainers immediately see how to run the comparison and why the public product route matters. The lab is logged out and runs a same-origin browser race against the matched public product routes. It makes the streaming, route-script, and serialized-payload differences visible immediately, then links to each implementation route for manual inspection.

Local equivalents:

- `https://gumroad.dev/rsc-demo`
- `https://gumroad.dev/public_product/performance_demo`
- `https://gumroad.dev/public_product/inertia_demo`
- `https://gumroad.dev/public_product/rsc_demo`

Both product routes render the seeded public `demo` product and link back to the current Gumroad product page at `https://gumroad.dev/l/demo`.

### What this repo currently proves

- The public product comparison route pair is logged out and focused on buyer-facing page behavior, not seller admin UX.
- The live lab makes route script bytes and serialized payload differences visible immediately.
- The demo assets are route-scoped, so ordinary Inertia pages do not pay for the experiment's extra JS or CSS.
- GitHub-hosted demo validation includes browser smoke coverage for the public comparison routes.
- Route-scoped `Server-Timing` and an alternating comparison runner are available for disciplined A/B benchmarks.

### Evidence still needed before a Gumroad adoption proposal

- Run and publish a mobile ShakaPerf/Lighthouse-style A/B report for `/public_product/inertia_demo` vs `/public_product/rsc_demo`.
- Use that report to decide whether the performance win is large enough to justify React Server Components via React on Rails Pro complexity.
- Profile renderer and streaming overhead if `responseEnd`, `TBT`, or tail latency weakens the RSC case.
- Keep dashboard routes out of the headline story except as technical integration evidence.

### Dashboard technical proof

The repo also exposes two dashboard comparison routes that use the same reduced seller-data surface. These are technical proofs for RSC integration and measurement, not the main SEO or conversion proof:

- `https://gumroad.dev/dashboard/inertia_demo`
- `https://gumroad.dev/dashboard/rsc_demo`

Latest production-like alternating local result on the reduced dashboard surface:

- Inertia median navigation duration: `775.40ms`
- RSC median navigation duration: `607.15ms`
- Inertia median `LCP`: `794.00ms`
- RSC median `LCP`: `634.00ms`
- Inertia median `responseEnd`: `644.80ms`
- RSC median `responseEnd`: `588.80ms`
- Inertia median `action_total`: `346.87ms`
- RSC median `action_total`: `339.20ms`

This pass built `RAILS_ENV=production NODE_ENV=production` Shakapacker/Rspack assets, built the standalone RSC demo bundles, ran Rails without the Shakapacker dev server, and used a dedicated React on Rails Pro Node renderer with matching `Chrome 147` and `ChromeDriver 147`.
It rotates route order by cycle instead of relying on separate batches.
The main caution is that `p95 responseEnd` still favored Inertia by `5.2%`, and the current RSC route does not expose a separate browser `/rsc_payload/` resource, so those payload resource fields are empty for this implementation.

Dashboard screenshots are kept as proof that the stack works against signed-in Gumroad data:

| Inertia dashboard technical proof             | React Server Components via React on Rails Pro dashboard proof |
| --------------------------------------------- | -------------------------------------------------------------- |
| ![Inertia demo](docs/images/inertia-demo.png) | ![RSC demo](docs/images/rsc-demo.png)                          |

### Optional seller login for technical proof routes

The headline public demo does not require a login. Use these credentials only when verifying the older signed-in dashboard technical proof or other seller-only Gumroad flows.

Local verification:

- email: `seller@gumroad.com`
- password: `password`
- two-factor code: `000000`

Hosted demo verification:

- email: `seller+admin@gumroad.com`
- password: `password`
- two-factor code, when prompted: `000000`

### How to reproduce the comparison locally

1. Start local services: `LOCAL_DETACHED=true make local`
2. Prepare the database: `bin/rails db:prepare`
3. Start the app runtime in separate terminals:
   `bundle exec rails s -b 0.0.0.0 -p 3000`
   `npm run setup && ./bin/shakapacker-dev-server`
   `node client/node-renderer.cjs`
   The Node renderer uses the local `devPassword` fallback only in `development` and `test`; set `RENDERER_PASSWORD` for production-like or hosted runs.
   If port `3035` is already occupied by another local repo, start both Rails and the dev server with the same override, for example:
   `SHAKAPACKER_DEV_SERVER_PORT=3036 bundle exec rails s -b 0.0.0.0 -p 3000`
   `SHAKAPACKER_DEV_SERVER_PORT=3036 npm run setup && ./bin/shakapacker-dev-server`
4. Open the performance lab first:
   `/rsc-demo`
   The lab auto-loads both matched public routes, shows first streamed bytes, complete response timing, HTML response
   size, route script bytes, and the serialized Inertia payload size.
5. Open the two demo routes and compare:
   `/public_product/inertia_demo`
   `/public_product/rsc_demo`
   The dashboard technical proof routes remain available, but they are not the SEO/conversion proof:
   `/dashboard/inertia_demo`
   `/dashboard/rsc_demo`
6. For the stricter benchmark method, run:
   `ruby scripts/perf/compare_dashboard_routes.rb --public --base-url https://gumroad.dev --measure-base-url https://gumroad.dev --path /public_product/inertia_demo --path /public_product/rsc_demo --label public-product-demo-alternating-4 --cycles 4 --server-warmup-requests 1 --require-driver-match`
   Use `/dashboard/inertia_demo` and `/dashboard/rsc_demo` with a dashboard-specific label only when benchmarking the technical proof.
   For the longer headline-style local repeat, use the same command with `--cycles 8`.

For the production-like local pass, first build compiled assets and initialize local Elasticsearch:
`RENDERER_PASSWORD=benchmarkRendererPassword RAILS_ENV=production NODE_ENV=production bin/shakapacker`
`RENDERER_PASSWORD=benchmarkRendererPassword RAILS_ENV=production NODE_ENV=production npm run build:rsc-demo`
`RENDERER_PASSWORD=benchmarkRendererPassword DISABLE_SPRING=1 OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES bin/rails runner 'DevTools.delete_all_indices_and_reindex_all'`
Then run Rails without `bin/shakapacker-dev-server`, start `RENDERER_PASSWORD=benchmarkRendererPassword RENDERER_PORT=3800 RENDERER_WORKERS_COUNT=2 RENDERER_LOG_LEVEL=warn node client/node-renderer.cjs`, and run the same comparison command with `--cycles 8`.

If a long comparison run is interrupted after it writes per-run JSON files, rerun the same command with `--reuse-existing` to emit the final comparison summary without discarding completed samples.

If you want the measured benchmark artifacts instead of a visual spot check, start with [docs/performance-findings.md](docs/performance-findings.md).

### Public evaluation docs

- [docs/public-product-rsc-demo.md](docs/public-product-rsc-demo.md)
- [docs/performance-findings.md](docs/performance-findings.md)
- [docs/performance-evaluation.md](docs/performance-evaluation.md)
- [docs/rsc-comparison-plan.md](docs/rsc-comparison-plan.md)
- [docs/control-plane-deployment.md](docs/control-plane-deployment.md)
- [docs/youtube-demo-script.md](docs/youtube-demo-script.md)

See [docs/rsc-comparison-plan.md](docs/rsc-comparison-plan.md) for the working plan, scope, and success criteria.
See [docs/current-status.md](docs/current-status.md) for engineering status details and remaining measurement work.

## See also

See also the [React on Rails Starter TanStack](https://github.com/shakacode/react-on-rails-starter-tanstack): the 2026 starter we ship, built on the same React on Rails Pro stack this demo benchmarks against Inertia.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Running Locally](#running-locally)
- [Development](#development)
  - [Logging in](#logging-in)
  - [Resetting Elasticsearch indices](#resetting-elasticsearch-indices)
  - [Push Notifications](#push-notifications)
  - [Common Development Tasks](#common-development-tasks)
  - [Linting](#linting)

## Getting Started

### Prerequisites

> 💡 If you're on Windows, follow our [Windows setup guide](docs/development/windows.md) instead.

Before you begin, ensure you have the following installed:

#### Ruby

- https://www.ruby-lang.org/en/documentation/installation/
- Install the version listed in [the .ruby-version file](./.ruby-version)

#### Node.js

- https://nodejs.org/en/download
- Install the version listed in [the .node-version file](./.node-version)

#### Docker

We use Docker to setup the services for development environment.

- For MacOS: Download the Docker app from the [Docker website](https://www.docker.com/products/docker-desktop)
- For Linux:

```bash
sudo wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker $(whoami)
```

#### MySQL & Percona Toolkit

Install a local version of MySQL 8.0.x to match the version running in production.

The local version of MySQL is a dependency of the Ruby `mysql2` gem. You do not need to start an instance of the MySQL service locally. The app will connect to a MySQL instance running in the Docker container.

- For MacOS:

```bash
brew install mysql@8.0 percona-toolkit
brew link --force mysql@8.0

# to use Homebrew's `openssl`:
brew install openssl
bundle config --global build.mysql2 --with-opt-dir="$(brew --prefix openssl)"

# ensure MySQL is not running as a service
brew services stop mysql@8.0
```

- For Linux:
  - MySQL:
    - https://dev.mysql.com/doc/refman/8.0/en/linux-installation.html
    - `apt install libmysqlclient-dev`
  - Percona Toolkit: https://www.percona.com/doc/percona-toolkit/LATEST/installation.html

#### Image Processing Libraries

##### ImageMagick

We use `imagemagick` for preview editing.

- For MacOS: `brew install imagemagick`
- For Linux: `sudo apt-get install imagemagick`

##### libvips

For newer image formats we use `libvips` for image processing with ActiveStorage.

- For MacOS: `brew install libvips`
- For Linux: `sudo apt-get install libvips-dev`

#### FFmpeg

We use `ffprobe` that comes with `FFmpeg` package to fetch metadata from video files.

- For MacOS: `brew install ffmpeg`
- For Linux: `sudo apt-get install ffmpeg`

#### PDFtk

We use [pdftk](https://www.pdflabs.com/tools/pdftk-server/) to stamp PDF files with the Gumroad logo and the buyers' emails.

- For MacOS: Download from [here](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg)
  - **Note:** pdftk may be blocked by Apple's firewall. If this happens, go to Settings > Privacy & Security and click "Open Anyways" to allow the installation.
- For Linux: `sudo apt-get install pdftk`

#### wkhtmltopdf

While generating invoices, to convert HTML to PDF, PDFKit expects [wkhtmltopdf](https://wkhtmltopdf.org/) to be installed on your system. [Download](https://wkhtmltopdf.org/downloads.html) and install the version 0.12.6 for your platform.

- **Note** similar to pdftk, this may also be blocked by Apple's firewall on MacOS. Follow a similar process as above.

### Installation

#### Bundler and gems

We use Bundler to install Ruby gems.

```shell
gem install bundler
```

Install gems:

```shell
bundle install
```

Also make sure to install `dotenv` as it is required for some console commands:

```shell
gem install dotenv
```

#### npm and Node.js dependencies

Make sure the correct version of `npm` is enabled:

```shell
corepack enable
```

Install dependencies:

```shell
npm install
```

### Configuration

#### Set up Custom credentials

App can be booted without any custom credentials. But if you would like to use services that require custom credentials (e.g. S3, Stripe, Resend, etc.), you can copy the `.env.example` file to `.env` and fill in the values.

### Running Locally

#### Start Docker services

If you installed Docker Desktop (on a Mac or Windows machine), you can run the following command to start the Docker services:

```shell
make local
```

If you are on Linux, or installed Docker via a package manager on a mac, you may have to manually give docker superuser access to open ports 80 and 443. To do that, use `sudo make local` instead.

This command will not terminate. You run this in one tab and start the application in another tab.
If you want to run Docker services in the background, use `LOCAL_DETACHED=true make local` instead.

#### Set up the database

```shell
bin/rails db:prepare
```

For Linux (Debian / Ubuntu) you might need the following:

- `apt install libxslt-dev libxml2-dev`

#### Start the application

```shell
bin/dev
```

This starts the Rails server, the JavaScript build system, and a Sidekiq worker.

You can now access the application at `https://gumroad.dev`.

## Development

### Logging in

You can log in with the username `seller@gumroad.com` and the password `password`. The two-factor authentication code is `000000`.

Read more about logging in as a user with a different team role at [Users & authentication](docs/users.md).

### Resetting Elasticsearch indices

You will need to explicitly reindex Elasticsearch to populate the indices after setup, otherwise you will see `index_not_found_exception` errors when you visit the dev application. You can reset them using:

```ruby
# Run this in a rails console:
DevTools.delete_all_indices_and_reindex_all
```

### Push Notifications

To send push notifications:

```shell
INITIALIZE_RPUSH_APPS=true bundle exec rpush start -e development -f
```

### Common Development Tasks

#### Rails console:

```shell
bin/rails c
```

#### Rake tasks:

```shell
bin/rake task_name
```

### Linting

We use ESLint for JS, and Rubocop for Ruby. Your editor should support displaying and fixing issues reported by these inline, and CI will automatically check and fix (if possible) these.

If you'd like, you can run `git config --local core.hooksPath .githooks` to check for these locally when committing.

## Common Issues

### macOS Error When Running Tests (Related to `fork()`)

```
objc[11912]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[11912]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

This issue occurs on macOS due to how the `fork()` system call interacts with multithreaded Objective-C applications—commonly triggered when Spring is enabled during testing.

#### How to Fix:

Temporarily disable Spring before running your tests to avoid this error.

```bash
export DISABLE_SPRING=1
bin/rspec spec/requests/balance_pages_spec.rb
```

This will disable Spring for the current session, allowing the tests to run without triggering the `fork()`-related crash.
