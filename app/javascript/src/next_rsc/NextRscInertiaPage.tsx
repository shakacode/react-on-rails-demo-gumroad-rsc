"use client";

import type { Page } from "@inertiajs/core";
import { App as InertiaApp, router } from "@inertiajs/react";
import React, { createElement, useEffect } from "react";

import AdminAppWrapper, { type GlobalProps as AdminGlobalProps } from "$app/inertia/admin_app_wrapper";
import AppWrapper, { type GlobalProps } from "$app/inertia/app_wrapper";
import { configureClientRoutes } from "$app/inertia/configure_client_routes";
import type { PageComponent } from "$app/inertia/resolve_page_component";
import Layout, { LoggedInUserLayout, PublicLayout } from "$app/inertia/layout";
import AdminLayoutComponent from "$app/layouts/Admin";

const tsxPages = require.context("../../pages", true, /\.tsx$/, "sync");
const jsxPages = require.context("../../pages", true, /\.jsx$/, "sync");

router.on("before", (event) => {
  const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
  if (token) event.detail.visit.headers = { ...event.detail.visit.headers, "X-CSRF-Token": token };
});

router.on("invalid", (event) => {
  event.preventDefault();
  window.location.href = event.detail.response.request.responseURL || window.location.href;
});

type Props = {
  page: Page<GlobalProps | AdminGlobalProps>;
  admin: boolean;
};

const loadPage = (name: string): PageComponent => {
  const request = [`./${name}.tsx`, `./${name}.jsx`].find(
    (candidate) => tsxPages.keys().includes(candidate) || jsxPages.keys().includes(candidate),
  );
  if (!request) throw new Error(`Next RSC page component not found: ${name}`);

  const module = request.endsWith(".tsx") ? tsxPages(request) : jsxPages(request);
  if (!module?.default) throw new Error(`Invalid Next RSC page component: ${name}`);
  return module.default as PageComponent;
};

const assignLayout = (page: PageComponent, admin: boolean) => {
  if (admin) {
    page.layout ||= (children) => createElement(AdminLayoutComponent, { children });
  } else if ("publicLayout" in page && page.publicLayout) {
    page.layout ||= (children) => createElement(PublicLayout, { children });
  } else if ("loggedInUserLayout" in page && page.loggedInUserLayout) {
    page.layout ||= (children) => createElement(LoggedInUserLayout, { children });
  } else {
    page.layout ||= (children) => createElement(Layout, { children });
  }
  return page;
};

export default function NextRscInertiaPage({ page, admin }: Props) {
  const component = assignLayout(loadPage(page.component), admin);
  const global = page.props;

  useEffect(() => configureClientRoutes(global.domain_settings), [global.domain_settings]);

  const app = (
    <InertiaApp
      initialPage={page}
      initialComponent={component}
      resolveComponent={(name) => Promise.resolve(assignLayout(loadPage(name), admin))}
    />
  );

  return admin ? (
    <AdminAppWrapper global={global as AdminGlobalProps}>{app}</AdminAppWrapper>
  ) : (
    <AppWrapper global={global as GlobalProps}>{app}</AppWrapper>
  );
}
