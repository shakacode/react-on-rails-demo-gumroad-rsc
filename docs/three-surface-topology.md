# Gumroad demo surfaces

The demo is intentionally split into three independently releasable sites. A
landing-page deploy must never replace the legacy control or silently change the
renderer used by the next site.

| Surface | Canonical URL | Source contract | Rendering contract |
| --- | --- | --- | --- |
| Legacy | Target: `https://legacy.gumroad.reactonrails.com` | Pin the Gumroad application at `e2343f98db315198c4c898f9efcca5c26fa0e9ab`, the last commit before Justin Gordon's RSC work began on April 12, 2026. Backport deployment-only files without changing page code. | Existing Inertia/ERB behavior. Requests cannot opt into RSC. |
| Next | Target: `https://next.gumroad.reactonrails.com` | Fork from the same pre-Justin SHA as Legacy, then add only RSC runtime, deployment, and parity changes. Page data, copy, assets, paths, query parameters, and interactions must remain matched to Legacy. | Every existing Inertia page response is transported through the universal RSC page shell. Route-specific native RSC implementations may progressively replace the compatibility shell without changing URLs or content. |
| Landing | `https://gumroad.reactonrails.com` | Release the independently evolving landing/evidence branch. | Marketing and evidence content may change without changing either comparison surface. |

The corresponding Control Plane app names are:

```text
react-on-rails-demo-gumroad-legacy
react-on-rails-demo-gumroad-next
react-on-rails-demo-gumroad-rsc-staging  # existing Landing app
```

`DemoRenderingSurface` derives the runtime surface from the app-name suffix.
`GUMROAD_RENDERING_SURFACE=legacy|next|landing` is an explicit override for
other hosting environments. The response header
`X-Gumroad-Rendering-Surface` makes the selected product renderer observable.

## Same-URL rule

Legacy and Next must use the same path. For example, a seeded Discover-layout
product is opened at both hosts as:

```text
https://legacy.gumroad.reactonrails.com/l/O365IT?layout=discover&recommended_by=search
https://next.gumroad.reactonrails.com/l/O365IT?layout=discover&recommended_by=search
```

The Next host selects RSC at the server. It does not add `rsc=1`, change the
fixture, or route to a hand-written comparison page. The Legacy host is locked
to the existing renderer even if someone adds `rsc=1` manually.

The canonical 16-product seed identities and equal Legacy/Next paths live in
the machine-readable
[`config/development_staging_products.yml`](../config/development_staging_products.yml)
catalog. Seed code and comparison tooling consume that source rather than
copying database-generated permalinks.

## Current migration coverage

The Next renderer intercepts all existing `render inertia:` responses and
streams the unchanged component name and fully resolved props through React on
Rails RSC. The shell bundles the existing page registry, applies the same
public, signed-in, or admin layout, and preserves the existing providers.
Inertia-link requests receive HTML rather than Inertia JSON and fall back to a
full navigation, ensuring each page response crosses the RSC transport.

The database-backed Discover-layout product detail route also has a dedicated
native RSC implementation. Route-specific conversions may progressively replace
the universal compatibility shell, but they must have all of the following:

1. A server component consuming the same presenter data.
2. The unchanged public path on the Next host.
3. Behavior, content, accessibility, and visual parity coverage against Legacy.
4. A test proving Legacy cannot select the new renderer.

This distinction keeps the three-site topology usable now without claiming
that the entire Gumroad application has already been converted.

## Deployment order

1. Create a maintenance branch from the pre-Justin SHA and backport only the
   current Control Plane packaging, security fixes, and demo seed tooling.
2. Bootstrap the three persistent apps with `cpflow setup-app`, using the app
   names above and the staging organization documented in
   [`.controlplane/readme.md`](../.controlplane/readme.md).
3. Deploy the legacy maintenance branch to the Legacy app, the RSC migration
   branch to Next, and the landing branch to Landing.
4. Set `CUSTOM_DOMAIN` on each app to its canonical hostname, attach the three
   hostnames to their Rails workloads, and configure DNS/TLS. Legacy and Next
   also need wildcard DNS/TLS for `*.legacy.gumroad.reactonrails.com` and
   `*.next.gumroad.reactonrails.com` so seller-profile and product subdomains
   keep working.
5. Seed the same fixture identities into Legacy and Next, then verify matching
   paths and the rendering-surface header before publishing links.

DNS and hosted workload mutations are operational steps; committing this file
or merging landing-page changes must not perform them implicitly.
