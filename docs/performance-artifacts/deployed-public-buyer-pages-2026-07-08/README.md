# Deployed Public Buyer Pages, 2026-07-08

This artifact captures the deployed public demo after the public buyer-page work
landed on `https://gumroad.reactonrails.com`.

Method:

- `scripts/perf/compare_dashboard_routes.rb`
- headless Chrome `150.0.7871.49` with ChromeDriver `150.0.7871.115`
- `8` alternating cycles per route pair
- `2` warmup requests per measured run
- `--public` and `--require-driver-match`

## Median Results

| Surface              |                 Median nav duration |                 Median response end |                    Median LCP start |           JS requests |
| -------------------- | ----------------------------------: | ----------------------------------: | ----------------------------------: | --------------------: |
| Product detail       | `883.90ms` -> `267.25ms` (`-69.8%`) |  `206.45ms` -> `206.60ms` (`+0.1%`) | `354.00ms` -> `304.00ms` (`-14.1%`) | `9` -> `1` (`-88.9%`) |
| Discover marketplace | `867.15ms` -> `300.30ms` (`-65.4%`) | `201.70ms` -> `243.30ms` (`+20.6%`) |  `362.00ms` -> `350.00ms` (`-3.3%`) | `9` -> `1` (`-88.9%`) |

Interpretation:

- RSC wins median browser navigation and route JavaScript request count on both public route pairs.
- Product detail also wins median LCP; Discover median LCP is about tied under the 5% benchmark band while p95 LCP favors RSC.
- RSC response-end is essentially tied on product and slower on Discover because the rendered document is streamed server-side.
- This is deployed desktop headless Chrome evidence. Treat the deployed Lighthouse URL-pair artifact as diagnostic only; mobile PageSpeed evidence against live Gumroad still needs media parity and reruns.

See `summary.json` for the readable rollup and the `*-comparison.json` files
plus `*-runs/` folders for full ShakaPerf output. The raw ShakaPerf JSON files
are intentionally compacted to keep the GitHub PR diff reviewable.
