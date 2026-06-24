import * as React from "react";

import PublicProductComparisonPage, { type PublicProductComparisonPageProps } from "../PublicProductComparisonPage";

export default function PublicDiscoverRscDemoPage(props: PublicProductComparisonPageProps) {
  return <PublicProductComparisonPage {...props} pageKind="discover" variant="rsc" />;
}
