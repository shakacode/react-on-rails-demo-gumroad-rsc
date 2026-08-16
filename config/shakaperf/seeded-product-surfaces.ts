import { readFileSync } from "node:fs";

import { load } from "js-yaml";

type SurfaceCatalog = {
  version: number;
  surfaces: {
    legacy_host: string;
    next_host: string;
  };
  products: SeededProduct[];
};

export type SeededProduct = {
  name: string;
  category: string;
  taxonomy_slug: string | null;
  seller_email: string;
  seller_username: string;
  price_cents: number;
  permalink: string;
  legacy_path: string;
  next_path: string;
};

export const REPRESENTATIVE_CATEGORIES = ["demo", "film", "audio", "design", "merchandise"] as const;

const catalogPath = new URL("../development_staging_products.yml", import.meta.url);

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null && !Array.isArray(value);

const stringField = (record: Record<string, unknown>, field: string) => {
  const value = record[field];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Invalid ${field} in ${catalogPath.pathname}`);
  }
  return value;
};

const numberField = (record: Record<string, unknown>, field: string) => {
  const value = record[field];
  if (typeof value !== "number") throw new Error(`Invalid ${field} in ${catalogPath.pathname}`);
  return value;
};

const parseCatalog = (value: unknown): SurfaceCatalog => {
  if (!isRecord(value) || !isRecord(value.surfaces) || !Array.isArray(value.products)) {
    throw new Error(`Invalid product catalog structure in ${catalogPath.pathname}`);
  }

  return {
    version: numberField(value, "version"),
    surfaces: {
      legacy_host: stringField(value.surfaces, "legacy_host"),
      next_host: stringField(value.surfaces, "next_host"),
    },
    products: value.products.map((product) => {
      if (!isRecord(product)) throw new Error(`Invalid product entry in ${catalogPath.pathname}`);
      const taxonomySlug = product.taxonomy_slug;
      if (taxonomySlug !== null && typeof taxonomySlug !== "string") {
        throw new Error(`Invalid taxonomy_slug in ${catalogPath.pathname}`);
      }

      return {
        name: stringField(product, "name"),
        category: stringField(product, "category"),
        taxonomy_slug: taxonomySlug,
        seller_email: stringField(product, "seller_email"),
        seller_username: stringField(product, "seller_username"),
        price_cents: numberField(product, "price_cents"),
        permalink: stringField(product, "permalink"),
        legacy_path: stringField(product, "legacy_path"),
        next_path: stringField(product, "next_path"),
      };
    }),
  };
};

const catalog = parseCatalog(load(readFileSync(catalogPath, "utf8")));

const controlPort = Number(process.env.SHAKAPERF_CONTROL_PORT || 3100);
const experimentPort = Number(process.env.SHAKAPERF_EXPERIMENT_PORT || 3200);

const productFor = (category: (typeof REPRESENTATIVE_CATEGORIES)[number]) => {
  const product = catalog.products.find((candidate) => candidate.category === category);
  if (!product) throw new Error(`Missing ${category} in ${catalogPath.pathname}`);
  if (!product.seller_username) throw new Error(`Missing seller_username for ${category} in ${catalogPath.pathname}`);
  if (product.legacy_path !== product.next_path) {
    throw new Error(`Legacy/Next paths differ for ${category} in ${catalogPath.pathname}`);
  }
  return product;
};

const directProductUrl = (sellerUsername: string, surfaceHost: string, port: number, path: string) =>
  `http://${sellerUsername.replaceAll("_", "-")}.${surfaceHost}:${port}${path}`;

export const seededProductComparisons = REPRESENTATIVE_CATEGORIES.map((category) => {
  const product = productFor(category);
  return {
    product,
    controlUrl: directProductUrl(
      product.seller_username,
      catalog.surfaces.legacy_host,
      controlPort,
      product.legacy_path,
    ),
    experimentUrl: directProductUrl(
      product.seller_username,
      catalog.surfaces.next_host,
      experimentPort,
      product.next_path,
    ),
  };
});

export const seededProductSurfaceHosts = catalog.surfaces;
