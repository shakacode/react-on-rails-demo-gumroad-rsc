# Extending Gumroad's Inertia Migration With a Public-Page RSC Experiment

Gumroad's account of moving from React on Rails to Inertia describes a sensible response to real engineering friction. Its old frontend combined Rails-rendered layouts, React mounts, internal API calls, client-side sub-routing, and separate server and browser builds. Navigation discarded stable page chrome. Data already available to Rails took a detour through frontend-only endpoints. Forms and routing crossed framework boundaries. Each concern was manageable, but together they raised the cost of ordinary product work.

Inertia addressed that problem directly. Rails remained responsible for routing, authorization, and data loading. React received controller props without a parallel application API. Client-side visits preserved the shared layout, while partial reloads, deferred props, prefetching, and Inertia's form helpers supplied the application behavior the creator dashboard needed. Removing obsolete endpoints and templates as each page moved also kept the migration incremental.

That is a good trade for a creator dashboard. It is an authenticated application surface, used repeatedly, where persistent navigation and straightforward Rails ownership matter more than search metadata or a fully rendered first document. Nothing in our experiment changes that conclusion. [Our own positioning starts from the same premise](../positioning-notes.md): Inertia is excellent for many Rails pages, and ignoring its strengths would make a comparison ideological rather than practical.

## The backend thesis continues

The most useful sentence in Gumroad's article is also the bridge to our experiment:

> "we already had the right architecture on the backend. We just needed a better way to deliver it to the frontend."

React Server Components ask the same question one step later. If the server already owns routing and data, how much of the React tree can it also resolve before the browser takes over? That does not invalidate the Inertia answer. It identifies another answer for pages with different constraints.

The distinction matters because dashboards and public buyer pages have different jobs. A dashboard benefits from warm caches, repeat visits, and persistent application state. A public product or marketplace page often meets a new visitor on an uncertain network. The initial document, metadata, and amount of client work can affect discovery and conversion. Our lab therefore measures a different class of page: logged-out Product and Discover surfaces, not the creator workflow that motivated most of Gumroad's migration. [That is the boundary the repository was designed to test](../positioning-notes.md#messaging-hypothesis).

Gumroad simplified its stack partly by removing server rendering. For the dashboard, that can be the right exchange. For a public surface, it may exchange away useful initial rendering. The decision is not "Inertia or server ownership." Both approaches keep Rails in charge. The decision is how Rails delivers the result and how much work remains for the browser.

## Looking more closely at "two pipelines"

The old server bundle and `mini_racer` setup imposed real operational cost. But two rendering pipelines are not uniquely a React on Rails tax. They are a cost of choosing server rendering for React.

