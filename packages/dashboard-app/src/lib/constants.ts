import branding from "../../../../branding.json";

// Product name and links come from branding.json, like tab_util::branding in Rust
export const PRODUCT_NAME = branding.productName;
export const CLI_BINARY_NAME = "tab";

export const USER_MANUAL_URL = branding.links.userManual;
export const AUTOCOMPLETE_WIKI_URL = branding.links.userManualAutocomplete;

export const NOTIFICATIONS_SEEN_STATE_KEY = "dashboard.notificationsSeen";
