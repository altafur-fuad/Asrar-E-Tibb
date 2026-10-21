'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import {
  Download,
  Smartphone,
  ShieldCheck,
  FileCheck,
  Copy,
  Check,
  AlertTriangle,
  ExternalLink,
  ChevronRight,
  Sparkles,
  Layers,
  Clock
} from 'lucide-react';
import { fetchLatestAndroidRelease, AndroidReleaseMetadata } from '../../lib/api';

export default function DownloadAppPage() {
  const [release, setRelease] = useState<AndroidReleaseMetadata | null>(null);
  const [copied, setCopied] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchLatestAndroidRelease().then((data) => {
      setRelease(data);
      setLoading(false);
    });
  }, []);

  const copyChecksum = () => {
    if (release?.sha256_checksum) {
      navigator.clipboard.writeText(release.sha256_checksum);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    }
  };

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return '28.4 MB';
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  };

  return (
    <div style={{ padding: '56px 0 96px' }}>
      <div className="container" style={{ maxWidth: '960px' }}>
        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <div style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            padding: '6px 16px',
            borderRadius: 'var(--radius-full)',
            background: 'var(--color-soft-sage)',
            color: 'var(--color-forest-green)',
            fontSize: '0.82rem',
            fontWeight: 700,
            textTransform: 'uppercase',
            marginBottom: '16px'
          }}>
            <Smartphone size={16} />
            <span>Official Mobile Distribution</span>
          </div>

          <h1 style={{ fontSize: 'clamp(2.2rem, 4vw, 3rem)', color: 'var(--color-forest-green)', marginBottom: '14px' }}>
            Download Asrar-e-Tibb for Android
          </h1>

          <p style={{ fontSize: '1.12rem', color: 'var(--color-muted)', maxWidth: '680px', margin: '0 auto', lineHeight: 1.6 }}>
            Install the native Android application for seamless offline medicine lookups, daily reminder alerts, symptom journaling, and healthcare intelligence.
          </p>
        </div>

        {/* Release Download Card */}
        <div className="card" style={{
          padding: '40px',
          background: 'var(--color-white)',
          boxShadow: 'var(--shadow-lg)',
          border: '2px solid var(--color-border)',
          borderRadius: '24px',
          marginBottom: '40px'
        }}>
          {loading ? (
            <div style={{ textAlign: 'center', padding: '40px', color: 'var(--color-muted)' }}>
              Checking latest release assets...
            </div>
          ) : release && release.available ? (
            <div>
              <div style={{
                display: 'flex',
                flexWrap: 'wrap',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: '16px',
                paddingBottom: '24px',
                borderBottom: '1px solid var(--color-border)',
                marginBottom: '28px'
              }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '6px' }}>
                    <span className="pill pill-green" style={{ fontSize: '0.82rem', padding: '6px 14px' }}>
                      Version {release.version} (Build #{release.version_code})
                    </span>
                    <span className="pill pill-outline" style={{ fontSize: '0.78rem' }}>
                      Production Release
                    </span>
                  </div>
                  <span style={{ fontSize: '0.85rem', color: 'var(--color-muted)' }}>
                    Released: {release.release_date} • Target: {release.min_android_version}
                  </span>
                </div>

                <div style={{ textAlign: 'right' }}>
                  <span style={{ fontSize: '0.8rem', color: 'var(--color-muted)', display: 'block' }}>Package Size</span>
                  <span style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--color-forest-green)' }}>
                    {formatFileSize(release.file_size_bytes)}
                  </span>
                </div>
              </div>

              {/* Release Notes */}
              <div style={{ marginBottom: '28px' }}>
                <h3 style={{ fontSize: '1.1rem', marginBottom: '8px' }}>Release Notes</h3>
                <p style={{ fontSize: '0.95rem', color: 'var(--color-deep-ink)', lineHeight: 1.6 }}>
                  {release.release_notes}
                </p>
              </div>

              {/* SHA-256 Checksum Box */}
              <div style={{
                background: 'var(--color-warm-ivory)',
                padding: '18px 20px',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--color-border)',
                marginBottom: '32px'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.82rem', fontWeight: 700, color: 'var(--color-forest-green)' }}>
                    <FileCheck size={16} />
                    <span>Cryptographic Verification (SHA-256 Checksum):</span>
                  </div>
                  <button
                    onClick={copyChecksum}
                    className="btn btn-secondary btn-sm"
                    style={{ padding: '4px 10px', fontSize: '0.78rem' }}
                  >
                    {copied ? <Check size={14} color="green" /> : <Copy size={14} />}
                    <span>{copied ? 'Copied' : 'Copy'}</span>
                  </button>
                </div>
                <code style={{
                  fontFamily: 'monospace',
                  fontSize: '0.8rem',
                  color: 'var(--color-muted)',
                  wordBreak: 'break-all',
                  display: 'block'
                }}>
                  {release.sha256_checksum}
                </code>
              </div>

              {/* Download Buttons */}
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px', alignItems: 'center' }}>
                <a
                  href={release.download_url}
                  className="btn btn-primary btn-lg"
                  style={{ flex: 1, minWidth: '240px' }}
                >
                  <Download size={20} />
                  <span>Download {release.apk_filename}</span>
                </a>

                <a
                  href={release.fallback_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn btn-secondary btn-lg"
                  style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
                >
                  <span>View GitHub Releases</span>
                  <ExternalLink size={16} />
                </a>
              </div>
            </div>
          ) : (
            <div style={{ textAlign: 'center', padding: '40px 20px' }}>
              <AlertTriangle size={48} color="var(--color-restrained-amber)" style={{ margin: '0 auto 16px' }} />
              <h3 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>No Official Release Published Yet</h3>
              <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem', marginBottom: '24px', maxWidth: '520px', margin: '0 auto 24px' }}>
                An official production APK has not yet been attached to a GitHub Release. You can monitor the repository releases page for new tags.
              </p>
              <a
                href={release?.fallback_url || 'https://github.com/altafur-fuad/Asrar-E-Tibb/releases'}
                target="_blank"
                rel="noopener noreferrer"
                className="btn btn-secondary"
              >
                Open GitHub Releases Page
              </a>
            </div>
          )}
        </div>

        {/* Installation Instructions */}
        <div className="card" style={{ padding: '36px', background: 'var(--color-white)', marginBottom: '32px' }}>
          <h2 style={{ fontSize: '1.45rem', marginBottom: '20px' }}>
            How to Install on Your Android Device
          </h2>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div style={{ display: 'flex', gap: '16px', alignItems: 'flex-start' }}>
              <div style={{
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                background: 'var(--color-soft-sage)',
                color: 'var(--color-forest-green)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700,
                flexShrink: 0
              }}>
                1
              </div>
              <div>
                <h4 style={{ fontSize: '1.02rem', marginBottom: '2px' }}>Download the APK file</h4>
                <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)' }}>
                  Click the &quot;Download Asrar-E-Tibb.apk&quot; button above directly on your Android phone or tablet.
                </p>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '16px', alignItems: 'flex-start' }}>
              <div style={{
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                background: 'var(--color-soft-sage)',
                color: 'var(--color-forest-green)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700,
                flexShrink: 0
              }}>
                2
              </div>
              <div>
                <h4 style={{ fontSize: '1.02rem', marginBottom: '2px' }}>Allow Installation from this Source</h4>
                <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)' }}>
                  If prompted by Android, go to <strong>Settings → Security / Privacy → Install unknown apps</strong> and allow your browser (e.g. Chrome) to install APK files.
                </p>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '16px', alignItems: 'flex-start' }}>
              <div style={{
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                background: 'var(--color-soft-sage)',
                color: 'var(--color-forest-green)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700,
                flexShrink: 0
              }}>
                3
              </div>
              <div>
                <h4 style={{ fontSize: '1.02rem', marginBottom: '2px' }}>Open and Launch</h4>
                <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)' }}>
                  Tap the downloaded file from your Notifications or Downloads folder, confirm &quot;Install&quot;, and launch Asrar-e-Tibb.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Security Guidance Box */}
        <div style={{
          background: 'var(--color-soft-sage)',
          borderRadius: '16px',
          padding: '24px',
          border: '1px solid var(--color-border)',
          display: 'flex',
          alignItems: 'flex-start',
          gap: '14px'
        }}>
          <ShieldCheck size={24} color="var(--color-forest-green)" style={{ flexShrink: 0 }} />
          <div>
            <h4 style={{ fontSize: '1rem', color: 'var(--color-forest-green)', marginBottom: '4px' }}>
              Official Security Advisory
            </h4>
            <p style={{ fontSize: '0.88rem', color: 'var(--color-deep-ink)', lineHeight: 1.5 }}>
              Only install Asrar-e-Tibb APK binaries originating from official GitHub Releases at <strong>github.com/altafur-fuad/Asrar-E-Tibb</strong>. Never download APK files from unauthorized third-party file sharing websites.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

