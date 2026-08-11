import {
  defineConfig,
  installRequestBlocking,
  DESKTOP_VIEWPORT,
  PHONE_VIEWPORT,
} from 'shaka-shared';

const CONTROL_PORT = Number(process.env.SHAKAPERF_CONTROL_PORT || 3100);
const EXPERIMENT_PORT = Number(process.env.SHAKAPERF_EXPERIMENT_PORT || 3200);
const projectDir = process.cwd();

const LIGHTHOUSE_CONFIG = {
  throttling: {
    rttMs: 150,
    throughputKbps: 1638.4,
    requestLatencyMs: 562.5,
    downloadThroughputKbps: 1474.56,
    uploadThroughputKbps: 675,
    cpuSlowdownMultiplier: 4,
  },
  throttlingMethod: 'devtools' as const,
  logLevel: 'error' as const,
  output: 'html' as const,
  onlyCategories: ['performance'],
  maxWaitForLoad: 60_000,
  networkQuietThresholdMs: 1_000,
  cpuQuietThresholdMs: 1_000,
};

export default defineConfig({
  shared: {
    controlURL: `http://localhost:${CONTROL_PORT}`,
    experimentURL: `http://localhost:${EXPERIMENT_PORT}`,
    viewportDefinitions: [DESKTOP_VIEWPORT, PHONE_VIEWPORT],
    viewports: ['desktop', 'phone'],
    parallelism: 1,
    beforeNavigate: async ({ context }) => {
      // The cart badge is unrelated to product rendering and its absolute
      // production-style URL cannot target either localhost twin reliably.
      await installRequestBlocking(context, ['/recaptcha/', '/cart_items_count']);
    },
    playwrightOptions: {
      browser: 'chromium',
      args: ['--no-sandbox'],
      waitTimeout: 60_000,
    },
    browserConsole: {
      failOn: ['error'],
      // These local-only dependencies are unrelated to product rendering:
      // Facebook Login rejects plain HTTP, and the production-style absolute
      // cart badge URL cannot address either localhost twin.
      allowList: [
        'FB.getLoginStatus can no longer be called from http pages',
        '/cart_items_count',
      ],
    },
  },

  visreg: {
    viewports: ['desktop', 'phone'],
    mismatchThreshold: 0.1,
    maxNumDiffPixels: 50,
    comparePixelmatchThreshold: 0.1,
  },

  perf: {
    viewports: ['phone'],
    numberOfMeasurements: 10,
    regressionThreshold: 50,
    pValueThreshold: 0.05,
    regressionThresholdStat: 'estimator',
    samplingMode: 'simultaneous',
    lighthouseConfig: LIGHTHOUSE_CONFIG,
  },

  audit: {
    lighthouseConfig: LIGHTHOUSE_CONFIG,
  },

  twinServers: {
    // Both containers build this checkout. The test chooses the two existing
    // implementations with experimentPathOverride, so branch clones are not
    // needed for this route-level A/B test. Override either path for branch A/B.
    controlDir: process.env.SHAKAPERF_CONTROL_DIR || projectDir,
    experimentDir: process.env.SHAKAPERF_EXPERIMENT_DIR || projectDir,
    dockerBuildDir: '.',
    dockerfile: 'twin-servers/Dockerfile',
    procfile: 'twin-servers/Procfile',
    composeFile: 'twin-servers/docker-compose.yml',
    ports: {
      control: CONTROL_PORT,
      experiment: EXPERIMENT_PORT,
    },
    setupCommands: [
      {
        command: `export STRONGBOX_GENERAL="$(ruby -ropenssl -e 'print OpenSSL::PKey::RSA.generate(2048).to_pem')" && export STRONGBOX_GENERAL_PASSWORD=""`,
        description: 'Generating the local runtime encryption key',
      },
      {
        command: 'memcached -d',
        description: 'Starting the embedded Memcached server',
      },
      {
        command: 'bundle exec rails db:schema:load',
        description: 'Loading a fresh schema into each isolated MySQL database',
      },
      {
        command: 'bundle exec rails runner scripts/seed_native_product_page.rb',
        description: 'Seeding the database-backed native product fixture',
      },
    ],
  },
});
