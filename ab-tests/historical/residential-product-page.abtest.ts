import { abTest, waitUntilPageSettled } from "shaka-shared";

abTest(
  "Residential Design product: Inertia control vs React on Rails RSC",
  {
    startingPath: "/l/bgfjk?layout=discover&recommended_by=search",
    experimentPathOverride: "/l/bgfjk?layout=discover&recommended_by=search&rsc=1",
    testTypes: ["visreg", "perf", "accessibility"],
    visregSelectors: ["article"],
  },
  async ({ page, annotate, isControl }) => {
    await page
      .locator(isControl ? 'script[data-page="app"]' : "#native-product-rsc-root")
      .waitFor({ state: "attached" });
    if (await page.locator(isControl ? "#native-product-rsc-root" : 'script[data-page="app"]').count()) {
      throw new Error(`Expected ${isControl ? "Inertia" : "React on Rails RSC"} renderer only`);
    }
    await page.locator("article").waitFor({ state: "visible" });
    await page
      .getByRole("heading", { level: 1, name: /Graphic Guide to Residential Design/ })
      .waitFor({ state: "visible" });
    await page.getByLabel("Product preview").waitFor({ state: "visible" });
    await waitUntilPageSettled(page);
    await annotate(`Residential ${isControl ? "Inertia" : "RSC"} rendered`);
  },
);
