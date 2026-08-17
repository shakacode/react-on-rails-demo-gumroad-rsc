import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { readFileSync } from "node:fs";
import { createServer, type Server } from "node:http";
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

test("keeps the shared comparison defaults at the twin origins", () => {
  assert.equal(config.shared.controlURL, "http://localhost:3100");
  assert.equal(config.shared.experimentURL, "http://localhost:3200");
});

type HelperResult = {
  code: number | null;
  signal: NodeJS.Signals | null;
  stdout: string;
  stderr: string;
};

const startServer = async (server: Server): Promise<number> => {
  await new Promise<void>((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      server.off("error", reject);
      resolve();
    });
  });

  const address = server.address();
  assert.ok(address && typeof address === "object");
  return address.port;
};

const closeServer = async (server: Server): Promise<void> => {
  server.closeAllConnections();
  await new Promise<void>((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  });
};

const runReadinessHelper = async (
  port: number,
  { stopWhenReady = false, timeoutMs = 3_000 }: { stopWhenReady?: boolean; timeoutMs?: number } = {},
): Promise<HelperResult> =>
  new Promise((resolve, reject) => {
    const child = spawn("./twin-servers/wait-for-seeded-product", ["control"], {
      env: {
        ...process.env,
        SHAKAPERF_CONTROL_PORT: String(port),
        SHAKAPERF_READINESS_ATTEMPTS: "2",
        SHAKAPERF_READINESS_CONNECT_TIMEOUT_SECONDS: "0.2",
        SHAKAPERF_READINESS_REQUEST_TIMEOUT_SECONDS: "0.2",
        SHAKAPERF_READINESS_RETRY_DELAY_SECONDS: "0",
      },
    });
    let stdout = "";
    let stderr = "";
    let stopped = false;

    const timeout = setTimeout(() => {
      child.kill("SIGTERM");
      reject(new Error(`Readiness helper exceeded ${timeoutMs}ms. stdout=${stdout} stderr=${stderr}`));
    }, timeoutMs);

    child.stdout.on("data", (chunk: Buffer) => {
      stdout += chunk.toString();
      if (stopWhenReady && !stopped && stdout.includes("Seeded product ready:")) {
        stopped = true;
        child.kill("SIGTERM");
      }
    });
    child.stderr.on("data", (chunk: Buffer) => {
      stderr += chunk.toString();
    });
    child.once("error", (error) => {
      clearTimeout(timeout);
      reject(error);
    });
    child.once("close", (code, signal) => {
      clearTimeout(timeout);
      resolve({ code, signal, stdout, stderr });
    });
  });

test("waits for an exact 200 from the direct seeded-product URL", async () => {
  const requests: { host: string | undefined; path: string | undefined }[] = [];
  const server = createServer((request, response) => {
    requests.push({ host: request.headers.host, path: request.url });
    response.writeHead(200).end("ready");
  });
  const port = await startServer(server);

  try {
    const result = await runReadinessHelper(port, { stopWhenReady: true });

    assert.equal(result.code, null);
    assert.equal(result.signal, "SIGTERM");
    assert.match(result.stdout, /Seeded product ready:/u);
    assert.deepEqual(requests, [{ host: `seller.legacy.gumroad.reactonrails.com:${port}`, path: "/l/demo" }]);
  } finally {
    await closeServer(server);
  }
});

test("rejects redirects without following them", async () => {
  const requestedPaths: (string | undefined)[] = [];
  const server = createServer((request, response) => {
    requestedPaths.push(request.url);
    response.writeHead(302, { location: "/unexpected" }).end();
  });
  const port = await startServer(server);

  try {
    const result = await runReadinessHelper(port);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Timed out waiting for seeded product:/u);
    assert.deepEqual(requestedPaths, ["/l/demo", "/l/demo"]);
  } finally {
    await closeServer(server);
  }
});

test("bounds stalled requests and retries before exiting", async () => {
  let requestCount = 0;
  const server = createServer(() => {
    requestCount += 1;
  });
  const port = await startServer(server);
  const startedAt = performance.now();

  try {
    const result = await runReadinessHelper(port);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Timed out waiting for seeded product:/u);
    assert.equal(requestCount, 2);
    assert.ok(performance.now() - startedAt < 2_000);
  } finally {
    await closeServer(server);
  }
});

test("bounds failed connection retries before exiting", async () => {
  const server = createServer();
  const port = await startServer(server);
  await closeServer(server);

  const startedAt = performance.now();
  const result = await runReadinessHelper(port);

  assert.equal(result.code, 1);
  assert.match(result.stderr, /Timed out waiting for seeded product:/u);
  assert.equal(result.stderr.match(/curl: \(7\)/gu)?.length, 2);
  assert.ok(performance.now() - startedAt < 2_000);
});

test("runs the direct product readiness helper from both twin Procfile entries", () => {
  const procfile = readFileSync("twin-servers/seeded-products/Procfile", "utf8");

  assert.match(procfile, /wait-for-seeded-product control/u);
  assert.match(procfile, /wait-for-seeded-product experiment/u);
  assert.doesNotMatch(procfile, /notify-server-started/u);
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
