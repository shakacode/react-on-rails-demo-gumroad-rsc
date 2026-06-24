#!/usr/bin/env node
/* eslint-disable no-console */

import { Buffer } from "node:buffer";

const DEFAULT_URLS = ["https://gumroad.com/discover"];
// Pass an explicit public product URL when checking product-page shape; do not commit scraped creator content.

const includeSourceUrl = process.argv.includes("--include-source-url");
const urls = process.argv.slice(2).filter((arg) => arg !== "--include-source-url");
const targetUrls = urls.length > 0 ? urls : DEFAULT_URLS;

const decodeHtmlAttribute = (value) =>
  value
    .replace(/&quot;/gu, '"')
    .replace(/&#39;/gu, "'")
    .replace(/&amp;/gu, "&")
    .replace(/&lt;/gu, "<")
    .replace(/&gt;/gu, ">");

const summarizeShape = (value, depth = 0) => {
  if (depth > 4) return Array.isArray(value) ? `array(${value.length})` : typeof value;

  if (Array.isArray(value)) {
    return {
      type: "array",
      length: value.length,
      first: value.length > 0 ? summarizeShape(value[0], depth + 1) : null,
    };
  }

  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .slice(0, 60)
        .map(([key, child]) => [key, summarizeShape(child, depth + 1)]),
    );
  }

  return typeof value;
};

const selectedShapeKeys = [
  "product",
  "seller",
  "recommended_products",
  "search_results",
  "taxonomies_for_nav",
  "currency_code",
  "sections",
  "purchase",
  "related_products",
];

for (const url of targetUrls) {
  const response = await fetch(url, {
    headers: { "User-Agent": "ShakaCode-RSC-demo-fixture-shape-sampler/1.0" },
  });
  const html = await response.text();
  const dataPageMatch = html.match(/data-page="([^"]*)"/u);
  const report = {
    source: new URL(url).pathname === "/discover" ? "public Gumroad Discover page" : "public Gumroad product page",
    status: response.status,
    contentType: response.headers.get("content-type"),
    htmlBytes: Buffer.byteLength(html),
    scriptTags: (html.match(/<script\b/gu) || []).length,
    imgTags: (html.match(/<img\b/gu) || []).length,
    hasInertiaDataPage: Boolean(dataPageMatch),
    component: null,
    propKeys: [],
    selectedShapes: {},
  };

  if (includeSourceUrl) report.sourceUrl = url;

  if (dataPageMatch) {
    const page = JSON.parse(decodeHtmlAttribute(dataPageMatch[1]));
    const props = page.props || {};
    report.component = page.component;
    report.propKeys = Object.keys(props);
    report.selectedShapes = Object.fromEntries(
      selectedShapeKeys.filter((key) => key in props).map((key) => [key, summarizeShape(props[key])]),
    );
  }

  console.log(JSON.stringify(report, null, 2));
}
