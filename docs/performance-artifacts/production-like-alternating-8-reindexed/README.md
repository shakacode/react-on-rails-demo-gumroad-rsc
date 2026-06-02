# Production-Like Alternating 8-Cycle Benchmark

This directory tracks the compact JSON evidence for the production-like
compiled-asset benchmark described in `docs/performance-findings.md`.

- `comparison.json` is the aggregate comparison output.
- `runs/` contains the 16 per-route metric JSON files used to build the
  aggregate comparison.

The same files were originally generated under ignored
`output/playwright/dashboard-perf/` paths. They are copied here so reviewers can
validate the route order, browser provenance, sample recovery, and percentile
summary behind the headline benchmark without relying on local untracked output.
