# Lighthouse Public URL Comparator, 2026-07-08

This artifact compares the public React on Rails RSC demo URLs with comparable
live Gumroad URLs using local Lighthouse metrics. The PageSpeed Insights API
returned HTTP `429` from this environment, so this is a pinned Lighthouse CLI
fallback rather than PageSpeed API output.

Method:

- `lighthouse@12.8.2`
- Chrome `149.0.7827.201`
- `3` runs per URL per strategy
- strategies: mobile and desktop
- category: performance

## URL Pairs

| Surface | Demo URL | Live Gumroad URL |
| --- | --- | --- |
| Product detail | `https://gumroad.reactonrails.com/public_product/rsc_demo` | `https://jaketuura.gumroad.com/l/tendonbook?layout=discover&recommended_by=search` |
| Discover marketplace | `https://gumroad.reactonrails.com/public_product/discover_rsc_demo` | `https://gumroad.com/discover` |

## Median Results

| Surface | Strategy | Score | LCP | TBT | Total byte weight |
| --- | --- | ---: | ---: | ---: | ---: |
| Product detail | Mobile | `0.56` -> `0.99` (`+43 pts`) | `14,741.13ms` -> `2,122.72ms` (`-85.6%`) | `56.00ms` -> `0.00ms` | `4,059,130 B` -> `369,328 B` (`-90.9%`) |
| Product detail | Desktop | `0.81` -> `1.00` (`+19 pts`) | `1,724.60ms` -> `584.08ms` (`-66.1%`) | `0.00ms` -> `0.00ms` | `4,937,003 B` -> `369,122 B` (`-92.5%`) |
| Discover marketplace | Mobile | `0.58` -> `0.96` (`+38 pts`) | `11,990.70ms` -> `2,647.96ms` (`-77.9%`) | `114.50ms` -> `0.00ms` | `12,811,991 B` -> `372,678 B` (`-97.1%`) |
| Discover marketplace | Desktop | `0.76` -> `1.00` (`+24 pts`) | `3,014.54ms` -> `462.49ms` (`-84.7%`) | `0.00ms` -> `0.00ms` | `12,982,659 B` -> `372,913 B` (`-97.1%`) |

Interpretation:

- These results are strong external URL-pair evidence that the RSC demo pages are lighter and faster than the comparable live Gumroad pages under Lighthouse.
- They are not same-data architecture proof; use the ShakaPerf artifacts for the controlled Inertia-vs-RSC route-pair comparison.
- Full Lighthouse JSON was not committed because it was about `27 MB`; `runs.ndjson` preserves the extracted metrics used to build `summary.json`.
