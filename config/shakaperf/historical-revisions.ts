import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";

export const HISTORICAL_CONTROL_SHA = "e720df1b4f13781af1b1b14efd10fe8a31e76641";
export const HISTORICAL_EXPERIMENT_SHA = "0c16a6cd36a2e2c89a7090e21c838a013b4d2654";

export const verifiedHistoricalCheckout = (directory: string, expectedSha: string, label: string) => {
  if (!existsSync(join(directory, ".git"))) {
    throw new Error(
      `Missing historical ${label} checkout at ${directory}. Run ./twin-servers/prepare-historical-checkouts first.`,
    );
  }

  const actualSha = execFileSync("git", ["-C", directory, "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
  if (actualSha !== expectedSha) {
    throw new Error(`Historical ${label} checkout is ${actualSha}; expected ${expectedSha}`);
  }
  return directory;
};
