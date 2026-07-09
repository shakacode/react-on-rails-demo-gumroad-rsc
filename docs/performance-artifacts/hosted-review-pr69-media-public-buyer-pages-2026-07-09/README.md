# PR 69 Media-Bearing Public Buyer Pages, 2026-07-09

This artifact captures the PR 69 review app after local synthetic media fixtures
were added to the public product and Discover demo pages.

Review app: `https://rails-6rbrymb4tqrb6.cpln.app`

Head SHA: `774c46e52c6533648ac1ce11e7ed501293282bc5`

Method:

- `scripts/perf/compare_dashboard_routes.rb`
- headless Chrome `150` with ChromeDriver `150`
- `8` alternating cycles per route pair
- `2` warmup requests per measured run
- `--public` and `--require-driver-match`
- local synthetic SVG media loaded through real `<img>` elements

## Median Results

| Surface              |                   Median nav duration |                 Median response end |                    Median LCP start |           JS requests |
| -------------------- | ------------------------------------: | ----------------------------------: | ----------------------------------: | --------------------: |
| Product detail       |  `1292.15ms` -> `731.70ms` (`-43.4%`) | `137.10ms` -> `170.15ms` (`+24.1%`) | `992.00ms` -> `382.00ms` (`-61.5%`) | `9` -> `1` (`-88.9%`) |
| Discover marketplace | `1423.70ms` -> `1054.30ms` (`-25.9%`) | `140.65ms` -> `261.60ms` (`+86.0%`) | `960.00ms` -> `602.00ms` (`-37.3%`) | `9` -> `1` (`-88.9%`) |

Interpretation:

- RSC still wins median browser navigation, median LCP, and route JavaScript
  request count after adding local media fixtures.
- RSC response-end is slower because the rendered document is streamed
  server-side.
- RSC HTML transfer is substantially larger because more complete content is in
  the document.
- The media-bearing RSC bundle is larger than the Inertia route JavaScript in
  this review-app run, so the honest client-side claim is fewer JavaScript
  requests and faster measured navigation/LCP, not lower JavaScript bytes.
- Live Gumroad PageSpeed comparisons remain diagnostic only until
  production-equivalent media, cache headers, and CDN behavior are documented.

See `summary.json` for the compact rollup and the `*-comparison.json` files plus
`*-runs/` folders for full ShakaPerf output.
