/**
 * Asrar-e-Tibb: Client API Utilities
 * Interfaces with Rust Axum release metadata endpoint or GitHub Releases fallback
 */

export interface AndroidReleaseMetadata {
  available: boolean;
  version: string;
  version_code: number;
  release_date: string;
  apk_filename: string;
  download_url: string;
  sha256_checksum: string;
  file_size_bytes?: number;
  release_notes: string;
  min_android_version: string;
  fallback_url: string;
}

const DEFAULT_RELEASE: AndroidReleaseMetadata = {
  available: true,
  version: '1.0.0',
  version_code: 1,
  release_date: 'October 2026',
  apk_filename: 'Asrar-E-Tibb.apk',
  download_url: 'https://github.com/altafur-fuad/Asrar-E-Tibb/releases/latest/download/Asrar-E-Tibb.apk',
  sha256_checksum: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  file_size_bytes: 28450120,
  release_notes: 'Initial production-ready release of Asrar-e-Tibb Android Application. Includes modernized UI, verified 21,700+ medicine directory, hardware back-navigation fixes, and PostgreSQL Row-Level Security client protections.',
  min_android_version: 'Android 5.0 (API Level 21) or higher',
  fallback_url: 'https://github.com/altafur-fuad/Asrar-E-Tibb/releases'
};

export async function fetchLatestAndroidRelease(): Promise<AndroidReleaseMetadata> {
  const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL;

  if (apiBase) {
    try {
      const res = await fetch(`${apiBase}/api/v1/app/android/latest`, {
        next: { revalidate: 60 } // cache for 1 minute
      });
      if (res.ok) {
        return await res.json();
      }
    } catch (err) {
      console.warn('Failed to fetch from Rust backend API, using configured fallback release metadata:', err);
    }
  }

  return DEFAULT_RELEASE;
}
