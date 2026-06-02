# Control Plane deployment plan

This repository now has a Control Plane deployment scaffold for the public
Gumroad RSC comparison demo. It intentionally targets the bounded
`/dashboard/inertia_demo` versus `/dashboard/rsc_demo` experiment, not a full
Gumroad production clone.

## What deploys

- `rails`: the public Rails web workload.
- `renderer`: the React on Rails Pro Node renderer on HTTP/2 port `3800`.
- `mysql`, `mongo`, `redis`, `memcached`, and `elasticsearch`: app-local
  backing services needed for the demo app to boot and seed data.

The Rails app runs with compiled `staging` assets and `NODE_ENV=production`.
Control Plane sets `ASSET_HOST=""` and `RAILS_SERVE_STATIC_FILES=true` so the
deployed app serves the built packs from the image instead of using Gumroad's
production or staging asset hosts.

It also sets `SESSION_COOKIE_DOMAIN=""` so Rails emits host-only session
cookies for the Control Plane hostname. That matters because Gumroad's normal
staging branch deployment path pins cookies to `.staging.gumroad.com`, which is
wrong for review/staging apps served from `*.cpln.app`.

## Review app workflow

Comment this on a PR:

```text
+review-app-deploy
```

The workflow only deploys review apps for same-repository PRs. Fork PRs are
skipped because review-app deployment passes repository deployment secrets to
the reusable Control Plane workflow.

The workflow creates:

```text
react-on-rails-demo-gumroad-rsc-review-pr-<PR number>
```

Review apps share one prefix-level secret dictionary because
`.controlplane/controlplane.yml` uses `match_if_app_name_starts_with` for PR
apps:

```text
react-on-rails-demo-gumroad-rsc-review-pr-secrets
```

Populate that dictionary before expecting release jobs to boot. The required
keys are the same runtime keys listed in the staging section below. If a release
runner reports `couldn't find key DEVISE_SECRET_KEY`, the GitHub/Control Plane
token path worked, but this app secret dictionary is still missing values.

Review and staging apps accept the Control Plane Rails workload hostname
directly when it matches `rails-*.cpln.app`, so fresh apps do not need a manual
`CUSTOM_DOMAIN` GVC update.

Use the review URL to verify:

- `/`
- `/dashboard/inertia_demo`
- `/dashboard/rsc_demo`

The dashboard comparison requires sign-in. When `ALLOW_DEMO_SEED=true`, use:

```text
seller@gumroad.com / password
```

Review and staging demo apps allow login without `RECAPTCHA_LOGIN_SITE_KEY` so
the public demo does not need a Google reCAPTCHA project. The Control Plane
production demo app does not inherit that bypass; production release fails
early unless `RECAPTCHA_LOGIN_SITE_KEY` and `ENTERPRISE_RECAPTCHA_API_KEY` are
configured.

## Staging workflow

`main` deploys to:

```text
react-on-rails-demo-gumroad-rsc-staging
```

Bootstrap once before the first deploy:

```sh
cpflow setup-app -a react-on-rails-demo-gumroad-rsc-staging --org shakacode-open-source-examples-staging --skip-post-creation-hook
```

Then set runtime secrets in Control Plane:

- `SECRET_KEY_BASE`
- `DEVISE_SECRET_KEY`
- `STRONGBOX_GENERAL`
- `STRONGBOX_GENERAL_PASSWORD`
- `OBFUSCATE_IDS_CIPHER_KEY`
- `OBFUSCATE_IDS_NUMERIC_CIPHER_KEY`
- `RENDERER_PASSWORD`
- `REACT_ON_RAILS_PRO_LICENSE`

Use `openssl rand -hex 64` for the long secret values and a positive integer
for `OBFUSCATE_IDS_NUMERIC_CIPHER_KEY`.

The review, staging, and production workflows run
`bin/prepare-control-plane-db-secrets` before deploying. That script creates
`<app-name>-mysql` and `<app-name>-mongo` with random passwords if they do not
already exist. Existing DB secrets are not rotated because MySQL and Mongo only
apply initialization passwords on an empty data volume. If the script detects
old public placeholder database passwords, it fails and requires explicit
rotation or app database reset.

The Mongo template intentionally does not set `command: mongod`. Keep the
official Docker entrypoint and pass flags such as `--bind_ip_all` through
`args`; otherwise Mongo starts without entrypoint initialization and binds only
inside the container.

Branch deployments allow login when `RECAPTCHA_LOGIN_SITE_KEY` is blank. That
is deliberate for review/staging demos, where requiring a Google reCAPTCHA
project would add setup friction unrelated to the RSC comparison.

## Why this is not the full Gumroad deployment

Gumroad's production topology includes more infrastructure and operational
concerns than this experiment needs. For the RSC business case, the important
question is whether the bounded React on Rails Pro + RSC route can keep beating
the matched Inertia control in a stable, deployed environment. This scaffold is
designed to answer that question with the smallest reviewable deployment shape.

## Local validation

Before opening deployment changes, run:

```sh
bin/test-cpflow-github-flow
docker build -f .controlplane/Dockerfile -t gumroad-rsc-cpflow-smoke .
```

The Docker build intentionally compiles Shakapacker/Rspack assets and the RSC
bundles inside the same image GitHub Actions will deploy.
