/**
 * Asrar-e-Tibb: Client API Utilities
 * Interfaces with Rust Axum release metadata endpoint or GitHub Releases fallback
 */

export interface AndroidReleaseMetadata {
  available: boolean;
  is_test_artifact?: boolean;
  version: string;
  version_code: number;
  release_date: string;
  apk_filename: string;
  download_url: string;
  artifact_download_url?: string;
  sha256_checksum: string;
  file_size_bytes?: number;
  release_notes: string;
  min_android_version: string;
  fallback_url: string;
}

const DEFAULT_RELEASE: AndroidReleaseMetadata = {
  available: false,
  is_test_artifact: true,
  version: '1.0.0',
  version_code: 1,
  release_date: 'October 2026',
  apk_filename: 'Asrar-E-Tibb.apk',
  download_url: 'https://github.com/altafur-fuad/Asrar-E-Tibb/releases/latest/download/Asrar-E-Tibb.apk',
  artifact_download_url: 'https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159/artifacts/12351955952',
  sha256_checksum: 'e8263faf3e06d67b1f6c83d56726611bb20c402dbcfec65a5753ef8b0b61f3ae',
  file_size_bytes: 66060288,
  release_notes: 'Cloud CI test build artifact from GitHub Actions run #39611963159. Modernized UI, 21,700+ medicine directory, and hardware back-navigation fixes. Official production release pending Supabase staging security review sign-off and official signing keystore.',
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
