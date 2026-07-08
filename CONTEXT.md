# Gumroad RSC Demo

This context describes the public buyer-page performance demo used to compare Gumroad's current public rendering path with React Server Components via React on Rails Pro.

## Language

**Public Buyer Page**:
A logged-out Gumroad page whose first render can affect marketplace browsing, SEO, share previews, or purchase intent.
_Avoid_: dashboard page, seller admin page

**Product Detail Route Pair**:
The matched public product-page comparison between the Inertia control and the RSC candidate.
_Avoid_: product migration, checkout flow

**Discover Marketplace Route Pair**:
The matched public Discover-page comparison between the Inertia control and the RSC candidate.
_Avoid_: dashboard comparison, search API benchmark

**Inertia Control**:
The benchmark route that represents Gumroad's current Inertia-style public page rendering for the same fixture data.
_Avoid_: legacy route, production Gumroad route

**RSC Candidate**:
The benchmark route that renders the same fixture data through React Server Components via React on Rails Pro.
_Avoid_: Rspack candidate, cached route

**Matched Fixture**:
Synthetic but production-shaped public-page data shared by both sides of a route pair.
_Avoid_: scraped content, real creator content

**Static RSC Cache Variant**:
A future benchmark variant for cacheable public RSC pages that should be measured separately from the uncached matched route pair.
_Avoid_: headline RSC candidate

**Live Gumroad Comparator**:
A public gumroad.com page used as an external reference for real-world layout, content density, and PageSpeed/ShakaPerf comparison.
_Avoid_: matched fixture, Inertia control

**Attributed Live Fixture**:
A demo fixture adapted from a public Gumroad page with source attribution and light wording changes so the comparison remains understandable without presenting creator content as original demo copy.
_Avoid_: scraped clone, anonymous synthetic fixture

**Initial Product Comparator**:
The first approved public Gumroad product source used to build an Attributed Live Fixture for product-page evidence.
_Avoid_: arbitrary product, anonymous product

**Fixture Identity Policy**:
The rule that an Attributed Live Fixture preserves the source title, seller, price, type, rating summary, and source link while lightly rewriting long descriptive and supporting copy.
_Avoid_: full rename, copied body copy

**Gumroad Issue Evidence Pack**:
The complete proof bundle needed before opening an upstream Gumroad issue or PR proposal.
_Avoid_: demo PR, benchmark note

**Reproducible Evidence Artifact**:
A committed benchmark result plus documented commands, source URLs, environment details, and rerun links so another evaluator can reproduce the claim.
_Avoid_: one-off screenshot, trust-me benchmark

**PageSpeed Comparator Pair**:
A pair of public URLs submitted to PageSpeed/Lighthouse-style tooling: one React on Rails RSC demo URL and one live gumroad.com comparator URL for the same buyer-page surface.
_Avoid_: repo comparison, unmatched route pair

**Controlled A/B Proof**:
Same-machine benchmark evidence comparing an Inertia Control and RSC Candidate that share the same fixture and route shape.
_Avoid_: live site comparison, PageSpeed comparator

## Relationships

- A **Public Buyer Page** may be represented by a **Product Detail Route Pair** or a **Discover Marketplace Route Pair**.
- Each route pair has exactly one **Inertia Control** and one **RSC Candidate**.
- The **Inertia Control** and **RSC Candidate** in a route pair share the same **Matched Fixture**.
- A **Static RSC Cache Variant** may reuse a **Matched Fixture**, but it is not the same benchmark claim as the headline **RSC Candidate**.
- A **Live Gumroad Comparator** is not part of a matched route pair; it anchors external reality and competitor-style PageSpeed comparisons.
- An **Attributed Live Fixture** can make a matched route pair more persuasive by staying close to a real public source while linking back to it.
- The approved **Initial Product Comparator** is Tendon Book by Jacked Athlete.
- The **Fixture Identity Policy** applies to the Initial Product Comparator.
- A **Gumroad Issue Evidence Pack** includes Reproducible Evidence Artifacts, matched route-pair data, Live Gumroad Comparator data, screenshots, source links, and a scoped upstream proposal.
- A **PageSpeed Comparator Pair** compares sites by URL, not repositories.
- **Controlled A/B Proof** supports the architecture claim; **PageSpeed Comparator Pairs** support the external public-site credibility claim.

## Example Dialogue

> **Dev:** "Should we turn on static RSC caching for the product route and call that the RSC result?"
> **Domain expert:** "No — keep the headline route pair matched and uncached. Add a separate Static RSC Cache Variant if we want to measure public-page caching."

> **Dev:** "Can we compare our synthetic route directly against gumroad.com/discover?"
> **Domain expert:** "Yes, but call that a Live Gumroad Comparator. It is persuasive external evidence, not the same-data benchmark."

> **Dev:** "Can we use a real Gumroad product as the demo fixture?"
> **Domain expert:** "Yes, if it is an Attributed Live Fixture: link to the source and adjust the wording so users understand it is a reference, not copied demo-owned content."

> **Dev:** "Should the lab just link to PageSpeed and ShakaPerf?"
> **Domain expert:** "No — include rerun links, but also commit a Reproducible Evidence Artifact with the exact method and measured results."

> **Dev:** "Can PageSpeed compare the two repos?"
> **Domain expert:** "PageSpeed compares public URLs. Use PageSpeed Comparator Pairs: our hosted RSC demo URL versus the live gumroad.com URL for the same surface."

## Flagged Ambiguities

- "RFC demo" was used in the request, but this repo and codebase consistently define the surface as the **RSC Candidate** and related RSC demo routes.
- "current site" can mean the hosted React on Rails RSC demo or the live gumroad.com product/Discover pages; use **RSC Candidate** for the demo and **Live Gumroad Comparator** for gumroad.com.
- "two repos" was used when discussing PageSpeed, but the benchmark target is really two public sites/URLs.
