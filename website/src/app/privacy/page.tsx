import React from 'react';
import Link from 'next/link';
import { ShieldCheck, ArrowLeft, Lock } from 'lucide-react';

export default function PrivacyPolicyPage() {
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
            <Lock size={26} color="var(--color-forest-green)" />
            <span className="pill pill-green">Privacy & Security Standards</span>
          </div>

          <h1 style={{ fontSize: '2.4rem', color: 'var(--color-forest-green)', marginBottom: '16px' }}>
            Privacy Policy
          </h1>
          <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)', marginBottom: '32px' }}>
            Last revised: October 2026 • Asrar-e-Tibb Healthcare Engineering
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', fontSize: '0.95rem', lineHeight: 1.7, color: 'var(--color-deep-ink)' }}>
            <section>
              <h2 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                1. Ethical Data Collection Principles
              </h2>
              <p>
                Asrar-e-Tibb is engineered to protect patient autonomy. We do not sell, rent, or trade your medical search queries, prescription uploads, or personal reminder data to advertisers, insurance brokers, or data brokers.
              </p>
            </section>

            <section>
              <h2 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                2. Database Row-Level Security (RLS)
              </h2>
              <p>
                All personal schedules, clinical notes, and private health indicators are isolated using PostgreSQL Row-Level Security policies. Only the authenticated user owning the record possesses decryption and read authorization.
              </p>
            </section>

            <section>
              <h2 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                3. Anonymous Browsing
              </h2>
              <p>
                Browsing the 21,700+ medicine directory, reading TibbNews, and comparing drug indications does not require account creation, cookies, or personal tracking.
              </p>
            </section>
          </div>
        </div>
      </div>
    </div>
  );
}

