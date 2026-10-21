import React from 'react';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import {
  ArrowLeft,
  Building2,
  FileText,
  AlertCircle,
  CheckCircle2,
  ShoppingBag,
  Sparkles,
  ShieldAlert
} from 'lucide-react';
import { MedicineImageBadge } from '../../../components/MedicineImageBadge';
import rawMedicines from '../../../data/medicines.json';

interface Props {
  params: {
    id: string;
  };
}

export function generateStaticParams() {
  // Pre-generate top 100 medicine paths for fast static rendering
  return rawMedicines.slice(0, 100).map((med: any) => ({
    id: med.slug,
  }));
}

export default function MedicineDetailPage({ params }: Props) {
  const medicine = (rawMedicines as any[]).find(
    (m) => m.slug === params.id || m.id.toString() === params.id
  );

  if (!medicine) {
    notFound();
  }

  return (
    <div style={{ padding: '48px 0 80px' }}>
      <div className="container">
        {/* Back Link */}
        <Link
          href="/medicines"
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            color: 'var(--color-forest-green)',
            fontWeight: 600,
            fontSize: '0.92rem',
            marginBottom: '28px'
          }}
        >
          <ArrowLeft size={18} />
          <span>Back to Medicine Directory</span>
        </Link>

        {/* Hero Card */}
        <div className="card" style={{
          padding: '40px',
          background: 'var(--color-white)',
          marginBottom: '32px'
        }}>
          <div style={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'flex-start',
            justifyContent: 'space-between',
            gap: '32px'
          }}>
            <div style={{ display: 'flex', gap: '24px', alignItems: 'flex-start' }}>
              <MedicineImageBadge dosageForm={medicine.dosage_form} size="lg" />

              <div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '8px' }}>
                  <span className="pill pill-green">
                    {medicine.dosage_form}
                  </span>
                  <span className="pill pill-outline">
                    {medicine.type}
                  </span>
                </div>

                <h1 style={{ fontSize: '2.4rem', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                  {medicine.name}
                </h1>

                <p style={{ fontSize: '1.2rem', color: 'var(--color-muted)', fontWeight: 600, marginBottom: '12px' }}>
                  {medicine.generic} {medicine.strength && `• ${medicine.strength}`}
                </p>

                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#64748B', fontSize: '0.95rem' }}>
                  <Building2 size={18} />
                  <span>Manufactured by: <strong>{medicine.manufacturer}</strong></span>
                </div>
              </div>
            </div>

            {/* Price Box */}
            <div style={{
              background: 'var(--color-soft-sage)',
              padding: '24px',
              borderRadius: 'var(--radius-lg)',
              minWidth: '240px',
              border: '1px solid var(--color-border)'
            }}>
              <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
                Official Package Price
              </span>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                {medicine.price}
              </div>
              <p style={{ fontSize: '0.82rem', color: 'var(--color-muted)', marginBottom: '16px', lineHeight: 1.4 }}>
                {medicine.package_container || 'Standard dispensing unit'}
              </p>
              <Link
                href={`/farmacia?add=${medicine.id}`}
                className="btn btn-primary"
                style={{ width: '100%', display: 'flex', justifyContent: 'center' }}
              >
                <ShoppingBag size={18} />
                <span>Buy on Farmacia</span>
              </Link>
            </div>
          </div>
        </div>

        {/* Clinical Specs Grid */}
        <div className="grid-2" style={{ gap: '28px', marginBottom: '40px' }}>
          {/* Indications & Class */}
          <div className="card" style={{ padding: '32px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '18px' }}>
              <FileText size={22} color="var(--color-forest-green)" />
              <h2 style={{ fontSize: '1.35rem' }}>Therapeutic Classification & Indications</h2>
            </div>

            <div style={{ marginBottom: '20px' }}>
              <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
                Pharmacological Drug Class
              </span>
              <p style={{ fontSize: '1.05rem', fontWeight: 600, color: 'var(--color-deep-ink)' }}>
                {medicine.drug_class || 'Allopathic therapeutic category'}
              </p>
            </div>

            <div>
              <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
                Clinical Indications & Target Conditions
              </span>
              <p style={{ fontSize: '0.98rem', color: 'var(--color-deep-ink)', lineHeight: 1.6 }}>
                {medicine.indication || 'Indications vary according to patient condition and physician evaluation. Consult an authorized clinician before use.'}
              </p>
            </div>
          </div>

          {/* Dosage & Packaging Specifications */}
          <div className="card" style={{ padding: '32px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '18px' }}>
              <Sparkles size={22} color="var(--color-forest-green)" />
              <h2 style={{ fontSize: '1.35rem' }}>Dispensing Specifications</h2>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '20px' }}>
              <div>
                <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block' }}>Dosage Form</span>
                <span style={{ fontSize: '0.98rem', fontWeight: 600 }}>{medicine.dosage_form}</span>
              </div>
              <div>
                <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block' }}>Formulation Strength</span>
                <span style={{ fontSize: '0.98rem', fontWeight: 600 }}>{medicine.strength || 'Standard'}</span>
              </div>
              <div>
                <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block' }}>Packaging Container</span>
                <span style={{ fontSize: '0.98rem', fontWeight: 600 }}>{medicine.package_container || 'Sealed blister / bottle'}</span>
              </div>
              <div>
                <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block' }}>Clinical Registry ID</span>
                <span style={{ fontSize: '0.98rem', fontWeight: 600 }}>#{medicine.id}</span>
              </div>
            </div>

            <div style={{
              background: '#FFFBEB',
              border: '1px solid #FDE68A',
              borderRadius: '8px',
              padding: '12px 16px',
              display: 'flex',
              alignItems: 'flex-start',
              gap: '10px'
            }}>
              <AlertCircle size={18} color="#D97706" style={{ flexShrink: 0, marginTop: '2px' }} />
              <span style={{ fontSize: '0.82rem', color: '#92400E', lineHeight: 1.5 }}>
                Prescription verification is legally required before pharmaceutical dispatch.
              </span>
            </div>
          </div>
        </div>

        {/* Clinical Disclaimer Box */}
        <div style={{
          background: 'var(--color-soft-sage)',
          borderRadius: 'var(--radius-lg)',
          padding: '28px',
          border: '1px solid var(--color-border)',
          display: 'flex',
          alignItems: 'flex-start',
          gap: '16px'
        }}>
          <ShieldAlert size={26} color="var(--color-forest-green)" style={{ flexShrink: 0 }} />
          <div>
            <h4 style={{ fontSize: '1.05rem', color: 'var(--color-forest-green)', marginBottom: '4px' }}>
              Evidence-Based Practice Notice
            </h4>
            <p style={{ fontSize: '0.88rem', color: 'var(--color-deep-ink)', lineHeight: 1.6 }}>
              All indications, drug classes, and strengths for <strong>{medicine.name}</strong> are compiled directly from manufacturer filings. Asrar-e-Tibb does not endorse self-medication. Do not discontinue or adjust prescribed doses without direct medical supervision.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

