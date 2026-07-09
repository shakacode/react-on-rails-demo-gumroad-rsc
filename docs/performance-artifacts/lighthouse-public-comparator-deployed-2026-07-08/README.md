# Lighthouse Public URL Comparator, 2026-07-08 Deployed Rerun

This artifact compares the deployed React on Rails RSC demo URLs with comparable
live Gumroad URLs using local Lighthouse metrics. The PageSpeed Insights API
returned HTTP `429` from this environment, so this is a pinned Lighthouse CLI
fallback rather than PageSpeed API output.

Method:

- `lighthouse@12.8.2`
- Chrome `150.0.7871.49`
- `3` runs per URL per strategy
- strategies: mobile and desktop
- category: performance
- demo host: `https://gumroad.reactonrails.com`
- sanitized PageSpeed API probe: `pagespeed-api-probe.json` captured HTTP `429`

## URL Pairs

| Surface              | Demo URL                                                            | Live Gumroad URL                                                                   |
| -------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Product detail       | `https://gumroad.reactonrails.com/public_product/rsc_demo`          | `https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search` |
| Discover marketplace | `https://gumroad.reactonrails.com/public_product/discover_rsc_demo` | `https://gumroad.com/discover`                                                     |

## Median Results

| Surface              | Strategy |           Live -> demo score |                         Live -> demo LCP |       Live -> demo TBT |           Live -> demo total byte weight |
| -------------------- | -------- | ---------------------------: | ---------------------------------------: | ---------------------: | ---------------------------------------: |
| Product detail       | Mobile   | `0.57` -> `0.98` (`+41 pts`) | `15,590.34ms` -> `2,422.79ms` (`-84.5%`) |  `74.00ms` -> `0.00ms` |  `4,053,575 B` -> `242,140 B` (`-94.0%`) |
| Product detail       | Desktop  | `0.78` -> `1.00` (`+22 pts`) |    `1,797.56ms` -> `582.40ms` (`-67.6%`) |   `0.00ms` -> `0.00ms` |  `4,937,344 B` -> `242,142 B` (`-95.1%`) |
| Discover marketplace | Mobile   | `0.58` -> `0.97` (`+39 pts`) | `27,210.88ms` -> `2,476.85ms` (`-90.9%`) | `149.00ms` -> `0.00ms` | `12,584,127 B` -> `246,901 B` (`-98.0%`) |
| Discover marketplace | Desktop  | `0.68` -> `1.00` (`+32 pts`) |    `4,547.36ms` -> `587.42ms` (`-87.1%`) |   `0.00ms` -> `0.00ms` | `12,519,508 B` -> `247,073 B` (`-98.0%`) |

Interpretation:

- These results are strong external URL-pair evidence that the deployed RSC demo pages are lighter and faster than the comparable live Gumroad pages under Lighthouse.
- They are not same-data architecture proof; use the ShakaPerf artifacts for the controlled Inertia-vs-RSC route-pair comparison.
- Full Lighthouse JSON was not committed because it is large; `runs.ndjson` preserves the extracted metrics used to build `summary.json`.
