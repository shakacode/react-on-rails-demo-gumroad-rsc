# Hosted Review-App Public Buyer Pages, 2026-07-08

This artifact captures the PR 63 review app after commit
`7ee485531536eee980386b1fbc58729d2202c3c7` deployed to:

`https://rails-ejbbntm539k6r.cpln.app`

Method:

- `scripts/perf/compare_dashboard_routes.rb`
- headless Chrome `149.0.7827.201` with ChromeDriver `149.0.7827.155`
- `6` alternating cycles per route pair
- `2` warmup requests per measured run
- `--public` and `--require-driver-match`

## Median Results

| Surface | Median nav duration | Median response end | Median LCP start | JS requests |
| --- | ---: | ---: | ---: | ---: |
| Product detail | `602.75ms` -> `502.20ms` (`-16.7%`) | `153.00ms` -> `193.00ms` (`+26.1%`) | `500.00ms` -> `394.00ms` (`-21.2%`) | `7` -> `1` (`-85.7%`) |
| Discover marketplace | `605.30ms` -> `529.25ms` (`-12.6%`) | `152.10ms` -> `357.25ms` (`+134.9%`) | `508.00ms` -> `430.00ms` (`-15.4%`) | `7` -> `1` (`-85.7%`) |

Interpretation:

- RSC wins median browser navigation, median LCP, and route JavaScript request count on both public route pairs.
- RSC loses median response-end and HTML transfer on the review app because the rendered document is streamed server-side.
- This is hosted desktop headless Chrome evidence for the current PR, not mobile-throttled PageSpeed evidence.

See `summary.json` for the compact rollup and the `*-comparison.json` files plus `*-runs/` folders for full ShakaPerf output.