[Inertia's own SSR path](https://inertiajs.com/server-side-rendering) introduces a separate Node server and a separately built SSR bundle, conventionally `ssr.js`. [Our positioning notes call out that Node-based Inertia SSR architecture explicitly](../positioning-notes.md#2-inertia-extension-that-uses-a-node-rendering-server). If an Inertia application adds SSR after removing it, a second runtime and server build return. React Server Components through React on Rails Pro also require a Node renderer and distinct server and client assets. [The current lab documents those actual moving parts](../current-status.md#react-192--pro-17-status).

So the useful comparison is not a server-rendered RSC route against no extra process. It is one server-rendering design against another, asking what the additional process buys. In this lab, it buys server and client composition, streamed rendered output, and a smaller route-level JavaScript transfer. It also adds deployment, observability, and failure modes that a client-rendered Inertia page does not have.

## The page data has two representations

On an initial Inertia response, Rails serializes the page props as JSON in the document's `data-page` attribute. The browser then uses those props to construct the React DOM. The payload and the rendered interface are separate representations of the same page data. This is easy to verify without a benchmark: open an Inertia page, inspect its root element, and look at `data-page`.

In the deployed lab, the Product control carried [`15,040 B`](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) in that attribute, while Discover carried [`33,966 B`](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). The RSC candidates had no Inertia `data-page` payload. Instead, the initial response carried rendered HTML plus the inline RSC stream used by the React runtime. [The repository documents that delivery shape](../current-status.md#react-192--pro-17-status). This is an architectural difference, but the byte totals below are properties of these particular pages and fixtures, not universal constants.

## What the deployed lab measured

The canonical run was captured on [July 10, 2026](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). It used [two independent batches of eight alternating cycles per route pair, two warmups before each measured run, and sixteen samples per route](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). The table reports Inertia control to RSC candidate:

| Surface | Median navigation | Median response end | Median LCP | Encoded HTML body | JavaScript transfer | Inertia `data-page` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Product | [`1123.5ms` to `575.0ms` (`-48.8%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`504.85ms` to `509.55ms` (`+0.9%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`662ms` to `602ms` (`-9.1%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`6,426 B` to `11,590.5 B` (`+80.4%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`162,696 B` to `82,228.5 B` (`-49.5%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`15,040 B` to none](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) |
| Discover | [`1097.9ms` to `630.45ms` (`-42.6%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`473.9ms` to `492.8ms` (`+4.0%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`768ms` to `648ms` (`-15.6%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`9,780 B` to `19,580 B` (`+100.2%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`162,696 B` to `82,223 B` (`-49.5%`)](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) | [`33,966 B` to none](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) |

The strongest result is full-navigation duration. Product LCP improved modestly. Discover LCP moved in the same direction but was noisier: [two of sixteen paired cycles regressed, and its batch medians differed materially](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). Response end is not an RSC win. It was slightly later for both candidates. RSC also sent substantially more HTML, even as JavaScript transfer fell by about half.

The causal limit belongs beside those results. This is a valid end-to-end comparison of the deployed routes, not an estimate of RSC alone. The RSC route intentionally skips the legacy application bundle and uses an isolated client bundle. The Inertia route also loads analytics and tag-manager scripts that the RSC route omits. Bundle isolation is part of the architecture under test, but third-party omission is a parity gap. [The benchmark contract forbids attributing the result solely to RSC](../rsc-lab-benchmark-contract-v1.md#status-and-supported-claim).

The fixtures are synthetic. Product loads [five small SVGs totaling about `11 KB`](../current-status.md#live-gumroad-parity-audit), while sampled live Product pages transferred roughly [`2.3-3.2 MB`](../current-status.md#live-gumroad-parity-audit) of mixed media. Discover uses [eight unique SVGs totaling about `17 KB`](../current-status.md#live-gumroad-parity-audit), while sampled live Discover pages transferred roughly [`11-16 MB` across about `100` image requests](../current-status.md#live-gumroad-parity-audit). Those are orders of magnitude apart.

The run used [unthrottled desktop headless Chrome on a public network](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json). It is not a mobile result and not field data. A transient [`503`](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) occurred while the deployment woke before the media gate passed. The harness also opened the shared host root before each target, warming the connection and common resources equally but making the visit less than fully cold. These limitations narrow the claim. They do not erase the observed route difference.

## Real product-page run

<!-- PENDING: real-product-page run, numbers land separately -->

This run uses a real product-page implementation rather than the matched synthetic pair. It matters more because real media, chrome, application code, caching, and third parties determine whether the laboratory advantage survives production shape. Its results will be reported separately rather than folded back into the canonical lab artifact.

## What adopting this route costs

The candidate is not a configuration switch. It requires [React 19](../current-status.md#react-192--pro-17-status), a Shakapacker and Rspack build path instead of Gumroad's Vite path, a separately operated Node renderer, and a commercial React on Rails Pro license. Rspack is supporting build infrastructure, not the explanation for the runtime result. [The repository makes that distinction explicit](../positioning-notes.md#3-shakapacker-and-rspack-positioning), and its deployment guide records the [license and renderer secrets](../control-plane-deployment.md).

That means adoption should be selective. A team has to price the React upgrade, asset-pipeline change, renderer capacity and monitoring, fallback behavior, and license against the value of the public surface. The dashboard case may still favor Inertia's simpler client-rendered model. The public Product or Discover case may justify the extra machinery if the measured reduction in browser work persists under production parity.

## A reproducible choice, not a migration demand

This repository is public, the [benchmark contract](../rsc-lab-benchmark-contract-v1.md) defines what the result can support, and the [canonical artifact](../performance-artifacts/deployed-stable-media-public-buyer-pages-2026-07-10/summary.json) exposes the method and caveats with the numbers. The Inertia routes remain the control, a practical architecture for many pages, and a fallback while the RSC path is tested.

Gumroad's migration solved the problems it set out to solve. Our experiment continues its backend-first reasoning on a different class of page. The remaining question is empirical: whether the extra server-rendering machinery earns its place once the comparison includes real product media, matched third parties, mobile conditions, and production traffic.
