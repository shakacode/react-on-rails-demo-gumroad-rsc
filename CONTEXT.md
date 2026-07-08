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

## Relationships

- A **Public Buyer Page** may be represented by a **Product Detail Route Pair** or a **Discover Marketplace Route Pair**.
- Each route pair has exactly one **Inertia Control** and one **RSC Candidate**.
- The **Inertia Control** and **RSC Candidate** in a route pair share the same **Matched Fixture**.
- A **Static RSC Cache Variant** may reuse a **Matched Fixture**, but it is not the same benchmark claim as the headline **RSC Candidate**.

## Example Dialogue

> **Dev:** "Should we turn on static RSC caching for the product route and call that the RSC result?"
> **Domain expert:** "No — keep the headline route pair matched and uncached. Add a separate Static RSC Cache Variant if we want to measure public-page caching."

## Flagged Ambiguities

- "RFC demo" was used in the request, but this repo and codebase consistently define the surface as the **RSC Candidate** and related RSC demo routes.
