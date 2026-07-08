import * as React from "react";

import { type CurrencyCode, formatPriceCentsWithCurrencySymbol } from "$app/utils/currency";

type BenchmarkVariant = "inertia" | "rsc";
type BenchmarkPageKind = "discover" | "product";

type Seller = {
  avatar_initials: string;
  followers_count?: number;
  id?: string;
  is_verified?: boolean;
  name: string;
  tagline?: string;
};

type Ratings = {
  average: number;
  count: number;
  percentages?: number[];
};

type Theme = {
  accent: string;
  end: string;
  start: string;
};

type CoverStyle = React.CSSProperties & {
  "--dd-cover-accent": string;
  "--dd-cover-end": string;
  "--dd-cover-start": string;
};

type ProductCard = {
  currency_code: CurrencyCode;
  id: string;
  is_pay_what_you_want?: boolean;
  name: string;
  native_type: string;
  permalink: string;
  price_cents: number;
  ratings: Ratings;
  sales_count_label: string;
  seller: Seller;
  taxonomy: string;
  thumbnail_theme: Theme;
};

type ProductPage = {
  bullets: string[];
  call_to_action: string;
  cover_theme: Theme;
  currency_code: CurrencyCode;
  description_sections: { body: string; heading: string }[];
  faq: { answer: string; question: string }[];
  hero_stats: { label: string; value: string }[];
  included_files: { description: string; filetype: string; name: string }[];
  name: string;
  native_type: string;
  permalink: string;
  price_cents: number;
  ratings: Ratings;
  recommendations: ProductCard[];
  seller: Seller;
  source_label: string;
  source_url: string;
  summary: string;
};

type DiscoverPage = {
  active_creators: number;
  categories: { count: number; label: string; slug: string }[];
  currency_code: CurrencyCode;
  featured_collections: { description: string; title: string }[];
  filetypes_data: { doc_count: number; key: string }[];
  products: ProductCard[];
  subtitle: string;
  tags_data: { doc_count: number; key: string }[];
  title: string;
  total_products: number;
  weekly_sales_cents: number;
};

type ComparisonLinks = {
  consultation_url: string;
  discover_inertia_url: string;
  discover_rsc_url: string;
  gumroad_discover_reference_url: string;
  gumroad_product_reference_url: string;
  home_url: string;
  inertia_url: string;
  performance_url: string;
  product_inertia_url: string;
  product_rsc_url: string;
  react_on_rails_github_url: string;
  react_on_rails_url: string;
  rsc_url: string;
  shakacode_url: string;
};

export type PublicProductComparisonPageProps = {
  comparison: ComparisonLinks;
  discover_page: DiscoverPage | null;
  locale: string;
  product_page: ProductPage | null;
  source_note: string;
};

type Props = PublicProductComparisonPageProps & {
  pageKind: BenchmarkPageKind;
  variant: BenchmarkVariant;
};

const formatPrice = (currencyCode: CurrencyCode, priceCents: number) =>
  priceCents === 0
    ? "Free"
    : formatPriceCentsWithCurrencySymbol(currencyCode, priceCents, { symbolFormat: "short", noCentsIfWhole: true });

const formatNumber = (locale: string, value: number) => value.toLocaleString(locale, { maximumFractionDigits: 0 });

const formatRating = (locale: string, ratings: Ratings) =>
  `${ratings.average.toLocaleString(locale, { maximumFractionDigits: 1 })} (${formatNumber(locale, ratings.count)})`;

const coverStyle = (theme: Theme): CoverStyle => ({
  "--dd-cover-accent": theme.accent,
  "--dd-cover-end": theme.end,
  "--dd-cover-start": theme.start,
});

const variantCopy = {
  inertia: {
    badge: "Before: Inertia",
    compareLabel: "Open RSC route",
    lead: "Current-style route with a serialized Inertia page payload and client-rendered React surface.",
  },
  rsc: {
    badge: "After: React Server Components",
    compareLabel: "Open Inertia route",
    lead: "React Server Components via React on Rails Pro stream public page content from Rails before client islands hydrate.",
  },
} satisfies Record<BenchmarkVariant, { badge: string; compareLabel: string; lead: string }>;

