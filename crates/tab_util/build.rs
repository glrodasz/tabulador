//! Generates the branding constants from `branding.json` at the repo root, the single source for
//! the product name and project links.

use std::path::PathBuf;
use std::{
    env,
    fs,
};

fn main() {
    let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let branding_path = manifest_dir.join("../../branding.json");
    println!("cargo:rerun-if-changed={}", branding_path.display());

    let branding: serde_json::Value = serde_json::from_str(&fs::read_to_string(&branding_path).unwrap()).unwrap();
    let field = |pointer: &str| {
        branding
            .pointer(pointer)
            .and_then(|value| value.as_str())
            .unwrap_or_else(|| panic!("branding.json is missing {pointer}"))
    };

    let product_name = field("/productName");
    let generated = format!(
        r#"pub const PRODUCT_NAME: &str = {product_name:?};
pub const APP_BUNDLE_NAME: &str = {app_bundle_name:?};
pub const AUTOCOMPLETE_WINDOW_TITLE: &str = {autocomplete_window_title:?};
pub const REPOSITORY_URL: &str = {repository:?};
pub const ISSUES_URL: &str = {issues:?};
pub const USER_MANUAL_URL: &str = {user_manual:?};
pub const USER_MANUAL_SSH_URL: &str = {user_manual_ssh:?};
"#,
        app_bundle_name = format!("{product_name}.app"),
        autocomplete_window_title = format!("{product_name} Autocomplete"),
        repository = field("/repository"),
        issues = field("/links/issues"),
        user_manual = field("/links/userManual"),
        user_manual_ssh = field("/links/userManualSsh"),
    );

    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap()).join("branding.rs");
    fs::write(out_path, generated).unwrap();
}
