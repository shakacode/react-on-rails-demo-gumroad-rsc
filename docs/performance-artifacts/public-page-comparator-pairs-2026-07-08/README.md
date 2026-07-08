# Public Page Comparator Pairs, 2026-07-08

This artifact documents the public URL pairs used by the Gumroad RSC performance
demo after the product fixture was switched to an attributed live source.

## Product Detail

- React on Rails RSC demo URL: `https://gumroad.reactonrails.com/public_product/rsc_demo`
- Live Gumroad comparator URL: `https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search`
- Source identity preserved in the demo: `Tendon Book`, `Jacked Athlete`, `ebook`, `$47`, `5.0` average rating across `10` reviews, and the source link.
- Long product copy policy: lightly rewritten for the demo rather than copied from the creator listing.

## Discover Marketplace

- React on Rails RSC demo URL: `https://gumroad.reactonrails.com/public_product/discover_rsc_demo`
- Live Gumroad comparator URL: `https://gumroad.com/discover`
- Fixture policy: synthetic product cards, tags, filetypes, and categories shaped from public `Discover/Index` payload observations.

## How To Use

Use the performance lab at `/public_product/performance_demo` for clickable
PageSpeed links for mobile and desktop. Mobile PageSpeed/Lighthouse should be
the headline external comparator. Desktop is a sanity check.

Use the committed alternating benchmark artifact in
`docs/performance-artifacts/local-public-buyer-pages-2026-07-08/summary.json`
as the local same-fixture A/B result. Use
`docs/performance-artifacts/hosted-review-pr63-public-buyer-pages-2026-07-08/summary.json`
as the hosted PR 63 same-fixture A/B result.

The PageSpeed Insights API returned HTTP `429` from the benchmark environment,
so `docs/performance-artifacts/lighthouse-public-comparator-2026-07-08/summary.json`
contains a pinned local `lighthouse@12.8.2` fallback for these URL pairs.

The older hosted `2026-06-24` artifact is historical support for
production-hosted JavaScript deltas. The URL pairs in this document compare the
hosted RSC demo to the live Gumroad status quo; they are not the same-data
architecture baseline.
