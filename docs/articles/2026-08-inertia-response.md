# Gumroad's Inertia Migration and the Public-Page Tradeoff

Gumroad's account of moving from React on Rails to Inertia is a useful description of a successful architecture change. The problems it names are familiar: full reloads interrupted navigation, a persistent application shell kept disappearing, server and browser rendering paths had to stay aligned, internal APIs repeated data-loading work already owned by Rails, and client routing sat inside server-routed pages. Inertia addressed those problems with a coherent model. Rails still owns routing, authorization, and data loading, while React receives page props and Inertia handles navigation and forms.

For a creator dashboard, that is a strong trade. Authenticated users revisit the same application, the shell persists, navigation can reuse warm state, and search indexing is not the product requirement. Partial reloads, deferred props, prefetching, and Rails-owned validation all fit that workload. We would recommend taking those benefits seriously rather than treating Inertia as a temporary compromise.

Our question starts where that conclusion stops: does the same trade remain favorable for a logged-out product or marketplace page?

## The backend thesis is shared

The most important sentence in Gumroad's article is this:

> "we already had the right architecture on the backend. We just needed a better way to deliver it to the frontend."

That is also the premise behind React Server Components in a Rails application. Rails can remain the source of truth for routes, authorization, and data. The open question is what Rails delivers across the rendering boundary: a page object for the browser to render, pre-rendered HTML through Inertia SSR, or a server-rendered React tree with explicit server and client component boundaries.

This is not a dispute about whether Gumroad diagnosed its old dashboard correctly. It did. It is a continuation of the same backend-first argument into a different class of page.

## Dashboard navigation and public acquisition are different workloads

The migration article is mostly about creator application pages. Those pages reward persistent navigation, form ergonomics, deferred data, and a simple controller-to-props path. Inertia is an excellent fit there.

Public buyer pages have a different budget. A visitor may arrive for the first time with a cold cache and an uncertain network. The initial document, metadata, client JavaScript, and time until useful content matter before any SPA navigation benefit exists. Product and Discover surfaces are therefore where we tested React Server Components through React on Rails Pro. We measured a different workload, not a correction to the dashboard decision. This is the distinction behind our [published positioning](../positioning-notes.md): Inertia is excellent for many Rails pages, while some public product surfaces need a stronger initial-rendering and client/server composition story.

Inertia can add server-side rendering, and its head component can manage metadata. Those capabilities matter. Once SSR enters the design, however, the operational comparison changes.

## The rendering-pipeline complaint, examined more closely

Gumroad removed a server-side JavaScript rendering path, its server bundle, and the runtime that supported them. That genuinely simplified production. But the simplification came from removing server rendering, not from an intrinsic property that makes Inertia SSR single-pipeline.

