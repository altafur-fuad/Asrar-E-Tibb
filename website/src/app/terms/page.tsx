import React from 'react';
import Link from 'next/link';
import { FileText, ArrowLeft } from 'lucide-react';

export default function TermsPage() {
  return (
    <div style={{ padding: '60px 0 96px' }}>
      <div className="container" style={{ maxWidth: '820px' }}>
        <Link
          href="/"
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            color: 'var(--color-forest-green)',
            fontWeight: 600,
            fontSize: '0.92rem',
            marginBottom: '32px'
          }}
        >
          <ArrowLeft size={18} />
          <span>Return to Homepage</span>
        </Link>

        <div className="card" style={{ padding: '48px 40px', background: 'var(--color-white)', borderRadius: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
            <FileText size={26} color="var(--color-forest-green)" />
            <span className="pill pill-green">Legal Agreement</span>
          </div>

          <h1 style={{ fontSize: '2.4rem', color: 'var(--color-forest-green)', marginBottom: '16px' }}>
            Terms of Service
          </h1>
          <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)', marginBottom: '32px' }}>
            Last revised: October 2026 • Asrar-e-Tibb Healthcare Platform
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', fontSize: '0.95rem', lineHeight: 1.7, color: 'var(--color-deep-ink)' }}>
            <section>
              <h2 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                1. Informational & Educational Scope
              </h2>
              <p>
                Asrar-e-Tibb provides access to registered pharmaceutical formulations, indications, dosages, and classical health principles strictly for informational reference. It is not an automated doctor or prescription dispensing engine.
              </p>
            </section>

            <section>
              <h2 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                2. Professional Clinical Judgment
              </h2>
              <p>
                Patients must never initiate, alter, or discontinue prescribed pharmacotherapy solely based on information displayed on this website. Always consult a licensed physician or pharmacist.
              </p>
            </section>

            <section>
              <h2 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                3. APK Distribution & Integrity
              </h2>
              <p>
                The Android application binary is distributed strictly through versioned GitHub Releases with verified SHA-256 hashes. Users assume responsibility when side-loading APKs onto Android hardware.
              </p>
            </section>
          </div>
        </div>
      </div>
    </div>
  );
}