const pageCopy = {
  discover: {
    label: "Discover marketplace fixture",
    navLabel: "Discover",
    proof: "SEO, browse latency, product-card payload, mobile LCP, and route JavaScript cost.",
  },
  product: {
    label: "Product detail fixture",
    navLabel: "Product",
    proof: "SEO, product storytelling, purchase framing, mobile LCP, and route JavaScript cost.",
  },
} satisfies Record<BenchmarkPageKind, { label: string; navLabel: string; proof: string }>;

const routeFor = (comparison: ComparisonLinks, pageKind: BenchmarkPageKind, variant: BenchmarkVariant) => {
  if (pageKind === "discover")
    return variant === "inertia" ? comparison.discover_inertia_url : comparison.discover_rsc_url;
  return variant === "inertia" ? comparison.product_inertia_url : comparison.product_rsc_url;
};

const BenchmarkNav = ({
  comparison,
  pageKind,
  variant,
}: {
  comparison: ComparisonLinks;
  pageKind: BenchmarkPageKind;
  variant: BenchmarkVariant;
}) => {
  const links = [
    { href: comparison.home_url, label: "Home" },
    { href: comparison.performance_url, label: "Performance lab" },
    { href: comparison.product_inertia_url, label: "Product Inertia", pageKind: "product", variant: "inertia" },
    { href: comparison.product_rsc_url, label: "Product RSC", pageKind: "product", variant: "rsc" },
    { href: comparison.discover_inertia_url, label: "Discover Inertia", pageKind: "discover", variant: "inertia" },
    { href: comparison.discover_rsc_url, label: "Discover RSC", pageKind: "discover", variant: "rsc" },
    { href: comparison.gumroad_product_reference_url, label: "Live Product", external: true },
    { href: comparison.gumroad_discover_reference_url, label: "Live Discover", external: true },
    { href: comparison.react_on_rails_url, label: "React on Rails", external: true },
    { href: comparison.shakacode_url, label: "ShakaCode", external: true },
  ] satisfies {
    external?: boolean;
    href: string;
    label: string;
    pageKind?: BenchmarkPageKind;
    variant?: BenchmarkVariant;
  }[];

  return (
    <nav className="dd-nav" aria-label="Public benchmark comparison routes">
      {links.map((link) => (
        <a
          key={link.label}
          href={link.href}
          aria-current={link.pageKind === pageKind && link.variant === variant ? "page" : undefined}
          rel={link.external ? "noreferrer" : undefined}
          target={link.external ? "_blank" : undefined}
        >
          {link.label}
        </a>
      ))}
    </nav>
  );
};

const ProductCardView = ({
  card,
  detailUrl,
  eager = false,
  locale,
}: {
  card: ProductCard;
  detailUrl: string;
  eager?: boolean;
  locale: string;
}) => (
  <a href={detailUrl} className="dd-product-card">
    <div className="dd-card-cover" style={coverStyle(card.thumbnail_theme)} aria-hidden="true">
      <span>{card.seller.avatar_initials}</span>
    </div>
    <div className="dd-card-body">
      <p className="dd-eyebrow">{card.native_type}</p>
      <h3>{card.name}</h3>
      <p>
        {card.seller.name}
        {card.seller.is_verified ? " - verified" : ""}
      </p>
      <div className="dd-card-meta">
        <strong>
          {card.is_pay_what_you_want ? "Pay what you want" : formatPrice(card.currency_code, card.price_cents)}
        </strong>
        <span>{formatRating(locale, card.ratings)}</span>
      </div>
      <div className="dd-chip-row">
        <span className="dd-chip">{card.taxonomy.replace(/-/gu, " ")}</span>
        <span className="dd-chip">{card.sales_count_label}</span>
        {eager ? <span className="dd-chip">above the fold</span> : null}
      </div>
    </div>
  </a>
);

const TrustBar = ({ locale, product }: { locale: string; product: ProductPage }) => (
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
      <p>Reviews</p>
      <strong>{formatRating(locale, product.ratings)}</strong>
    </article>
    <article>
      <p>Product type</p>
      <strong>{product.native_type}</strong>
    </article>
  </div>
);