The [Inertia Rails SSR guide](https://inertia-rails.dev/guide/server-side-rendering) is explicit about production: build the client and SSR bundles, then run the SSR server as a background process. The Rails adapter can supervise that process through Puma, which improves operations, but the rendering runtime and server bundle still exist. The [current Inertia SSR documentation](https://inertiajs.com/docs/v3/advanced/server-side-rendering) likewise describes a Node-based production server and separate client and server builds.

React Server Components through React on Rails Pro also require a Node renderer and multiple build outputs. We should say that plainly. The decision is not "one pipeline or two" once server rendering is required. It is whether the initial-rendering, metadata, streaming, and server/client composition benefits justify the additional build and runtime surface for the pages that need them.

For a dashboard that does not need SSR, the answer may be no. For an acquisition-sensitive public page, the calculation can change.

## The page data has two jobs

On an initial Inertia visit, the server serializes the page object into the document. In the current protocol, that object is carried by a JSON script element marked with `data-page`; older clients used the root element's attribute. The browser then reads those props and renders the page component into the DOM. The same application data therefore has a serialized transport representation and a rendered UI representation, with client work between them. This is easy to inspect in View Source on an Inertia page, and it follows directly from [Inertia's protocol](https://inertiajs.com/docs/v3/core-concepts/the-protocol).

That does not mean identical bytes cross the network twice. It means the initial response pays for serialized props, then the browser pays to turn them into UI. In our stable run, the Product control carried a [`15,040 B` Inertia page payload](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json), and the Discover control carried [`33,966 B`](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). The RSC candidates had no Inertia page object, but that did not make their responses smaller in every dimension. They sent substantially more HTML. This implementation also streams its RSC tree inline, so removing the Inertia page object does not mean removing protocol overhead or client work. It changes the rendering boundary.

## What the bounded lab run measured

The [canonical run used independent alternating batches, explicit server warmups, and unthrottled desktop headless Chrome](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). Both route pairs used the same host and shared presenter fixtures. Values below are medians, with Inertia first and the RSC candidate second.

| Surface | Navigation duration | Response end | Largest Contentful Paint start | Encoded HTML body, compressed and excluding headers | JavaScript transfer | Inertia page payload |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Product | [`1,123.5 ms` -> `575.0 ms` (`-48.8%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`504.85 ms` -> `509.55 ms` (`+0.9%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`662 ms` -> `602 ms` (`-9.1%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`6,426 B` -> `11,590.5 B` (`+80.4%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`162,696 B` -> `82,228.5 B` (`-49.5%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`15,040 B` -> none](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) |
| Discover | [`1,097.9 ms` -> `630.45 ms` (`-42.6%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`473.9 ms` -> `492.8 ms` (`+4.0%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`768 ms` -> `648 ms` (`-15.6%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`9,780 B` -> `19,580 B` (`+100.2%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`162,696 B` -> `82,223 B` (`-49.5%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`33,966 B` -> none](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) |

The full-navigation result is clear for these deployed routes. Product LCP improved modestly, while Discover LCP moved in the same direction with more variation between batches. Response end did not improve. RSC's HTML was materially larger on both surfaces, even as transferred JavaScript was roughly halved and the Inertia page object disappeared.

These medians describe the bounded capture. They are not confidence intervals or a substitute for field evidence.

Those observations need the limits beside them:

- This is an end-to-end comparison of the deployed routes, not an estimate of RSC alone. The RSC routes use isolated bundles and skip the legacy application bundle. The Inertia routes also load analytics and tag-manager scripts that the RSC routes omit. Bundle isolation is part of the candidate architecture; third-party omission is a parity gap. The [causal limit is documented in the repository](../current-status.md#causal-limit).
- The fixtures are synthetic. They include local SVG media, but the [sampled live Gumroad pages transferred orders of magnitude more media](../current-status.md#live-gumroad-parity-audit), with different formats, chrome, caching, and third parties.
- The run used unthrottled desktop headless Chrome. It is not mobile, mobile-throttled, PageSpeed, or field data. We make no INP or TBT claim.
- Discover LCP was noisier than Product LCP, so the median should not be presented as equally strong evidence on both surfaces.
- The capture predates the versioned benchmark contract. Its media-presence command output and exact arm-to-arm media inventory comparison were not preserved, and viewport details were reconstructed from the pinned harness rather than recorded as explicit artifact fields. The [contract accepts those gaps only for this historical capture](../rsc-lab-benchmark-contract-v1.md#historical-capture-exception).
- The deployment needed warm-up before the media gate passed, and measured runs deliberately included server warmups. The harness also opened the common host root before each target, warming a shared connection and common resources. That is balanced between the routes, but it is not a fully cold first visit. These conditions are preserved in the [immutable run summary](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json).

The supported conclusion is correspondingly narrow: this RSC candidate delivered faster full navigation and less JavaScript for these matched public-page fixtures, with modest or noisy LCP improvements, no response-end win, more HTML, and important resource-parity gaps.

## Real product-page run pending

<!-- PENDING: real-product-page run, numbers land separately -->

This follow-on will use a real product-page implementation rather than the synthetic matched pair. It matters more because it exposes the rendering approaches to production-shaped component complexity, media, chrome, and third-party behavior. We will keep its results separate rather than backfilling them into the laboratory table.

## What adopting this path costs

The candidate is not a drop-in configuration switch. A team must account for:

- A [React 19 application stack](../current-status.md#react-192--pro-17-status), including ecosystem and type migration work for an application coming from an earlier React line.
- Shakapacker with Rspack. In this experiment Rspack is build infrastructure and a developer-loop choice, not the explanation for the runtime result.
- A production Node renderer, with process supervision, credentials, health checks, capacity planning, observability, and fallback behavior.
- A React on Rails Pro license and the organizational decision to depend on a commercial rendering layer.
- More build outputs and a more demanding deployment than client-rendered Inertia.

These costs are real. The Node process and server bundle are not unique to React on Rails Pro if the alternative is Inertia SSR, but React Server Components add their own integration and composition model. A team should pay that cost only on surfaces where the return is measurable.

## A route-level decision, not a reversal

Gumroad's migration demonstrates why Inertia is a productive default for Rails-owned application pages. Our experiment asks whether logged-out buyer pages deserve a different rendering boundary. So far, the answer is promising enough to keep measuring, not broad enough to prescribe a wholesale change.

The [benchmark contract](../rsc-lab-benchmark-contract-v1.md) and [raw artifact summary](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) are committed in the public repository. Inertia remains the control, a valid choice for the dashboard, and a practical rollback path for the experiment. The useful decision is not which framework wins in the abstract. It is which delivery model earns its operational cost on a particular route.
