import * as React from "react";

import { type CurrencyCode, formatPriceCentsWithCurrencySymbol } from "$app/utils/currency";

type PublicProductSeller = {
  avatar_url?: string | null;
  is_verified?: boolean;
  name: string;
  profile_url?: string | null;
};

type PublicProductAttribute = {
  name?: string | null;
  value?: string | null;
};

type PublicProductFile = {
  description?: string | null;
  extension?: string | null;
  filetype?: string | null;
  name?: string | null;
};

type PublicProductRatings = {
  average?: number | null;
  count?: number | null;
};

type PublicProductProps = {
  attributes?: PublicProductAttribute[];
  currency_code: CurrencyCode;
  description_html?: string | null;
  long_url: string;
  name: string;
  permalink: string;
  price_cents: number;
  public_files?: PublicProductFile[];
  purchase_url: string;
  ratings?: PublicProductRatings | null;
  seller: PublicProductSeller;
  summary?: string | null;
};

type PublicProductComparisonLinks = {
  control_url: string;
  inertia_url: string;
  rsc_url: string;
};

export type PublicProductComparisonPageProps = {
  comparison: PublicProductComparisonLinks;
  locale: string;
  product: PublicProductProps;
};

type PublicProductComparisonVariant = "inertia" | "rsc";

type Props = PublicProductComparisonPageProps & {
  variant: PublicProductComparisonVariant;
};

const formatPrice = (currencyCode: CurrencyCode, priceCents: number) =>
  priceCents === 0
    ? "Free"
    : formatPriceCentsWithCurrencySymbol(currencyCode, priceCents, { symbolFormat: "short", noCentsIfWhole: true });

const variantCopy = {
  inertia: {
    titleSuffix: "Inertia public product demo",
    subtitle: "Public product Inertia control",
    lead: "Client-rendered comparison route for a logged-out product landing page.",
    compareLabel: "Open RSC demo",
  },
  rsc: {
    titleSuffix: "React on Rails Pro + RSC public product demo",
    subtitle: "Public product RSC candidate",
    lead: "Server-rendered product facts, story, and conversion framing before client-side checkout islands.",
    compareLabel: "Open Inertia demo",
  },
} satisfies Record<
  PublicProductComparisonVariant,
  {
    compareLabel: string;
    lead: string;
    subtitle: string;
    titleSuffix: string;
  }
>;

const hasText = (value?: string | null) => value != null && value.trim() !== "";

const ProductNav = ({
  comparison,
  currentView,
}: {
  comparison: PublicProductComparisonLinks;
  currentView: PublicProductComparisonVariant;
}) => {
  const links = [
    { href: comparison.control_url, label: "Current product page", view: null },
    { href: comparison.inertia_url, label: "Inertia demo", view: "inertia" },
    { href: comparison.rsc_url, label: "RSC demo", view: "rsc" },
  ];

  return (
    <nav className="dd-nav" aria-label="Public product comparison routes">
      {links.map((link) => (
        <a key={link.label} href={link.href} aria-current={link.view === currentView ? "page" : undefined}>
          {link.label}
        </a>
      ))}
    </nav>
  );
};

