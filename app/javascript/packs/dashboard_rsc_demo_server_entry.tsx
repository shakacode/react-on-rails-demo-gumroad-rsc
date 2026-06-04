import "react-on-rails-pro";
import registerServerComponent from "react-on-rails-pro/registerServerComponent/server";

import DashboardRscDemoPage from "../src/dashboard_rsc_demo/ror_components/DashboardRscDemoPage";
import PublicProductRscDemoPage from "../src/public_product_rsc_demo/ror_components/PublicProductRscDemoPage";

registerServerComponent({ DashboardRscDemoPage, PublicProductRscDemoPage });
