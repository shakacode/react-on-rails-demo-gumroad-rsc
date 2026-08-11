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
      await installRequestBlocking(context, ['/recaptcha/']);
    },
    playwrightOptions: {
      browser: 'chromium',
      args: ['--no-sandbox'],
      waitTimeout: 60_000,
    },
    browserConsole: {
      failOn: ['error'],
      allowList: [],
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
    numberOfMeasurements: 7,
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
        command: 'redis-server --save "" --appendonly no --daemonize yes',
        description: 'Starting the embedded Redis server',
      },
      {
        command: 'memcached -d',
        description: 'Starting the embedded Memcached server',
      },
      {
        command: 'bundle exec rails db:schema:load',
        description: 'Loading a fresh schema into each isolated MySQL database',
      },
    ],
  },
});
