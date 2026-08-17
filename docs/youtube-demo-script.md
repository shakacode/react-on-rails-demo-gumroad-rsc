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
The current ShakaPerf CLI run measures two native product pages under mobile Lighthouse.
FCP falls from about 7.7 seconds to 1.85 seconds on both. LCP improves 74 percent on Microsoft 365 and 49 percent on Residential Design, while JavaScript requests fall from 41 to 3.
The costs stay on screen: downloads grow 56 and 36 percent, JavaScript transfer grows 206 percent, TTFB regresses, and Microsoft TBT moves from zero to 199 milliseconds.
The command exits failed with two performance regressions. This proves faster paint on these route pairs, not that RSC is better overall.
```

### Close

```text
That makes this interesting for product positioning and for a narrow upstream discussion.
The next honest proof gates are reducing payload and TTFB, restoring production parity, rerunning the exact product pairs, and collecting field data.
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
Both native product RSC routes paint materially faster in the current ShakaPerf run, and JavaScript requests drop from 41 to 3.
Microsoft 365 LCP moves from 13.92 seconds to 3.64; Residential Design moves from 16.88 to 8.63.
The tradeoff is heavier delivery and slower TTFB. The suite fails two performance gates, so the decision is pilot, not rollout.
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
If field data corroborates the paint result after production-equivalent media, analytics, bundles, and CDN parity—and the payload regressions are fixed or accepted—this becomes a credible Gumroad-facing proposal.
If not, it is still valuable because it tells us where the tradeoff actually lives.
```

## Shot list

1. README top section with the hosted public result
2. `/rsc-demo`
3. `/rsc-demo/evidence#native-shakaperf-result`
4. `/public_product/discover_inertia_demo`
5. `/public_product/discover_rsc_demo`
6. `docs/public-buyer-page-performance-results.md` metrics table
7. `docs/current-status.md` short answer and current result
8. optional PR stack view on GitHub

## Good phrases to use

- `bounded comparison surface`
- `matched Inertia control`
- `faster paint, heavier payload`
- `fewer JavaScript requests`
- `failed suite, bounded pilot`
- `promising, not universal`

## Phrases to avoid

- `RSC is obviously better`
- `Inertia is obsolete`
- `this proves Gumroad should migrate`
- `Rspack made the page faster`
