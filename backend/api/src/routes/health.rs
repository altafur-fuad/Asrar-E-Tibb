use axum::{extract::State, Json};
use chrono::Utc;
use std::sync::Arc;
use crate::{config::AppConfig, models::HealthResponse};

pub async fn health_check(
    State(_config): State<Arc<AppConfig>>,
) -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "healthy".to_string(),
        service: "asrar-e-tibb-api".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        timestamp: Utc::now().to_rfc3339(),
    })
}
