import { abTest, waitUntilPageSettled } from 'shaka-shared';

abTest(
  'Public product detail: Inertia control versus RSC experiment',
  {
    startingPath: '/public_product/inertia_demo',
    experimentPathOverride: '/public_product/rsc_demo',
    testTypes: ['visreg', 'perf', 'accessibility'],
    visregSelectors: ['.dd-product-hero'],
  },
  async ({ page, annotate }) => {
    await page.locator('.dd-product-hero').waitFor({ state: 'visible' });
    await page.locator('h1').waitFor({ state: 'visible' });
    await waitUntilPageSettled(page);
    annotate('Compared the fully rendered public product hero and page-load performance.');
  },
);
