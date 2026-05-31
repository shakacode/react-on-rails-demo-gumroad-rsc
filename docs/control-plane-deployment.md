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

The workflow creates:

```text
react-on-rails-demo-gumroad-rsc-review-pr-<PR number>
```

Use the review URL to verify:

- `/`
- `/dashboard/inertia_demo`
- `/dashboard/rsc_demo`

The dashboard comparison requires sign-in. When `ALLOW_DEMO_SEED=true`, use:

```text
seller@gumroad.com / password
```

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
- `RENDERER_PASSWORD`
- `REACT_ON_RAILS_PRO_LICENSE`

Replace the generated MySQL and Mongo placeholder passwords before sharing the
staging URL outside the team.

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
