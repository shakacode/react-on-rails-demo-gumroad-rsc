import { abTest, waitUntilPageSettled } from 'shaka-shared';

abTest(
  'Database-backed native product page',
  {
    startingPath: '/l/O365IT?layout=discover&recommended_by=search',
    testTypes: ['visreg', 'perf', 'accessibility'],
    visregSelectors: ['article'],
  },
  async ({ page, annotate }) => {
    await page.locator('article').waitFor({ state: 'visible' });
    await page.getByRole('heading', { level: 1, name: /Microsoft 365 for IT Pros/ }).waitFor({ state: 'visible' });
    await page.getByLabel('Product preview').waitFor({ state: 'visible' });
    await page.locator('article [itemprop="price"]:visible').first().waitFor({ state: 'visible' });
    await waitUntilPageSettled(page);
    annotate('Seeded native product fully rendered');
  },
);
