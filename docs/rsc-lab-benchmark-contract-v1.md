# RSC lab benchmark contract v1

## Status and supported claim

This versioned contract governs the public buyer-page benchmark. Its headline evidence is the serialized, same-host ShakaPerf A/B run of these deterministic route pairs:

| Surface | Inertia control | React on Rails Pro RSC candidate |
| --- | --- | --- |
| Product | `/public_product/inertia_demo` | `/public_product/rsc_demo` |
| Discover | `/public_product/discover_inertia_demo` | `/public_product/discover_rsc_demo` |

The supported claim is an **end-to-end route comparison**: under this fixture, host, and protocol, the deployed RSC candidate had the recorded navigation, LCP, transfer, and payload outcomes against its matched Inertia control. It is not a claim that RSC alone caused an outcome. The candidate's dedicated bundle is part of the architecture under test, while the Inertia control's legacy application JavaScript and analytics/tag-manager requests are a documented parity gap.

`production-shaped` means a deterministic, measurable approximation of public buyer-page shape. It does not mean production traffic, production-equivalent media, or a field-performance claim.

## Evidence hierarchy and named variants

1. **Historical / headline A/B:** the stable-host, media-bearing ShakaPerf result captured July 10, 2026 UTC: two independent batches of eight alternating cycles per pair, with two warmups before each measured run. The immutable summary, four manifests, and 64 raw measurements live in [`performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10`](./performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/README.md). This is the only headline evidence in v1.
2. **Future lab-clean A/B:** a separately named route pair with third parties disabled on both arms. It may estimate the rendering-stack effect only after its fixture and resource parity checks pass. It does not rewrite the historical result.
3. **Future production-shaped A/B:** a separately named route pair with the required analytics and other agreed production-shaped dependencies enabled on both arms. It may improve causal framing only after its own contract and validation pass.
4. **Diagnostic live comparisons:** PageSpeed, Lighthouse, live Gumroad, and mobile/field-adjacent observations are for finding gaps or downstream corroboration. They are not headline evidence while media, chrome, caching, fonts, and third-party services differ.

Final-release validation is deliberately deferred; it is not satisfied by the historical/headline run.

## Fixture identity contract

Both arms of a route pair must render the same deterministic presenter fixture, shared visual/content structure, local synthetic media inventory, and public mode. A run is invalid when either arm differs in fixture revision, item order, route parameters, locale/currency, media inventory, or eager/lazy assignment. Except for the single historical capture grandfathered below, the run record must include the application commit, fixture-source revision, base URL, both paths, the media-presence result, and an exact arm-to-arm media inventory comparison. The existing minimum media-presence check is:

```bash
node scripts/perf/assert_public_demo_media_parity.mjs --base-url "$TARGET_BASE_URL"
```

Despite its historical filename, that script checks minimum unique-media and initial-image counts independently; it does not prove exact equality between arms. For every rerun or new variant, also record the ordered media URL set, occurrence count, and eager/lazy assignment for each arm and compare them for exact equality. Missing exact comparison evidence makes the run ineligible for the headline even when the minimum-presence script passes.

The source of truth for the v1 fixture is `PublicProductRscDemoPresenter`, the shared comparison component, the public-shape sampling artifact, and the stable-host desktop/mobile resource audits. The audits retain URLs, hosts, MIME types, dimensions, cache policy, and transfer metadata without copying creator-owned media.

| Profile field | v1 requirement / known value | Evidence and pass/fail |
| --- | --- | --- |
| Product content | One attributed Product detail, with seller, cover, rating, price, purchase framing, rewritten description, files, FAQ, and **8** recommendation cards. | Presenter + shared component. Both arms must expose the same fields and 8 cards; otherwise fail. |
| Discover content | **36** synthetic product cards, **8** tag buckets, **8** filetype buckets, taxonomy navigation, and featured collections. | Public-shape sampling + presenter. Both arms must expose identical ordered data; otherwise fail. |
| Media count and reuse | Product requests five small synthetic SVG resources (about **11 KB** total in the recorded audit); Discover uses **8** unique synthetic SVG files across 36 cards (about **17 KB** recorded). | `current-status.md` and stable resource audits. Count/unique-file set must match the recorded inventory for both arms; any change requires a new fixture revision and is not comparable to v1. |
| Formats and transfer | Local fixture media is SVG only. The transfer figures above describe the current fixture, not a production-media target. | Presenter/media audit. A non-SVG or inventory/weight change invalidates v1 comparability until documented and rerun. |
| Natural and rendered dimensions | **Provisional — owner: benchmark maintainer.** v1 does not freeze a dimension table because the checked-in public audit is the evidence source and current documentation does not publish a stable per-asset natural/rendered inventory. | Before a production-shaped claim, export both viewport audits (390 x 844 and 1440 x 1100), record per-image natural/rendered dimensions, and set tolerances. Until then, dimension parity means the same rendered markup/media inputs on both arms, not parity with live Gumroad. |
| Loading behavior | Product hero is eager/high priority; Product's first **4** recommendations and Discover's first **8** cards are eager/high priority; remaining cards are lazy. No `srcset`/`sizes`. | Shared component + current-status audit. Both arms must have the same assignments; otherwise fail. |
| Text density | Product's rewritten long-form buyer content and Discover's 36 card summaries/metadata are fixed by the presenter. **Provisional numeric tolerance — owner: benchmark maintainer.** | Validate a fixture digest or normalized text/HTML inventory before each new named variant. Any content change requires a new fixture revision, not reuse of v1 aggregates. |
| Pricing and metadata | Product is USD $47 with source title/seller/type/rating identity; Discover cards carry USD price, seller, rating, taxonomy, type, format, audience, and sales metadata. | Presenter + public-shape sampling. Values/order must match between arms; otherwise fail. |
| Fonts and chrome | Demo media/fonts were observed as Cloudflare hits with four-hour caching. Production chrome and font parity are **provisional — owner: benchmark maintainer**. | Stable resource audit is the baseline. Before production-shaped/mobile claims, capture an explicit font/chrome request inventory and document inclusion/exclusion. A live parity assertion cannot pass until that target exists. |

