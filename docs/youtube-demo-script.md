# YouTube Demo Script

## Goal

Show one honest claim:

- a bounded React Server Components via React on Rails Pro surface can beat a matched `Inertia` control on user-visible metrics

Do not claim:

- a universal RSC win
- that the full dashboard is already faster
- that `Rspack` is responsible for the route-level runtime gain
- that the current Lighthouse fallback replaces PageSpeed API or field-data proof

## Suggested video length

- short version: `90` to `120` seconds
- full version: `4` to `6` minutes

## Recording setup

- open the VP Engineering summary at `https://gumroad.reactonrails.com/rsc-demo`
- have the detailed logged-out lab at `https://gumroad.reactonrails.com/rsc-demo/evidence` open in another tab
- have [docs/public-buyer-page-performance-results.md](./public-buyer-page-performance-results.md) open in another tab
- keep the repo README open in another tab
- optionally keep the product and Discover route pairs open in separate tabs

## Short version script

### Opening

```text
This is a Gumroad public-page rendering experiment from ShakaCode.
The question is simple: can React on Rails Pro plus React Server Components make buyer-facing product and Discover pages faster than a matched Inertia control enough to justify the extra complexity?
```

### Show the control

```text
This route is the control: `/public_product/discover_inertia_demo`.
It uses the same synthetic production-shaped Discover fixture as the experiment route.
```

### Show the RSC route

```text
This route is the experiment: `/public_product/discover_rsc_demo`.
Same public marketplace data, different rendering model.
```

### State the measured result

```text
On the current stable media-bearing ShakaPerf run, the Discover RSC route cuts combined-median navigation duration from about 1098ms to 630ms.
The product detail route shows a larger win: about 1124ms to 575ms combined-median navigation duration.
The same run keeps the direction honest: JavaScript requests drop from nine to one, while response-end is about the same on Product and inconclusive on Discover.
The PageSpeed links are still useful, but the current live-versus-demo Lighthouse fallback is diagnostic only because the pages did not load equivalent media and production chrome.
That is not a universal win, but it is a real buyer-page win on bounded public surfaces.
```

### Close

```text
That makes this interesting for product positioning and for a narrow upstream discussion.
The next honest proof gates are defining production parity, validating mobile-throttled behavior, and rerunning after React on Rails Pro 17.0.0 final. PageSpeed or field-data corroboration still requires documented media, chrome, CDN, cache, and third-party parity, especially for INP.
```

## Full version script

### 1. Frame the problem

```text
We are not trying to prove that every Inertia page should be replaced.
We are trying to identify whether some read-heavy Rails surfaces cross the line where a richer React rendering model becomes worth it.
```

### 2. Show the repo

```text
This repo tracks Gumroad and keeps the work bounded:
first a public product page, then a public Discover page, each with a matched Inertia control and React Server Components route.
That keeps the review surface understandable and focused on buyer-page performance.
```

### 3. Show the two routes

```text
Here is the Inertia control route.
Here is the RSC experiment route.
Both use the same production-shaped synthetic fixture, so we are measuring rendering architecture rather than content differences.
```

### 4. Explain the actual result

```text
Both public RSC routes win on combined-median navigation duration in the stable media-bearing run, and route JavaScript requests drop from nine to one.
Product detail improves median LCP from 662ms to 602ms; Discover improves from 768ms to 648ms, with more run-to-run noise.
The tradeoff is a larger encoded HTML body. Response-end is about the same on Product and inconclusive on Discover, not an RSC win.
```

### 5. Separate the two stories

```text
Rspack is the build-speed and dev-loop story.
RSC is the route-level runtime story.
If we blur those together, we weaken both claims.
```

### 6. Show the docs

```text
The repo includes the current status, the hosted public buyer-page results, the public performance evaluation notes, and the positioning notes.
So this is not just a demo branch.
It is meant to help decide what should be positioned, what should be optimized next, and what should never be over-claimed.
```

### 7. Close with the honest ask

```text
If PageSpeed API or field data corroborates the media-bearing same-fixture result after production-equivalent media and CDN parity, especially for INP, this becomes a credible Gumroad-facing proposal.
If not, it is still valuable because it tells us where the tradeoff actually lives.
```

## Shot list

1. README top section with the hosted public result
2. `/rsc-demo`
3. `/rsc-demo/evidence#current-shakaperf-result`
4. `/public_product/discover_inertia_demo`
5. `/public_product/discover_rsc_demo`
6. `docs/public-buyer-page-performance-results.md` metrics table
7. `docs/current-status.md` short answer and current result
8. optional PR stack view on GitHub

## Good phrases to use

- `bounded comparison surface`
- `matched Inertia control`
- `public buyer-page win`
- `reduced client JavaScript`
- `mobile proof gate`
- `promising, not universal`

## Phrases to avoid

- `RSC is obviously better`
- `Inertia is obsolete`
- `this proves Gumroad should migrate`
- `Rspack made the page faster`
