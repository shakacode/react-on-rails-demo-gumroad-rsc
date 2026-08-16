# Development/staging product catalog

The 16 canonical development/staging products and their stable URL paths are
defined in [`config/development_staging_products.yml`](../config/development_staging_products.yml).
That file is the source of truth for seed code, documentation, and comparison
tooling; consumers should parse it rather than copy its names or permalinks.

Every catalog entry has an explicit `permalink`, `legacy_path`, and `next_path`.
The two paths are deliberately identical. The renderer is selected by the host:

- Legacy: `https://legacy.gumroad.reactonrails.com` plus `legacy_path`
- Next: `https://next.gumroad.reactonrails.com` plus `next_path`

The fixed widget URL remains `/l/demo`. Taxonomy products use validation-safe
`demo_*` permalinks. Re-running the seeds adopts an existing recognizable
pre-catalog product by its legacy seed signature, records durable ownership,
and changes its generated permalink in place. It does not create a duplicate.
If a stable permalink or logical seed identity belongs to an unrelated record,
the seed fails with an ownership conflict instead of overwriting it.
