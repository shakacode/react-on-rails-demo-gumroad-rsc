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

**Gumroad Issue Evidence Pack**:
The complete proof bundle needed before opening an upstream Gumroad issue or PR proposal.
_Avoid_: demo PR, benchmark note

## Relationships

- A **Public Buyer Page** may be represented by a **Product Detail Route Pair** or a **Discover Marketplace Route Pair**.
- Each route pair has exactly one **Inertia Control** and one **RSC Candidate**.
- The **Inertia Control** and **RSC Candidate** in a route pair share the same **Matched Fixture**.
- A **Static RSC Cache Variant** may reuse a **Matched Fixture**, but it is not the same benchmark claim as the headline **RSC Candidate**.
- A **Live Gumroad Comparator** is not part of a matched route pair; it anchors external reality and competitor-style PageSpeed comparisons.
- A **Gumroad Issue Evidence Pack** may include matched route-pair data, Live Gumroad Comparator data, screenshots, source links, and a scoped upstream proposal.

## Example Dialogue

> **Dev:** "Should we turn on static RSC caching for the product route and call that the RSC result?"
> **Domain expert:** "No — keep the headline route pair matched and uncached. Add a separate Static RSC Cache Variant if we want to measure public-page caching."

> **Dev:** "Can we compare our synthetic route directly against gumroad.com/discover?"
> **Domain expert:** "Yes, but call that a Live Gumroad Comparator. It is persuasive external evidence, not the same-data benchmark."

## Flagged Ambiguities

- "RFC demo" was used in the request, but this repo and codebase consistently define the surface as the **RSC Candidate** and related RSC demo routes.
- "current site" can mean the hosted React on Rails RSC demo or the live gumroad.com product/Discover pages; use **RSC Candidate** for the demo and **Live Gumroad Comparator** for gumroad.com.
