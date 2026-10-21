use axum::{
    extract::State,
    http::{header, HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;
use crate::{
    config::AppConfig,
    error::ApiError,
    models::AndroidReleaseResponse,
};

/// GET /api/v1/app/android/latest
/// Returns documented release metadata for the latest Android APK
pub async fn get_latest_android_release(
    State(config): State<Arc<AppConfig>>,
) -> Json<AndroidReleaseResponse> {
    Json(AndroidReleaseResponse {
        available: config.apk_available,
        version: config.apk_version.clone(),
        version_code: config.apk_version_code,
        release_date: config.apk_release_date.clone(),
        apk_filename: config.apk_filename.clone(),
        download_url: config.apk_download_url.clone(),
        sha256_checksum: config.apk_sha256.clone(),
        file_size_bytes: config.apk_file_size_bytes,
        release_notes: config.apk_release_notes.clone(),
        min_android_version: config.min_android_version.clone(),
        fallback_url: config.github_releases_url.clone(),
    })
}

/// GET /api/v1/app/android/download
/// Validates and securely redirects clients directly to the official GitHub Release asset.
/// Prevents open redirects by enforcing strict HTTPS and verified hostname whitelisting.
pub async fn download_android_release(
    State(config): State<Arc<AppConfig>>,
) -> Result<Response, ApiError> {
    if !config.apk_available {
        return Err(ApiError::ReleaseNotAvailable);
    }

    let download_url = &config.apk_download_url;

    // Strict URL parsing and hostname security check
    let parsed_url = match url::Url::parse(download_url) {
        Ok(u) => u,
        Err(e) => return Err(ApiError::InvalidRedirectUrl(format!("Parse error: {}", e))),
    };

    // 1. Enforce HTTPS only
    if parsed_url.scheme() != "https" {
        return Err(ApiError::InvalidRedirectUrl(
            "Security violation: Plaintext HTTP downloads are rejected".to_string(),
        ));
    }

    // 2. Enforce Host Whitelist
    let host = parsed_url.host_str().unwrap_or("");
    let is_allowed_host = config
        .allowed_redirect_hosts
        .iter()
        .any(|allowed| host.eq_ignore_ascii_case(allowed) || host.ends_with(&format!(".{}", allowed)));

    if !is_allowed_host {
        return Err(ApiError::InvalidRedirectUrl(format!(
            "Untrusted release host '{}' rejected. Downloads must originate from official repository assets.",
            host
        )));
    }

    // 3. Issue Temporary Redirect (HTTP 307)
    let mut headers = HeaderMap::new();
    headers.insert(
        header::LOCATION,
        header::HeaderValue::from_str(download_url)
            .map_err(|e| ApiError::InternalServerError(e.to_string()))?,
    );
    headers.insert(
        header::CACHE_CONTROL,
        header::HeaderValue::from_static("no-cache, no-store, must-revalidate"),
    );

    Ok((StatusCode::TEMPORARY_REDIRECT, headers).into_response())
}
