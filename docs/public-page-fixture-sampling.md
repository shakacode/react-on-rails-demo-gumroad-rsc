# Public Page Fixture Sampling

## Goal

The Gumroad RSC demo needs realistic public buyer-page data without copying
creator content into a public ShakaCode demo repository.

The policy is:

- Sample public Gumroad pages for component names, prop keys, field types, and
  counts.
- Do not commit creator copy, seller URLs, product URLs, image URLs, thumbnails,
  or real product names.
- Build curated synthetic fixtures that preserve the production data shape
  needed for an apples-to-apples Inertia versus React Server Components
  benchmark.

The sanitized shape artifact is committed at
[docs/performance-artifacts/public-gumroad-shape-sampling-2026-06-24/summary.json](performance-artifacts/public-gumroad-shape-sampling-2026-06-24/summary.json).

## What Was Sampled

Run command:

```bash
node scripts/perf/sample_public_gumroad_shapes.mjs https://gumroad.com/discover
node scripts/perf/sample_public_gumroad_shapes.mjs '<public product URL with layout=discover>'
```

The sampler prints only the source category, page component name, top-level prop
keys, selected field shapes, array counts, status, and response size. It omits
the sampled URL and page title by default, and it does not write files or persist
scraped content. Use `--include-source-url` only for local debugging, and do not
commit that raw output.

Observed public page shapes:

| Public page | Inertia component | Useful shape signal |
| --- | --- | --- |
| Discover marketplace | `Discover/Index` | `search_results.products` has `36` cards, `tags_data` has `8` entries, `filetypes_data` has `8` entries, and `taxonomies_for_nav` has `342` entries. |
| Product with Discover layout | `Products/Discover/Show` | `product` includes seller, cover, rating, summary, `description_html`, price, purchase-state fields, refund policy, public files, and taxonomy navigation. |

## How The Fixture Uses The Shape

The committed demo fixture in `PublicProductRscDemoPresenter` keeps the public
shape but replaces content with synthetic data:

- `discover_page.products` contains `36` synthetic product cards to match the
  observed public Discover grid count.
- `discover_page.tags_data` and `discover_page.filetypes_data` contain `8`
  entries each to match the observed filter payload shape.
- `discover_page.categories` and taxonomy-like fields preserve the browse and
  category context that matters for public marketplace pages.
- `product_page` includes product name, summary, seller, price, rating
  percentages, media theme, description sections, included files, FAQ, and
  recommendations so the benchmark includes SEO and conversion-sensitive copy.
- Both the Inertia and RSC routes use the same presenter output, same host, same
  route CSS, and same benchmark harness.

## What This Comparison Proves

This is a legitimate same-data rendering comparison:

- Before: Inertia route serializes the full page payload into `data-page` and
  hydrates the public React surface on the client.
- After: React Server Components via React on Rails Pro streams the public
  content through the React on Rails renderer and avoids the serialized Inertia
  page payload.
- The current result can support claims about route JavaScript, serialized
  payload, browser navigation timing, and streamed initial content on the
  matched synthetic public surfaces.

This is not yet the final Gumroad adoption proof:

- It does not claim the production Gumroad `Discover/Index` component itself has
  been ported to RSC.
- It does not copy a real creator product page or use real creator media.
- It still needs a mobile-throttled Lighthouse/ShakaPerf repeat before making a
  stronger upstream proposal.
- A stronger follow-up would wire sanitized production-shaped props into the
  existing Gumroad public page components where feasible, then compare those
  with RSC equivalents.
