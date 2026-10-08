import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import {
  HISTORICAL_CONTROL_SHA,
  HISTORICAL_EXPERIMENT_SHA,
  verifiedHistoricalCheckout,
} from "../../config/shakaperf/historical-revisions";

test("pins exact historical revisions and rejects the current checkout", () => {
  assert.equal(HISTORICAL_CONTROL_SHA, "e720df1b4f13781af1b1b14efd10fe8a31e76641");
  assert.equal(HISTORICAL_EXPERIMENT_SHA, "0c16a6cd36a2e2c89a7090e21c838a013b4d2654");
  assert.throws(
    () => verifiedHistoricalCheckout(process.cwd(), HISTORICAL_EXPERIMENT_SHA, "experiment"),
    /expected 0c16a6cd36a2e2c89a7090e21c838a013b4d2654/u,
  );
});

test("accepts only an exact clean historical checkout", () => {
  const repository = mkdtempSync(join(tmpdir(), "shakaperf-historical-revision-"));
  const preparationScript = join(process.cwd(), "twin-servers/prepare-historical-checkouts");
  const git = (...args: string[]) =>
    execFileSync("git", ["-C", repository, ...args], { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
  const verifyPreparation = (revision: string) =>
    execFileSync(preparationScript, ["--verify-checkout", "fixture", repository, revision], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });

  try {
    git("init", "--quiet");
    git("config", "user.email", "shakaperf@example.com");
    git("config", "user.name", "ShakaPerf Test");
    writeFileSync(join(repository, "tracked.txt"), "clean\n");
    git("add", "tracked.txt");
    git("commit", "--quiet", "-m", "fixture");
    const revision = git("rev-parse", "HEAD").trim();

    assert.equal(verifiedHistoricalCheckout(repository, revision, "fixture"), repository);
    assert.doesNotThrow(() => verifyPreparation(revision));

    writeFileSync(join(repository, "tracked.txt"), "modified\n");
    assert.throws(() => verifiedHistoricalCheckout(repository, revision, "fixture"), /is dirty:[\s\S]*tracked\.txt/u);
    assert.throws(() => verifyPreparation(revision), /is dirty:[\s\S]*tracked\.txt/u);
    git("restore", "tracked.txt");

    writeFileSync(join(repository, "untracked.txt"), "untracked\n");
    assert.throws(() => verifiedHistoricalCheckout(repository, revision, "fixture"), /is dirty:[\s\S]*untracked\.txt/u);
    assert.throws(() => verifyPreparation(revision), /is dirty:[\s\S]*untracked\.txt/u);
    git("clean", "-f", "--", "untracked.txt");

    writeFileSync(join(repository, "tracked.txt"), "staged\n");
    git("add", "tracked.txt");
    assert.throws(() => verifiedHistoricalCheckout(repository, revision, "fixture"), /is dirty:[\s\S]*tracked\.txt/u);
    assert.throws(() => verifyPreparation(revision), /is dirty:[\s\S]*tracked\.txt/u);
  } finally {
    rmSync(repository, { recursive: true, force: true });
  }
});
