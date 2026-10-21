import React from 'react';
import Link from 'next/link';
import { FileText, Sparkles, ShieldCheck, ArrowLeft, Clock, CheckCircle } from 'lucide-react';

export default function PrescriptionUploadPage() {
  return (
    <div style={{ padding: '60px 0 96px' }}>
      <div className="container" style={{ maxWidth: '800px', textAlign: 'center' }}>
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

        <div className="card" style={{
          padding: '48px 36px',
          background: 'var(--color-white)',
          borderRadius: '24px',
          boxShadow: 'var(--shadow-lg)'
        }}>
          <div style={{
            width: '72px',
            height: '72px',
            borderRadius: '20px',
            background: 'var(--color-soft-sage)',
            color: 'var(--color-forest-green)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 20px'
          }}>
            <FileText size={36} />
          </div>

          <div style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            padding: '4px 14px',
            borderRadius: 'var(--radius-full)',
            background: '#FEF3C7',
            color: '#92400E',
            fontSize: '0.8rem',
            fontWeight: 700,
            textTransform: 'uppercase',
            marginBottom: '16px'
          }}>
            <Clock size={14} />
            <span>Under Clinical Architecture Review • Milestone 7</span>
          </div>

          <h1 style={{ fontSize: '2.2rem', color: 'var(--color-forest-green)', marginBottom: '14px' }}>
            AI Prescription OCR & Digitization
          </h1>

          <p style={{ fontSize: '1.05rem', color: 'var(--color-muted)', lineHeight: 1.6, maxWidth: '600px', margin: '0 auto 32px' }}>
            We are actively engineering an offline-first computer vision model to digitize handwritten doctor prescriptions into verified medicine directory schedules and dosage reminders.
          </p>

          <div style={{
            background: 'var(--color-warm-ivory)',
            border: '1px solid var(--color-border)',
            borderRadius: '16px',
            padding: '24px',
            textAlign: 'left',
            marginBottom: '32px'
          }}>
            <h4 style={{ fontSize: '1rem', marginBottom: '14px', color: 'var(--color-forest-green)' }}>
              Engineering Standards Being Implemented:
            </h4>
            <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.9rem', color: 'var(--color-deep-ink)' }}>
              <li style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <CheckCircle size={18} color="var(--color-fresh-green)" />
                <span>Zero cloud image caching without explicit patient biometric authorization.</span>
              </li>
              <li style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <CheckCircle size={18} color="var(--color-fresh-green)" />
                <span>Automated cross-referencing against the 21,716 verified medicine registry.</span>
              </li>
              <li style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <CheckCircle size={18} color="var(--color-fresh-green)" />
                <span>Mandatory licensed pharmacist verification before any auto-dispensing.</span>
              </li>
            </ul>
          </div>

          <Link href="/medicines" className="btn btn-primary">
            <span>Browse Medicine Directory Instead</span>
          </Link>
        </div>
      </div>
    </div>
  );
}

