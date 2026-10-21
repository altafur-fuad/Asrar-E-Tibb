pub mod app_release;
pub mod health;

use axum::{routing::get, Router};
use std::sync::Arc;
use crate::config::AppConfig;

pub fn create_router(config: Arc<AppConfig>) -> Router {
    Router::new()
        // Health check endpoint
        .route("/healthz", get(health::health_check))
        // Android release endpoints
        .route("/api/v1/app/android/latest", get(app_release::get_latest_android_release))
        .route("/api/v1/app/android/download", get(app_release::download_android_release))
        .with_state(config)
}
