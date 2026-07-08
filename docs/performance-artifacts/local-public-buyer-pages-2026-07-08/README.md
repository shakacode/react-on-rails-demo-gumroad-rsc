# Local Public Buyer Page A/B, 2026-07-08

Supporting local benchmark for the attributed public product fixture and the
Discover marketplace fixture.

## Method

- Environment: local `RAILS_ENV=test` Rails server at `http://app.test.gumroad.com:31338`
- Renderer: React on Rails Pro node renderer at `http://127.0.0.1:3800`
- Browser: headless Chrome `149.0.7827.201` with ChromeDriver `149.0.7827.155`
- Harness: `scripts/perf/compare_dashboard_routes.rb`
- Cycles: `6` alternating cycles per route pair, route order rotated each cycle
- Warmup: `2` server warmup requests per measured run
- Public mode: yes, no login or cookies

## Commands

```bash
DISABLE_SPRING=1 RAILS_ENV=test REACT_RENDERER_URL=http://127.0.0.1:3800 \
  ruby scripts/perf/compare_dashboard_routes.rb \
  --public \
  --base-url http://app.test.gumroad.com:31338 \
  --measure-base-url http://app.test.gumroad.com:31338 \
  --path /public_product/inertia_demo \
  --path /public_product/rsc_demo \
  --label local-attributed-product-2026-07-08 \
  --cycles 6 \
  --server-warmup-requests 2 \
  --require-driver-match \
  --timeout 90 \
  --output-dir docs/performance-artifacts/local-public-buyer-pages-2026-07-08
```

```bash
DISABLE_SPRING=1 RAILS_ENV=test REACT_RENDERER_URL=http://127.0.0.1:3800 \
  ruby scripts/perf/compare_dashboard_routes.rb \
  --public \
  --base-url http://app.test.gumroad.com:31338 \
  --measure-base-url http://app.test.gumroad.com:31338 \
  --path /public_product/discover_inertia_demo \
  --path /public_product/discover_rsc_demo \
  --label local-discover-2026-07-08 \
  --cycles 6 \
  --server-warmup-requests 2 \
  --require-driver-match \
  --timeout 90 \
  --output-dir docs/performance-artifacts/local-public-buyer-pages-2026-07-08
```

## Median Results

| Surface | Metric | Inertia control | RSC candidate | Delta |
| --- | --- | ---: | ---: | ---: |
| Product detail | Navigation duration | 392.7 ms | 212.8 ms | -45.8% |
| Product detail | Response end | 337.4 ms | 171.3 ms | -49.2% |
| Product detail | LCP start | 416.0 ms | 224.0 ms | -46.2% |
| Product detail | HTML transfer | 24,291 B | 179,407.5 B | +638.6% |
| Discover marketplace | Navigation duration | 375.45 ms | 303.7 ms | -19.1% |
| Discover marketplace | Response end | 313.6 ms | 245.25 ms | -21.8% |
| Discover marketplace | LCP start | 400.0 ms | 322.0 ms | -19.5% |
| Discover marketplace | HTML transfer | 46,336 B | 452,345.5 B | +876.2% |

## Stream Timing

| Surface | Server-Timing metric | Median |
| --- | --- | ---: |
| Product detail RSC | `ror_renderer_prepare` | 1.77 ms |
| Product detail RSC | `ror_stream_shell` | 108.54 ms |
| Discover marketplace RSC | `ror_renderer_prepare` | 2.69 ms |
| Discover marketplace RSC | `ror_stream_shell` | 155.17 ms |

## Notes

This is the current-branch same-fixture ShakaPerf evidence. The hosted
`2026-06-24` artifact remains useful historical context for production-hosted
JavaScript transfer and request-count deltas, but it predates the Tendon Book
fixture and is no longer the headline current result. The PageSpeed comparator
links in the performance lab are the external public-site rerun path.

The local test environment reports much larger RSC HTML because the streamed
server-rendered content is in the document. Treat that as a known tradeoff, not
as a standalone verdict. JavaScript pack deltas are not used from this local run
because this test-pack measurement recorded `0` route scripts for both variants.
