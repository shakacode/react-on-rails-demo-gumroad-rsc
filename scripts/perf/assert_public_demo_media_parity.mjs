#!/usr/bin/env node
/* eslint-disable no-console */

import { Buffer } from "node:buffer";

const DEFAULT_BASE_URL = "http://localhost:3000";
const MEDIA_BASE_PATH = "/public-product-rsc-demo/media/";

const parseArgs = () => {
  const args = process.argv.slice(2);
  const baseUrlIndex = args.indexOf("--base-url");

  if (baseUrlIndex >= 0) {
    const value = args[baseUrlIndex + 1];
    if (!value || value.startsWith("--")) {
      throw new Error("Missing value for --base-url");
    }
    return { baseUrl: value };
  }

  const positional = args.find((arg) => !arg.startsWith("--"));
  return { baseUrl: positional || DEFAULT_BASE_URL };
};

const countMatches = (text, pattern) => (text.match(pattern) || []).length;

const uniqueMediaRefs = (html) => new Set(html.match(new RegExp(`${MEDIA_BASE_PATH}[^"'\\s<]+`, "gu")) || []);

const routes = [
  {
    label: "Product Inertia serialized fixture",
    path: "/public_product/inertia_demo",
    minMediaRefs: 9,
    minInitialImgTags: 0,
    note: "Inertia media is serialized in data-page and renders after hydration.",
  },
  {
    label: "Product RSC initial HTML",
    path: "/public_product/rsc_demo",
    minMediaRefs: 9,
    minInitialImgTags: 9,
    note: "PageSpeed should see the product cover and recommendation images in the streamed RSC document.",
  },
  {
    label: "Discover Inertia serialized fixture",
    path: "/public_product/discover_inertia_demo",
    minMediaRefs: 8,
    minInitialImgTags: 0,
    note: "The 36 hydrated cards rotate across the local synthetic media set.",
  },
  {
    label: "Discover RSC initial HTML",
    path: "/public_product/discover_rsc_demo",
    minMediaRefs: 8,
    minInitialImgTags: 36,
    note: "PageSpeed should see the full Discover card grid as image elements.",
  },
];

const { baseUrl } = parseArgs();
const base = new URL(baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`);
let failures = 0;

for (const route of routes) {
  const url = new URL(route.path, base);
  const response = await fetch(url, {
    headers: { "User-Agent": "ShakaCode-RSC-demo-media-parity/1.0" },
  });
  const html = await response.text();
  const mediaRefs = uniqueMediaRefs(html);
  const initialImgTags = countMatches(html, /<img\b/gu);
  const problems = [];

  if (!response.ok) {
    problems.push(`HTTP ${response.status}`);
  }

  if (mediaRefs.size < route.minMediaRefs) {
    problems.push(`expected >= ${route.minMediaRefs} unique local media refs, saw ${mediaRefs.size}`);
  }

  if (initialImgTags < route.minInitialImgTags) {
    problems.push(`expected >= ${route.minInitialImgTags} initial <img> tags, saw ${initialImgTags}`);
  }

  const status = problems.length === 0 ? "PASS" : "FAIL";
  if (problems.length > 0) failures += 1;

  console.log(
    JSON.stringify(
      {
        status,
        label: route.label,
        url: url.toString(),
        httpStatus: response.status,
        htmlBytes: Buffer.byteLength(html),
        uniqueLocalMediaRefs: mediaRefs.size,
        initialImgTags,
        note: route.note,
        problems,
      },
      null,
      2,
    ),
  );
}

if (failures > 0) {
  console.error(
    `Media parity failed for ${failures} route(s). Do not use PageSpeed or same-host ShakaPerf results as current media-bearing evidence for this host.`,
  );
  process.exit(1);
}

console.error("Media parity passed for public product and Discover demo routes.");
