import assert from "node:assert/strict";
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
