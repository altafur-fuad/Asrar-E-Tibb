use std::env;

#[derive(Debug, Clone)]
pub struct AppConfig {
    pub host: String,
    pub port: u16,
    pub allowed_origins: Vec<String>,
    pub apk_available: bool,
    pub apk_version: String,
    pub apk_version_code: u32,
    pub apk_release_date: String,
    pub apk_filename: String,
    pub apk_download_url: String,
    pub apk_sha256: String,
    pub apk_file_size_bytes: Option<u64>,
    pub apk_release_notes: String,
    pub min_android_version: String,
    pub github_releases_url: String,
    pub allowed_redirect_hosts: Vec<String>,
}

impl AppConfig {
    pub fn from_env() -> Self {
        let host = env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
        let port = env::var("PORT")
            .ok()
            .and_then(|p| p.parse::<u16>().ok())
            .unwrap_or(10000);

        let allowed_origins_str = env::var("CORS_ALLOWED_ORIGINS")
            .unwrap_or_else(|_| "*".to_string());
        let allowed_origins: Vec<String> = allowed_origins_str
            .split(',')
            .map(|s| s.trim().to_string())
            .filter(|s| !s.is_empty())
            .collect();

        let apk_available = env::var("APK_AVAILABLE")
            .map(|v| v.to_lowercase() == "true" || v == "1")
            .unwrap_or(true);

        let apk_version = env::var("APK_VERSION")
            .unwrap_or_else(|_| "1.0.0".to_string());

        let apk_version_code = env::var("APK_VERSION_CODE")
            .ok()
            .and_then(|v| v.parse::<u32>().ok())
            .unwrap_or(1);

        let apk_release_date = env::var("APK_RELEASE_DATE")
            .unwrap_or_else(|_| "October 2026".to_string());

        let apk_filename = env::var("APK_FILENAME")
            .unwrap_or_else(|_| "Asrar-E-Tibb.apk".to_string());

        let apk_download_url = env::var("APK_DOWNLOAD_URL").unwrap_or_else(|_| {
            "https://github.com/altafur-fuad/Asrar-E-Tibb/releases/latest/download/Asrar-E-Tibb.apk"
                .to_string()
        });

        let apk_sha256 = env::var("APK_SHA256").unwrap_or_else(|_| {
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855".to_string()
        });

        let apk_file_size_bytes = env::var("APK_FILE_SIZE_BYTES")
            .ok()
            .and_then(|v| v.parse::<u64>().ok())
            .or(Some(28450120));

        let apk_release_notes = env::var("APK_RELEASE_NOTES").unwrap_or_else(|_| {
            "Official production release of Asrar-e-Tibb Android Application with modernized UI, 21,700+ medicine directory, hardware back-navigation fixes, and PostgreSQL Row-Level Security client protections."
                .to_string()
        });

        let min_android_version = env::var("MIN_ANDROID_VERSION")
            .unwrap_or_else(|_| "Android 5.0 (API Level 21) or higher".to_string());

        let github_releases_url = env::var("GITHUB_RELEASES_URL").unwrap_or_else(|_| {
            "https://github.com/altafur-fuad/Asrar-E-Tibb/releases".to_string()
        });

        let allowed_redirect_hosts = vec![
            "github.com".to_string(),
            "objects.githubusercontent.com".to_string(),
            "raw.githubusercontent.com".to_string(),
        ];

        Self {
            host,
            port,
            allowed_origins,
            apk_available,
            apk_version,
            apk_version_code,
            apk_release_date,
            apk_filename,
            apk_download_url,
            apk_sha256,
            apk_file_size_bytes,
            apk_release_notes,
            min_android_version,
            github_releases_url,
            allowed_redirect_hosts,
        }
    }
}
