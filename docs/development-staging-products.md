# Development/staging product catalog

The 16 canonical development/staging products and their stable URL paths are
defined in [`config/development_staging_products.yml`](../config/development_staging_products.yml).
That file is the source of truth for seed code, documentation, and comparison
tooling; consumers should parse it rather than copy its names or permalinks.

Every catalog entry has an explicit `seller_username`, `permalink`,
`legacy_path`, and `next_path`.
The two paths are deliberately identical. The renderer is selected by the host:

- Legacy: `https://legacy.gumroad.reactonrails.com` plus `legacy_path`
- Next: `https://next.gumroad.reactonrails.com` plus `next_path`

The fixed widget URL remains `/l/demo`. Taxonomy products use validation-safe
`demo_*` permalinks. Re-running the seeds adopts an existing recognizable
pre-catalog product by its legacy seed signature, records durable ownership,
and changes its generated permalink in place. It does not create a duplicate.
If a stable permalink or logical seed identity belongs to an unrelated record,
the seed fails with an ownership conflict instead of overwriting it.

The dedicated ShakaPerf seed runner freezes the catalog at
`2026-08-12 12:00:00 UTC` and uses stable `seed_<permalink>` offer codes, so
fresh isolated databases expose equal render-relevant product, seller, sale,
and review snapshots. Canonical seller public IDs derive from their catalog
emails. Verify this contract locally with:

```shell
scripts/verify_development_staging_product_surfaces
```

The verifier creates two clean, uniquely named MySQL databases, starts separate
Redis processes, uses distinct Mongo database names, and launches independent
Rails seed and snapshot processes. It compares the actual
`ProductPresenter#product_page_props` plus database/external IDs, seller and
refund-policy state, purchases, reviews, tags, taxonomies, and offer codes for
all 16 products, then removes the temporary services and databases. BCrypt
digests and OTP secrets remain intentionally random and are the only excluded
seller fields; both are authentication-only secrets that never reach the
product presenter.

ShakaPerf uses `seller_username` with the surface host and configured twin port
to form a direct creator-host URL. For example, the film entry becomes
`http://gumbofilm.legacy.gumroad.reactonrails.com:3100/l/demo_films` for the
local Legacy twin and
`http://gumbofilm.next.gumroad.reactonrails.com:3200/l/demo_films` for Next.
See [ShakaPerf A/B testing](./shakaperf-ab-testing.md) for the complete selected
subset and commands.
