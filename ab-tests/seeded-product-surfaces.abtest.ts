import { abTest, waitUntilPageSettled } from "shaka-shared";

import { seededProductComparisons } from "../config/shakaperf/seeded-product-surfaces";

for (const { product, controlUrl, experimentUrl } of seededProductComparisons) {
  abTest(
    `Seeded ${product.category} product: Legacy Inertia vs Next RSC`,
    {
      startingPath: controlUrl,
      experimentPathOverride: experimentUrl,
      testTypes: ["visreg", "perf", "accessibility"],
      visregSelectors: ["article"],
    },
    async ({ page, annotate, isControl }) => {
      const expectedSurface = isControl ? "legacy" : "next";
      const response = await page.request.get(page.url());
      const actualSurface = response.headers()["x-gumroad-rendering-surface"];
      if (actualSurface !== expectedSurface) {
        throw new Error(`Expected ${expectedSurface} surface, received ${actualSurface || "no surface header"}`);
      }

      const expectedRenderer = isControl ? 'script[data-page="app"]' : "#next-rsc-page-root";
      const unexpectedRenderer = isControl ? "#next-rsc-page-root" : 'script[data-page="app"]';
      await page.locator(expectedRenderer).waitFor({ state: "attached" });
      if (await page.locator(unexpectedRenderer).count()) {
        throw new Error(`Expected only the ${isControl ? "Legacy Inertia" : "Next RSC"} renderer`);
      }

      await page.locator("article").waitFor({ state: "visible" });
      await page.getByRole("heading", { level: 1, name: product.name, exact: true }).waitFor({ state: "visible" });
      await waitUntilPageSettled(page);
      await annotate(`${product.category}: ${expectedSurface} renderer selected`);
    },
  );
}
