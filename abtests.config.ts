import { defineConfig, installRequestBlocking, DESKTOP_VIEWPORT, PHONE_VIEWPORT } from "shaka-shared";
import type { AbTestsConfigInput, SharedConfigInput } from "shaka-shared";

import { seededProductComparisons } from "./config/shakaperf/seeded-product-surfaces";

type ShakaPerfConfig = AbTestsConfigInput & {
  shared: SharedConfigInput & {
    browserConsole: { failOn: ("error" | "warn")[]; allowList: string[] };
  };
};

const CONTROL_PORT = Number(process.env.SHAKAPERF_CONTROL_PORT || 3100);
const EXPERIMENT_PORT = Number(process.env.SHAKAPERF_EXPERIMENT_PORT || 3200);
const projectDir = process.cwd();
const currentRevisionDir = process.env.SHAKAPERF_CURRENT_DIR || projectDir;
const readinessComparison = seededProductComparisons[0];

if (!readinessComparison) throw new Error("The seeded product catalog must define a readiness comparison");

const LIGHTHOUSE_CONFIG = {
  throttling: {
    rttMs: 150,
    throughputKbps: 1638.4,
    requestLatencyMs: 562.5,
    downloadThroughputKbps: 1474.56,
    uploadThroughputKbps: 675,
    cpuSlowdownMultiplier: 4,
  },
  throttlingMethod: "devtools" as const,
  logLevel: "error" as const,
  output: "html" as const,
  onlyCategories: ["performance"],
  maxWaitForLoad: 60_000,
  networkQuietThresholdMs: 1_000,
  cpuQuietThresholdMs: 1_000,
};

const config: ShakaPerfConfig = {
  shared: {
    // The app intentionally has no localhost root surface. These direct URLs
    // let ShakaPerf's readiness helpers probe the same host topology as tests.
    controlURL: readinessComparison.controlUrl,
    experimentURL: readinessComparison.experimentUrl,
    testPathPattern: "ab-tests/seeded-product-surfaces\\.abtest\\.ts$",
    viewportDefinitions: [DESKTOP_VIEWPORT, PHONE_VIEWPORT],
    viewports: ["desktop", "phone"],
    parallelism: 1,
    beforeNavigate: async ({ context }) => {
      await installRequestBlocking(context, ["/recaptcha/", "/cart_items_count"]);
    },
    playwrightOptions: {
      browser: "chromium",
      args: [
        "--no-sandbox",
        "--host-resolver-rules=MAP *.legacy.gumroad.reactonrails.com 127.0.0.1,MAP *.next.gumroad.reactonrails.com 127.0.0.1",
      ],
      waitTimeout: 60_000,
    },
    browserConsole: {
      failOn: ["error"],
      allowList: ["FB.getLoginStatus can no longer be called from http pages", "/cart_items_count"],
    },
  },
  visreg: {
    viewports: ["desktop", "phone"],
    mismatchThreshold: 0.1,
    maxNumDiffPixels: 50,
    comparePixelmatchThreshold: 0.1,
  },
  perf: {
    viewports: ["phone"],
    numberOfMeasurements: 10,
    regressionThreshold: 50,
    pValueThreshold: 0.05,
    regressionThresholdStat: "estimator",
    samplingMode: "simultaneous",
    lighthouseConfig: LIGHTHOUSE_CONFIG,
  },
  audit: { lighthouseConfig: LIGHTHOUSE_CONFIG },
  twinServers: {
    // Both images build the same checkout. Runtime surface selection is the
    // experimental variable; SHAKAPERF_CURRENT_DIR may point both at another checkout.
    controlDir: currentRevisionDir,
    experimentDir: currentRevisionDir,
    dockerBuildDir: ".",
    dockerfile: "twin-servers/Dockerfile",
    procfile: "twin-servers/seeded-products/Procfile",
    composeFile: "twin-servers/seeded-products/docker-compose.yml",
    ports: { control: CONTROL_PORT, experiment: EXPERIMENT_PORT },
    setupCommands: [
      {
        command: `export STRONGBOX_GENERAL="$(ruby -ropenssl -e 'print OpenSSL::PKey::RSA.generate(2048).to_pem')" && export STRONGBOX_GENERAL_PASSWORD=""`,
        description: "Generating the local runtime encryption key",
      },
      { command: "memcached -d", description: "Starting the embedded Memcached server" },
      {
        command: "bundle exec rails db:schema:load",
        description: "Loading a fresh schema into each isolated MySQL database",
      },
      {
        command: "bundle exec rails runner scripts/seed_development_staging_products.rb",
        description: "Seeding the canonical 16-product catalog into each isolated database",
      },
    ],
  },
};

export default defineConfig(config);
