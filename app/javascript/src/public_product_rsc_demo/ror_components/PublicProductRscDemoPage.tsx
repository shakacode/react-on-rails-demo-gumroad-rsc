import * as React from "react";

import PublicProductComparisonPage, { type PublicProductComparisonPageProps } from "../PublicProductComparisonPage";

export default function PublicProductRscDemoPage(props: PublicProductComparisonPageProps) {
  return <PublicProductComparisonPage {...props} pageKind="product" variant="rsc" />;
}
