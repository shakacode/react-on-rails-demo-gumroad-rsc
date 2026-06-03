import { configure as configureRoutes } from "$app/utils/routes";

type RouteDomainSettings = {
  scheme: string;
  app_domain: string;
};

export const configureClientRoutes = (domainSettings: RouteDomainSettings) => {
  if (typeof window === "undefined") return;

  configureRoutes({
    default_url_options: {
      protocol: domainSettings.scheme,
      host: domainSettings.app_domain,
    },
  });
};
