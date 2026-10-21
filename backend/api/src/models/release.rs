use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HealthResponse {
    pub status: String,
    pub service: String,
    pub version: String,
    pub timestamp: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AndroidReleaseResponse {
    pub available: bool,
    pub version: String,
    pub version_code: u32,
    pub release_date: String,
    pub apk_filename: String,
    pub download_url: String,
    pub sha256_checksum: String,
    pub file_size_bytes: Option<u64>,
    pub release_notes: String,
    pub min_android_version: String,
    pub fallback_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorResponse {
    pub error: String,
    pub message: String,
    pub timestamp: String,
}