const TrustSignals = ({ locale, product }: { locale: string; product: PublicProductProps }) => {
  const hasReviewSignal =
    product.ratings?.average != null && product.ratings.count != null && product.ratings.count > 0;
  const formattedRating = hasReviewSignal
    ? `${product.ratings.average.toLocaleString(locale, { maximumFractionDigits: 1 })} from ${product.ratings.count.toLocaleString(locale)} reviews`
    : "Product facts rendered in initial HTML";
  const attributes =
    product.attributes?.filter((attribute) => hasText(attribute.name) || hasText(attribute.value)) ?? [];
  const publicFiles = product.public_files?.filter((file) => hasText(file.name) || hasText(file.filetype)) ?? [];

  return (
    <section className="dd-section">
      <header>
        <h2>Buyer confidence</h2>
        <p>Static purchase context that should be present before hydration on public conversion pages.</p>
      </header>

      <div className="dd-metrics">
        <article>
          <p>Price</p>
          <strong>{formatPrice(product.currency_code, product.price_cents)}</strong>
        </article>
        <article>
          <p>Creator</p>
          <strong>{product.seller.name}</strong>
        </article>
        <article>
          <p>Review signal</p>
          <strong>{formattedRating}</strong>
        </article>
        <article>
          <p>Permalink</p>
          <strong>/l/{product.permalink}</strong>
        </article>
      </div>

      {attributes.length || publicFiles.length ? (
        <div className="dd-list">
          {attributes.map((attribute, index) => (
            <article key={`${attribute.name}-${attribute.value}-${index}`} className="dd-row">
              <p className="dd-copy">
                <strong>{attribute.name || "Product detail"}:</strong> {attribute.value || "Included"}
              </p>
            </article>
          ))}
          {publicFiles.map((file, index) => (
            <article key={`${file.name}-${file.filetype}-${index}`} className="dd-row">
              <p className="dd-copy">
                <strong>{file.name || "Public file"}</strong>
                {file.description ? <>: {file.description}</> : null}
              </p>
            </article>
          ))}
        </div>
      ) : null}
    </section>
  );
};

export default function PublicProductComparisonPage({ comparison, locale, product, variant }: Props) {
  const copy = variantCopy[variant];
  const compareHref = variant === "inertia" ? comparison.rsc_url : comparison.inertia_url;

  return (
    <div className="dd">
      <aside className="dd-side">
        <div className="dd-brand">
          <a href={comparison.control_url}>Gumroad</a>
          <p>{copy.subtitle}</p>
        </div>

        <ProductNav comparison={comparison} currentView={variant} />

        <footer className="dd-meta">
          <strong>{product.seller.name}</strong>
          <p>Logged-out public product comparison</p>
        </footer>
      </aside>

      <main className="dd-main">
        <header className="dd-header">
          <div>
            <p className="dd-eyebrow">{copy.titleSuffix}</p>
            <h1>{product.name}</h1>
            <p>{copy.lead}</p>
          </div>

          <div className="dd-actions">
            <a href={compareHref} className="dd-btn">
              {copy.compareLabel}
            </a>
            <a href={product.purchase_url} className="dd-btn">
              Open current product page
            </a>
          </div>
        </header>

        <div className="dd-body">
          <p className="dd-note">
            This route is intentionally logged-out and public. It focuses the RSC comparison on crawlable product
            content, buyer-facing copy, and conversion context rather than seller dashboard widgets.
          </p>

          <section className="dd-section">
            <header>
              <h2>Product story</h2>
              <p>{product.summary || "Public product copy rendered in the initial document."}</p>
            </header>

            {hasText(product.description_html) ? (
              <div
                className="dd-empty dd-rich-text"
                dangerouslySetInnerHTML={{ __html: product.description_html ?? "" }}
              />
            ) : (
              <div className="dd-empty">
                <p>No product description has been configured for this demo product.</p>
              </div>
            )}
          </section>

          <TrustSignals locale={locale} product={product} />

          <section className="dd-section">
            <header>
              <h2>What the benchmark should prove</h2>
              <p>RSC only matters here if the public product route gets better enough to justify the complexity.</p>
            </header>
            <div className="dd-list">
              <article className="dd-row">
                <p className="dd-copy">
                  <strong>SEO:</strong> product title, creator, description, price, and CTA context are present before
                  JavaScript.
                </p>
              </article>
              <article className="dd-row">
                <p className="dd-copy">
                  <strong>Conversion:</strong> above-the-fold buyer context is available before the interactive checkout
                  path hydrates.
                </p>
              </article>
              <article className="dd-row">
                <p className="dd-copy">
                  <strong>Performance:</strong> compare response timing, LCP, JS transfer, and page-specific client work
                  against the matched Inertia route.
                </p>
              </article>
            </div>
          </section>
        </div>
      </main>
    </div>
  );
}
