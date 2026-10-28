import type { Plugin } from "vite";

/**
 * Replaces %PRODUCT_NAME% in index.html with the product name from
 * branding.json at the repo root.
 */
export declare function htmlBrandingPlugin(): Plugin;
