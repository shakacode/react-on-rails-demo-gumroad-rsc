import { usePage } from "@inertiajs/react";
import * as React from "react";

import PublicProductComparisonPage, {
  type PublicProductComparisonPageProps,
} from "$app/src/public_product_rsc_demo/PublicProductComparisonPage";

export default function PublicProductInertiaDemo() {
  const props = usePage<PublicProductComparisonPageProps>().props;

  return <PublicProductComparisonPage {...props} variant="inertia" />;
}
