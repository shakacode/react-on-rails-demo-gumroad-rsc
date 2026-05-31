# Control Plane deployment

This repo uses `cpflow` for a Heroku Flow style demo deployment:

- review apps for pull requests
- staging deploys from `main`
- manual promotion from staging to production
- nightly cleanup for stale review apps

The app runs these image-backed workloads:

- `rails`: public web workload for the Gumroad RSC comparison routes
- `renderer`: React on Rails Pro Node renderer on cleartext HTTP/2 port `3800`

The demo also provisions app-local MySQL, Mongo, Redis, Memcached, and
Elasticsearch workloads. This is enough to boot the bounded comparison routes
and seed the public demo account, but it is not Gumroad's full production
infrastructure.

Control Plane sets `SESSION_COOKIE_DOMAIN=""` so review and staging apps use
host-only session cookies on their `*.cpln.app` hostnames. Without that
override, Gumroad's staging branch deployment logic pins session cookies to
`.staging.gumroad.com`, which prevents sign-in from persisting on Control Plane
URLs.

## GitHub repository settings

For review apps, GitHub needs one repository secret:

| Secret | Notes |
| --- | --- |
| `CPLN_TOKEN_STAGING` | Control Plane service-account token for `shakacode-open-source-examples-staging`. |

No repository variables are required for the normal review-app path. The
workflow infers the staging org and review-app prefix from
`.controlplane/controlplane.yml`.

For staging deploys from `main`, configure:

| Secret or variable | Value |
| --- | --- |
| `CPLN_TOKEN_STAGING` | Same staging Control Plane token used by review apps. |
| `CPLN_ORG_STAGING` | `shakacode-open-source-examples-staging` |
| `STAGING_APP_NAME` | `react-on-rails-demo-gumroad-rsc-staging` |

For production promotion later, configure a protected GitHub Environment named
`production`:

| Secret or variable | Value |
| --- | --- |
| `CPLN_TOKEN_PRODUCTION` | Environment secret on `production`, not a repository secret. |
| `CPLN_ORG_PRODUCTION` | Environment variable on `production`: `shakacode-open-source-examples-production` |
| `PRODUCTION_APP_NAME` | Environment variable on `production`: `react-on-rails-demo-gumroad-rsc-production` |

Protect the `production` environment with required reviewers and prevent
self-review.

## Control Plane runtime secrets

The app secret dictionary must provide:

- `SECRET_KEY_BASE`
- `DEVISE_SECRET_KEY`
- `STRONGBOX_GENERAL`
- `STRONGBOX_GENERAL_PASSWORD`
- `RENDERER_PASSWORD`
- `REACT_ON_RAILS_PRO_LICENSE`

For review apps, `cpflow` uses the shared review-app prefix when resolving
`{{APP_SECRETS}}`. That means every PR app named
`react-on-rails-demo-gumroad-rsc-review-pr-<PR number>` reads from:

```text
react-on-rails-demo-gumroad-rsc-review-pr-secrets
```

If the release runner fails with `couldn't find key DEVISE_SECRET_KEY`, the
review secret exists but has not been populated with the app keys above.

Generate values with:

```sh
openssl rand -hex 64 # SECRET_KEY_BASE
openssl rand -hex 64 # DEVISE_SECRET_KEY
openssl rand -hex 32 # RENDERER_PASSWORD
openssl genrsa 2048 # STRONGBOX_GENERAL; STRONGBOX_GENERAL_PASSWORD can be blank for an unencrypted key.
```

The MySQL and Mongo templates create separate app-scoped dictionaries:

- `<app-name>-mysql`
- `<app-name>-mongo`

Replace their placeholder passwords in Control Plane before using the app for
serious review or staging testing.

The Mongo workload must keep the official Docker entrypoint. Pass Mongo flags
through `args` only; setting `command: mongod` bypasses entrypoint
initialization, leaves the root-user secret unused, and binds Mongo to localhost
inside the container instead of the GVC network.

## Bootstrap

Bootstrap persistent staging once before relying on merge-to-main deploys:

```sh
cpflow setup-app -a react-on-rails-demo-gumroad-rsc-staging --org shakacode-open-source-examples-staging --skip-post-creation-hook
```

Use `--skip-post-creation-hook` for first bootstrap because no app image exists
yet. Database preparation runs from `.controlplane/release_script.sh` after the
Docker image is built.

For a public demo account, set this GVC env var before deploying:

```text
ALLOW_DEMO_SEED=true
```

The seeded account is:

```text
seller@gumroad.com / password
```

## Review app smoke test

After `CPLN_TOKEN_STAGING` is configured, create or update a review app by
commenting on a PR:

```text
+review-app-deploy
```

The review app name follows:

```text
react-on-rails-demo-gumroad-rsc-review-pr-<PR number>
```

Smoke these paths after the workflow comments with the review URL:

```sh
curl -L -s -o /dev/null -w '%{http_code}\n' <review-url>/
curl -L -s -o /dev/null -w '%{http_code}\n' <review-url>/dashboard/inertia_demo
curl -L -s -o /dev/null -w '%{http_code}\n' <review-url>/dashboard/rsc_demo
```

The dashboard routes require a signed-in seller in a browser for full visual QA.
Use `seller@gumroad.com / password` when `ALLOW_DEMO_SEED=true`.

## Validation

Run:

```sh
bin/test-cpflow-github-flow
docker build -f .controlplane/Dockerfile -t gumroad-rsc-cpflow-smoke .
```

The wrappers currently point at:

```yaml
uses: shakacode/control-plane-flow/.github/workflows/<workflow>.yml@v5.0.4
```

To update only the pinned reusable-workflow ref:

```sh
bin/pin-cpflow-github-ref v5.0.4
```

If the renderer workload is changed, confirm it still exposes port `3800` as
`http2`; React on Rails Pro's Node renderer speaks cleartext HTTP/2.
