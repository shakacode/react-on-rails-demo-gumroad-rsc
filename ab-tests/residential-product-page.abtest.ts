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
    await page.locator(isControl ? "#app[data-page]" : "#native-product-rsc-root").waitFor({ state: "attached" });
    if (await page.locator(isControl ? "#native-product-rsc-root" : "#app[data-page]").count()) {
      throw new Error(`Expected ${isControl ? "Inertia" : "React on Rails RSC"} renderer only`);
    }
    await page.locator("article").waitFor({ state: "visible" });
    await page
      .getByRole("heading", { level: 1, name: /Graphic Guide to Residential Design/ })
      .waitFor({ state: "visible" });
    await page.getByLabel("Product preview").waitFor({ state: "visible" });
    await page.locator('article [itemprop="price"]:visible').first().waitFor({ state: "visible" });
    await waitUntilPageSettled(page);
    await annotate(`${isControl ? "Inertia" : "React on Rails RSC"} Residential Design product fully rendered`);
  },
);
