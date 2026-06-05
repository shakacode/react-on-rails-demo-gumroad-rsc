# Gumroad RSC Comparison Plan

## Goal

Build a credible comparison between:

- Gumroad as it exists today on Inertia
- A targeted React on Rails Pro + React 19 + RSC implementation

The comparison should answer one question clearly:

Would React on Rails Pro be meaningfully better for public, buyer-facing Gumroad pages where initial rendering quality can affect SEO and conversion?

## Non-goals

- Do not try to prove that Inertia should be removed from the whole app.
- Do not file upstream issues or open upstream PRs until the experiment is working and measured.
- Do not start by porting large parts of the application blindly.

## Working Hypothesis

React on Rails Pro is most likely to be competitive on pages that are:

- data-heavy
- highly interactive
- already naturally componentized in React
- good candidates for React 19 features and server/client composition
- public enough that initial HTML, metadata, and client JavaScript cost affect discovery or conversion

Important distinction:

- `Rspack` is the build-time and developer-experience lever
- `RSC` is the route-runtime lever

It is less likely to be competitive on simple CRUD-style Rails pages where Inertia already fits well, or on logged-in administrative pages where SEO is irrelevant.

## Success Criteria

The experiment is successful only if it produces evidence in at least one of these areas:

- better perceived loading behavior
- smaller client-side JavaScript for the chosen page
- clearer server/client composition
- easier reuse of React code between server and client concerns
- materially better developer ergonomics for complex UI work

The existing `Dashboard` comparison is a useful technical proof that the stack can run, isolate assets, and be measured inside Gumroad. It should not be treated as the main value proof because logged-in dashboard pages do not test SEO, share previews, or buyer conversion.

The main product proof is now the public product-like route pair:

- `Inertia` control: `/public_product/inertia_demo`
- `React on Rails Pro + RSC` demo: `/public_product/rsc_demo`

The experiment fails if the React on Rails Pro path mostly adds complexity without a measurable payoff.

## Proposed Execution Order

1. Establish an Inertia baseline on current upstream Gumroad.
2. Pick one comparison surface.
3. Upgrade the bundling/tooling path needed for the experiment.
4. Capture route metrics from that Inertia baseline so the runtime bar is explicit.
5. Add React on Rails Pro and React 19 only where required.
6. Add an RSC proof of concept for the selected surface.
7. Measure and document the tradeoffs honestly.

## Candidate Comparison Surfaces

### Best initial candidates

- `Products/Edit`
- `Dashboard`
- `Checkout/Show`
- `Settings/Payments/Show`

### Selection criteria

- the page is important enough to matter
- the UI is complex enough to justify React specialization
- the page has meaningful server/client boundaries
- the comparison can be isolated without rewriting half the app

## Recommended First Target

The first technical target was `Dashboard`.

The next value target should be a logged-out public product page.

Reasoning:

- `Products/Edit` is the strongest test of complex client-side React workflows.
- `Dashboard` is the stronger test for streaming, server/client composition, and RSC-style data boundaries.

Because this repository is explicitly centered on React 19 and RSC, `Dashboard` was a practical first proof target. Because the business case is SEO and conversion, the public product page is the better proof-of-value target.

## Branch Strategy

- `main`: upstream tracking plus experiment documentation
- `jg-codex/baseline-metrics`: capture baseline behavior and measurements
- `jg-codex/shakapacker-upgrade`: upgrade the asset pipeline as needed
- `jg-codex/rspack-migration`: migrate off webpack if justified
- `jg-codex/react-on-rails-pro-poc`: add React on Rails Pro for the selected surface
- `jg-codex/rsc-poc`: add the final RSC experiment

## Decision Rule Before Going Upstream

Do not take this upstream unless the experiment can show:

- a clearly bounded use case
- a realistic adoption path
- objective wins or a very strong qualitative improvement
- acceptable maintenance overhead

For the first runtime pitch, "objective wins" should mean that the `React on Rails Pro + RSC` public product route beats the matched Inertia public product route on client JS cost, initial product HTML or metadata quality, and at least one user-facing load metric.

Without that, this should remain a ShakaCode experiment repo rather than an upstream proposal.
