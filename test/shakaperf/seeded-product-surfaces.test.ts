import assert from "node:assert/strict";
import { test } from "node:test";

import { clearRegistry, getRegisteredTests } from "shaka-shared";

import config from "../../abtests.config";
import { REPRESENTATIVE_CATEGORIES, seededProductComparisons } from "../../config/shakaperf/seeded-product-surfaces";

test("resolves representative catalog products to direct creator-host twin URLs", () => {
  assert.deepEqual(REPRESENTATIVE_CATEGORIES, ["demo", "film", "audio", "design", "merchandise"]);
  assert.deepEqual(
    seededProductComparisons.map(({ product, controlUrl, experimentUrl }) => ({
      category: product.category,
      name: product.name,
      controlUrl,
      experimentUrl,
    })),
    [
      {
        category: "demo",
        name: "Beautiful widget",
        controlUrl: "http://seller.legacy.gumroad.reactonrails.com:3100/l/demo",
        experimentUrl: "http://seller.next.gumroad.reactonrails.com:3200/l/demo",
      },
      {
        category: "film",
        name: "Beautiful films widget",
        controlUrl: "http://gumbofilm.legacy.gumroad.reactonrails.com:3100/l/demo_films",
        experimentUrl: "http://gumbofilm.next.gumroad.reactonrails.com:3200/l/demo_films",
      },
      {
        category: "audio",
        name: "Beautiful audio widget",
        controlUrl: "http://gumboaudio.legacy.gumroad.reactonrails.com:3100/l/demo_audio",
        experimentUrl: "http://gumboaudio.next.gumroad.reactonrails.com:3200/l/demo_audio",
      },
      {
        category: "design",
        name: "Beautiful design widget",
        controlUrl: "http://gumbodesign.legacy.gumroad.reactonrails.com:3100/l/demo_design",
        experimentUrl: "http://gumbodesign.next.gumroad.reactonrails.com:3200/l/demo_design",
      },
      {
        category: "merchandise",
        name: "Beautiful fiction-books widget",
        controlUrl: "http://gumbomerchandise.legacy.gumroad.reactonrails.com:3100/l/demo_fiction_books",
        experimentUrl: "http://gumbomerchandise.next.gumroad.reactonrails.com:3200/l/demo_fiction_books",
      },
    ],
  );
});

test("uses the same current checkout and canonical seed runner for both twins", () => {
  assert.equal(config.twinServers?.controlDir, config.twinServers?.experimentDir);
  assert.match(config.shared.testPathPattern ?? "", /seeded-product-surfaces/u);
  assert.ok(config.shared.playwrightOptions.args?.some((arg) => arg.includes("host-resolver-rules")));
  assert.ok(
    config.twinServers?.setupCommands?.some(({ command }) =>
      command.includes("scripts/seed_development_staging_products.rb"),
    ),
  );
});

test("discovers only the current seeded-surface definitions by default", async () => {
  clearRegistry();
  await import("../../ab-tests/seeded-product-surfaces.abtest");

  const definitions = getRegisteredTests();
  assert.equal(definitions.length, REPRESENTATIVE_CATEGORIES.length);
  assert.deepEqual(
    definitions.map(({ startingPath, experimentPathOverride }) => ({ startingPath, experimentPathOverride })),
    seededProductComparisons.map(({ controlUrl, experimentUrl }) => ({
      startingPath: controlUrl,
      experimentPathOverride: experimentUrl,
    })),
  );

  for (const definition of definitions) {
    const body = definition.testFn.toString();
    assert.match(body, /x-gumroad-rendering-surface/u);
    assert.match(body, /page\.evaluate/u);
    assert.match(body, /fetch/u);
    assert.doesNotMatch(body, /page\.request/u);
    assert.match(body, /script\[data-page="app"\]/u);
    assert.match(body, /#next-rsc-page-root/u);
  }
});
