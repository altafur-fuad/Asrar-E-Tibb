use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use chrono::Utc;
use serde_json::json;

#[derive(Debug)]
pub enum ApiError {
    ReleaseNotAvailable,
    InvalidRedirectUrl(String),
    InternalServerError(String),
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        let (status, code, message) = match self {
            ApiError::ReleaseNotAvailable => (
                StatusCode::NOT_FOUND,
                "APK_RELEASE_NOT_AVAILABLE",
                "No official Android APK release is currently published for download.".to_string(),
            ),
            ApiError::InvalidRedirectUrl(details) => (
                StatusCode::BAD_REQUEST,
                "INVALID_REDIRECT_TARGET",
                format!("The configured release URL failed domain verification: {}", details),
            ),
            ApiError::InternalServerError(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "INTERNAL_SERVER_ERROR",
                err,
            ),
        };

        let body = Json(json!({
            "error": code,
            "message": message,
            "timestamp": Utc::now().to_rfc3339()
        }));

        (status, body).into_response()
    }
}
