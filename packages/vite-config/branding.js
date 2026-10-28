// Types are in branding.d.ts.

import { readFileSync } from "node:fs";

const branding = JSON.parse(
  readFileSync(new URL("../../branding.json", import.meta.url), "utf8"),
);

export function htmlBrandingPlugin() {
  return {
    name: "html-branding",
    transformIndexHtml: (html) =>
      html.replaceAll("%PRODUCT_NAME%", branding.productName),
  };
}