The live audit is intentionally a contrast, not a target silently smuggled into the headline: sampled live Product used roughly 2.3–3.2 MB of mixed WebP/PNG/SVG media; live Discover used roughly 11–16 MB across about 100 image requests with WebP, PNG, JPEG, GIF, and SVG. Those differences are why live comparisons remain diagnostic.

### Invalidation rules

Reject a v1 headline comparison if the media-presence script fails, exact arm-to-arm media equality is not proven, either arm has a non-200 navigation or different fixture identity, the browser/driver major versions do not match, required raw artifacts are missing, or the serialized protocol below was not followed. A run that changes fixture content, media, loading behavior, chrome, fonts, analytics, or route resources is a new named variant and must not be aggregated with the July 10 v1 result.

## Execution and artifact protocol

Complete Product batch 1 and Product batch 2 before starting Discover batch 1; then complete Discover batch 1 and Discover batch 2. Within each batch, serialize the Inertia/RSC pair through alternating cycle order so each arm occupies each position. Do not interleave surfaces, run pairs concurrently, or combine unlabelled batches.

- Run two independent batches of eight alternating cycles per pair, with two server warmups before each measured run, in public mode and with a browser/driver major-version match.
- Record host/base URL, application commit, exact route paths, UTC timestamps, browser name/version, ChromeDriver version, operating system/platform, harness/driver versions, viewport/emulation, public-mode flags, timeout, cycle order/position, warmup count, and any HTTP/transient failure.
- Preserve the comparison manifests and per-navigation raw metrics as immutable artifacts. Do not overwrite, trim, or average away an outlier; label replacements and link them as a later capture.
- Record the media-presence command/result, exact arm-to-arm media inventory comparison, and fixture revision alongside the run. A warm-up `503` is a reproducibility observation, not a successful measured sample.

### Historical capture exception

The July 10 headline capture predates this contract. Its exception is limited to the immutable artifact set at application commit `cc61125b02ec0282ec455c044240e97b6a33b741`; that commit is the best available fixture revision. The pinned harness source reconstructs the ShakaPerf viewport as 1440 x 1100 headless desktop Chrome with no device emulation, but the artifacts do not record those as explicit fields. This must not be confused with the separate 390 x 844 mobile and 1440 x 1100 desktop resource audits. The media-presence command stdout and an exact arm-to-arm inventory comparison were not preserved; the artifact README and summary record that the gate passed after one transient warm-up `503`, and the resource audits provide supporting state, but not the missing command log or exact-equality proof.

Those gaps narrow the historical claim and are accepted only so v1 can identify the evidence that already exists. Every rerun and every new named variant must satisfy the complete run-record requirements above; none may reuse this exception or silently fill an `UNKNOWN` field.

The headline must keep the end-to-end/no-RSC-alone boundary in every summary: it may report the observed route result and architecture bundle isolation, but must not attribute the result solely to RSC while third-party execution differs.

## Release gates mapped to this contract

The six remaining gates in [`current-status.md`](./current-status.md) map as follows. All are open in v1; final-release validation is deferred until gates 1 and 2 complete.

| Gate | Contract requirement | v1 state |
| --- | --- | --- |
| 1. Pro 17.0.0 final | Final release must be publicly available before final-release validation. | Deferred / open. |
| 2. Upgrade, deploy, media gate, repeat protocol | Rerun the exact serialized two-batch protocol with recorded browser/driver versions after upgrading and deploying final. | Deferred / open. |
| 3. Analytics/legacy asymmetry | Keep the historical result end-to-end; add separately named lab-clean and production-shaped pairs before any RSC-alone framing. | Open. |
| 4. Production-parity target | Freeze image, format, dimension, responsive behavior, font, chrome, cache/CDN, and third-party targets; then rerun mobile diagnostics. | Open; provisional fields above name their owner/method. |
| 5. Mobile/field-relevant corroboration | Use a mobile-throttled harness or field-relevant setup as downstream evidence. | Open; not a replacement for the headline A/B. |
| 6. PageSpeed discipline | Keep PageSpeed diagnostic unless service/media differences are controlled or disclosed. | Open; no favorable score substitutes for the matched A/B. |

## Change control

This file is versioned because changes to the fixture or protocol change what a benchmark means. Update to a new contract version when a new named variant becomes eligible, rather than retroactively broadening v1's claim.