const ProductDetailBenchmark = ({
  comparison,
  locale,
  product,
  variant,
}: {
  comparison: ComparisonLinks;
  locale: string;
  product: ProductPage;
  variant: BenchmarkVariant;
}) => {
  const detailUrl = routeFor(comparison, "product", variant);

  return (
    <div className="dd-body">
      <section className="dd-product-hero">
        <div className="dd-product-copy">
          <p className="dd-eyebrow">Attributed live product fixture</p>
          <h2>{product.name}</h2>
          <p>{product.summary}</p>

          <div className="dd-chip-row">
            {product.bullets.map((bullet) => (
              <span className="dd-chip" key={bullet}>
                {bullet}
              </span>
            ))}
          </div>
        </div>

        <div className="dd-product-media" style={coverStyle(product.cover_theme)}>
          <span>{product.seller.avatar_initials}</span>
          <strong>{product.name}</strong>
        </div>

        <aside className="dd-buy-card">
          <p className="dd-eyebrow">Buyer decision panel</p>
          <strong>{formatPrice(product.currency_code, product.price_cents)}</strong>
          <p>{product.seller.tagline}</p>
          <a href={comparison.performance_url} className="dd-btn">
            {product.call_to_action}
          </a>
          <a href={product.source_url} className="dd-btn" rel="noreferrer" target="_blank">
            Open live Gumroad source
          </a>
          <span>Demo CTA links to the lab, not a fake checkout.</span>
        </aside>
      </section>

      <TrustBar locale={locale} product={product} />

      <section className="dd-section">
        <header>
          <h2>Product story rendered before purchase intent</h2>
          <p>
            These mostly static details are the natural RSC target: high SEO value, high conversion value, low need for
            client state.
          </p>
        </header>
        <div className="dd-two-column">
          {product.description_sections.map((section) => (
            <article className="dd-panel" key={section.heading}>
              <h3>{section.heading}</h3>
              <p>{section.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="dd-section">
        <header>
          <h2>Included files and buyer confidence</h2>
          <p>The benchmark keeps purchase framing visible and realistic without linking to a real Gumroad checkout.</p>
        </header>
        <div className="dd-list">
          {product.included_files.map((file) => (
            <article className="dd-row" key={file.name}>
              <p className="dd-copy">
                <strong>{file.name}</strong>: {file.description}
              </p>
              <span className="dd-chip">{file.filetype}</span>
            </article>
          ))}
        </div>
      </section>

      <section className="dd-section">
        <header>
          <h2>Frequently asked questions</h2>
          <p>Longer static content makes the before/after payload and hydration tradeoff easier to see.</p>
        </header>
        <div className="dd-two-column">
          {product.faq.map((item) => (
            <article className="dd-panel" key={item.question}>
              <h3>{item.question}</h3>
              <p>{item.answer}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="dd-section">
        <header>
          <h2>Recommended products</h2>
          <p>
            Real product pages often continue into browse/recommendation surfaces, so the fixture includes realistic
            card density.
          </p>
        </header>
        <div className="dd-card-grid">
          {product.recommendations.map((card, index) => (
            <ProductCardView card={card} detailUrl={detailUrl} eager={index < 4} key={card.id} locale={locale} />
          ))}
        </div>
      </section>
    </div>
  );
};

const DiscoverBenchmark = ({
  comparison,
  discover,
  locale,
  variant,
}: {
  comparison: ComparisonLinks;
  discover: DiscoverPage;
  locale: string;
  variant: BenchmarkVariant;
}) => {
  const detailUrl = routeFor(comparison, "product", variant);

  return (
    <div className="dd-body">
      <section className="dd-discover-hero">
        <div>
          <p className="dd-eyebrow">Synthetic Discover listing</p>
          <h2>{discover.title}</h2>
          <p>{discover.subtitle}</p>
          <div className="dd-chip-row">
            {discover.tags_data.slice(0, 6).map((tag) => (
              <span className="dd-chip" key={tag.key}>
                {tag.key} ({formatNumber(locale, tag.doc_count)})
              </span>
            ))}
          </div>
        </div>
        <div className="dd-metrics dd-discover-metrics">
          <article>
            <p>Products</p>
            <strong>{formatNumber(locale, discover.total_products)}</strong>
          </article>
          <article>
            <p>Creators</p>
            <strong>{formatNumber(locale, discover.active_creators)}</strong>
          </article>
          <article>
            <p>Weekly sales</p>
            <strong>{formatPrice(discover.currency_code, discover.weekly_sales_cents)}</strong>
          </article>
        </div>
      </section>

      <section className="dd-section">
        <header>
          <h2>Marketplace categories</h2>
          <p>
            Public Discover pages carry category and filter context that should not require unnecessary client work.
          </p>
        </header>
        <div className="dd-category-grid">
          {discover.categories.map((category) => (
            <article className="dd-panel" key={category.slug}>
              <h3>{category.label}</h3>
              <p>{formatNumber(locale, category.count)} synthetic products</p>
            </article>
          ))}
        </div>
      </section>

      <section className="dd-section">
        <header>
          <h2>Featured collections</h2>
          <p>These cards represent editorial and recommendation context common on consumer marketplace pages.</p>
        </header>
        <div className="dd-two-column">
          {discover.featured_collections.map((collection) => (
            <article className="dd-panel" key={collection.title}>
              <h3>{collection.title}</h3>
              <p>{collection.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="dd-section">
        <header>
          <h2>Product grid</h2>
          <p>
            The fixture renders {formatNumber(locale, discover.products.length)} cards from the same data for Inertia
            and RSC, matching the public Discover payload shape closely enough for a meaningful A/B benchmark.
          </p>
        </header>
        <div className="dd-filter-strip">
          {discover.filetypes_data.map((filetype) => (
            <span className="dd-chip" key={filetype.key}>
              {filetype.key}: {formatNumber(locale, filetype.doc_count)}
            </span>
          ))}
        </div>
        <div className="dd-card-grid dd-card-grid--dense">
          {discover.products.map((card, index) => (
            <ProductCardView card={card} detailUrl={detailUrl} eager={index < 8} key={card.id} locale={locale} />
          ))}
        </div>
      </section>
    </div>
  );
};

export default function PublicProductComparisonPage({
  comparison,
  discover_page,
  locale,
  pageKind,
  product_page,
  source_note,
  variant,
}: Props) {
  const copy = variantCopy[variant];
  const activePageCopy = pageCopy[pageKind];
  const compareHref = routeFor(comparison, pageKind, variant === "inertia" ? "rsc" : "inertia");

  return (
    <div className="dd">
      <aside className="dd-side">
        <div className="dd-brand">
          <a href={comparison.home_url}>Gumroad</a>
          <p>React Server Components via React on Rails Pro benchmark</p>
        </div>

        <BenchmarkNav comparison={comparison} pageKind={pageKind} variant={variant} />

        <footer className="dd-meta">
          <strong>{activePageCopy.navLabel} benchmark</strong>
          <p>{source_note}</p>
          <p>
            <a href={comparison.consultation_url} rel="noreferrer" target="_blank">
              Book a ShakaCode consultation
            </a>
          </p>
        </footer>
      </aside>

      <main className="dd-main">
        <header className="dd-header dd-hero-grid">
          <div>
            <p className="dd-eyebrow">
              {copy.badge} - {activePageCopy.label}
            </p>
            <h1>{pageKind === "discover" ? discover_page?.title : product_page?.name}</h1>
            <p>{copy.lead}</p>
            <p className="dd-proof-line">
              Benchmark focus: <strong>{activePageCopy.proof}</strong>
            </p>
          </div>

          <div className="dd-actions">
            <a href={comparison.performance_url} className="dd-btn">
              Open performance lab
            </a>
            <a href={compareHref} className="dd-btn">
              {copy.compareLabel}
            </a>
            <a href={comparison.home_url} className="dd-btn">
              Back to home
            </a>
          </div>
        </header>

        {pageKind === "product" && product_page ? (
          <p className="dd-note dd-fixture-note">
            This is an attributed live fixture: title, seller, price, product type, rating summary, and source link
            match{" "}
            <a href={product_page.source_url} rel="noreferrer" target="_blank">
              {product_page.source_label}
            </a>
            . Longer product copy is lightly rewritten for a reproducible public benchmark.
          </p>
        ) : (
          <p className="dd-note dd-fixture-note">
            This is a production-shaped synthetic Discover fixture based on public Gumroad page structure. It is
            designed for matched A/B measurement, not as a copy of any creator's marketplace data.
          </p>
        )}

        {pageKind === "discover" && discover_page ? (
          <DiscoverBenchmark comparison={comparison} discover={discover_page} locale={locale} variant={variant} />
        ) : null}

        {pageKind === "product" && product_page ? (
          <ProductDetailBenchmark comparison={comparison} locale={locale} product={product_page} variant={variant} />
        ) : null}
      </main>
    </div>
  );
}
