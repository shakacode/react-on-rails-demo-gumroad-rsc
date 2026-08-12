"use client";

import type { Page } from "@inertiajs/core";
import { App as InertiaApp } from "@inertiajs/react";
import * as React from "react";

import type { Taxonomy } from "$app/utils/discover";

import { CurrentSellerProvider, parseCurrentSeller } from "$app/components/CurrentSeller";
import { Layout as DiscoverLayout } from "$app/components/Discover/Layout";
import { LoggedInUserProvider, parseLoggedInUser } from "$app/components/LoggedInUser";
import { Layout as ProductLayout, type Props as ProductLayoutProps } from "$app/components/Product/Layout";
import Alert from "$app/components/server-components/Alert";
import AppWrapper, { type GlobalProps } from "$app/inertia/app_wrapper";
import { configureClientRoutes } from "$app/inertia/configure_client_routes";

type NativeProductGlobalProps = GlobalProps & {
  current_seller?: unknown;
  logged_in_user?: unknown;
};

export type NativeProductRscPageProps = ProductLayoutProps & {
  global: NativeProductGlobalProps;
  taxonomy_path: string | null;
  taxonomies_for_nav: Taxonomy[];
};

export default function NativeProductRscPage({
  global,
  taxonomy_path: taxonomyPath,
  taxonomies_for_nav: taxonomiesForNav,
  ...productProps
}: NativeProductRscPageProps) {
  React.useEffect(() => configureClientRoutes(global.domain_settings), [global.domain_settings]);

  const inertiaPage: Page = {
    component: "links/rsc_show",
    props: { ...global, ...productProps, errors: {} },
    url: global.href,
    version: null,
    rescuedProps: [],
    flash: {},
    rememberedState: {},
  };

  return (
    <InertiaApp initialPage={inertiaPage} initialComponent={() => null} resolveComponent={() => () => null}>
      {() => (
        <AppWrapper global={global}>
          <LoggedInUserProvider value={parseLoggedInUser(global.logged_in_user ?? null)}>
            <CurrentSellerProvider value={parseCurrentSeller(global.current_seller ?? null)}>
              <Alert initial={null} />
              <DiscoverLayout
                taxonomyPath={taxonomyPath ?? undefined}
                taxonomiesForNav={taxonomiesForNav}
                forceDomain
              >
                <ProductLayout cart hasHero {...productProps} />
              </DiscoverLayout>
            </CurrentSellerProvider>
          </LoggedInUserProvider>
        </AppWrapper>
      )}
    </InertiaApp>
  );
}
