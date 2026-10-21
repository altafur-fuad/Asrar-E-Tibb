import React from 'react';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import {
  ArrowLeft,
  BookOpen,
  Pill,
  ShieldAlert,
  ExternalLink,
  Layers,
  Sparkles,
  Info,
  CheckCircle2,
  AlertTriangle,
  Building2,
  ChevronRight
} from 'lucide-react';
import { getGenericBySlug, getMonographBySlug, getAllGenerics } from '../../../lib/medicines';
import { sanitizeClinicalHtml } from '../../../lib/sanitizeHtml';
import { MedicineImageBadge } from '../../../components/MedicineImageBadge';

interface Props {
  params: {
    slug: string;
  };
}

export const dynamic = 'auto';

export default function GenericDetailPage({ params }: Props) {
  const generic = getMonographBySlug(params.slug);

  if (!generic) {
    notFound();
  }

  // Clinical Monograph Sections to display
  const monographSections = [
    { title: 'Indications & Usage', content: generic.indication_description || generic.indication },
    { title: 'Therapeutic Class & Mechanism', content: generic.therapeutic_class_description || generic.drug_class },
    { title: 'Pharmacology & Pharmacodynamics', content: generic.pharmacology_description },
    { title: 'Dosage & Administration Regimen', content: generic.dosage_description },
    { title: 'Specific Administration Guidelines', content: generic.administration_description },
    { title: 'Adverse Reactions & Side Effects', content: generic.side_effects_description },
    { title: 'Contraindications', content: generic.contraindications_description },
    { title: 'Special Warnings & Precautions', content: generic.precautions_description },
    { title: 'Drug & Food Interactions', content: generic.interaction_description },
    { title: 'Pregnancy & Lactation Safety', content: generic.pregnancy_and_lactation_description },
    { title: 'Pediatric & Geriatric Usage', content: generic.pediatric_usage_description },
    { title: 'Overdose Effects & Management', content: generic.overdose_effects_description },
    { title: 'Reconstitution & Storage Conditions', content: generic.storage_conditions_description || generic.reconstitution_description }
  ].filter((s) => s.content && s.content.trim().length > 0);

  return (
    <div style={{ padding: '48px 0 88px' }}>
      <div className="container" style={{ maxWidth: '1100px' }}>
        {/* Navigation Breadcrumb */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.88rem', marginBottom: '24px' }}>
          <Link href="/medicines" style={{ color: 'var(--color-forest-green)', display: 'inline-flex', alignItems: 'center', gap: '6px', fontWeight: 600 }}>
            <ArrowLeft size={16} />
            <span>Medicine Directory</span>
          </Link>
          <ChevronRight size={14} color="var(--color-muted)" />
          <span style={{ color: 'var(--color-muted)' }}>Generic Monograph</span>
          <ChevronRight size={14} color="var(--color-muted)" />
          <span style={{ fontWeight: 600, color: 'var(--color-deep-ink)' }}>{generic.name}</span>
        </div>

        {/* Hero Card */}
        <div className="card" style={{
          padding: '40px',
          background: 'var(--color-white)',
          boxShadow: 'var(--shadow-md)',
          borderRadius: '24px',
          border: '1px solid var(--color-border)',
          marginBottom: '36px'
        }}>
          <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'flex-start', justifyContent: 'space-between', gap: '24px' }}>
            <div style={{ flex: 1, minWidth: '280px' }}>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '12px' }}>
                <span className="pill pill-green" style={{ fontSize: '0.82rem', padding: '6px 14px' }}>
                  Generic Monograph #{generic.id}
                </span>
                {generic.drug_class && (
                  <span className="pill pill-outline" style={{ fontSize: '0.82rem' }}>
                    {generic.drug_class}
                  </span>
                )}
              </div>

              <h1 style={{ fontSize: 'clamp(2rem, 4vw, 2.8rem)', color: 'var(--color-forest-green)', marginBottom: '12px' }}>
                {generic.name}
              </h1>

              {generic.indication && (
                <p style={{ fontSize: '1.12rem', color: 'var(--color-deep-ink)', lineHeight: 1.6, marginBottom: '20px' }}>
                  <strong>Key Indications:</strong> {generic.indication}
                </p>
              )}

              {generic.monograph_link && (
                <a
                  href={generic.monograph_link}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn btn-secondary btn-sm"
                  style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}
                >
                  <BookOpen size={16} />
                  <span>Official Prescribing Information</span>
                  <ExternalLink size={14} />
                </a>
              )}
            </div>

            {/* Quick Stats Pill */}
            <div style={{
              background: 'var(--color-soft-sage)',
              padding: '24px',
              borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--color-border)',
              textAlign: 'center',
              minWidth: '200px'
            }}>
              <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block' }}>
                Commercial Brands
              </span>
              <span style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--color-forest-green)', display: 'block', lineHeight: 1.2 }}>
                {generic.brand_count}
              </span>
              <span style={{ fontSize: '0.78rem', color: 'var(--color-deep-ink)' }}>
                Registered in Bangladesh
              </span>
            </div>
          </div>
        </div>

        {/* Content Layout: Brands Listing & Monograph */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '40px' }}>
          {/* Section: Linked Commercial Brands */}
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '20px' }}>
              <div>
                <h2 style={{ fontSize: '1.6rem', color: 'var(--color-forest-green)', marginBottom: '4px' }}>
                  Commercial Brands ({generic.brand_count})
                </h2>
                <p style={{ fontSize: '0.92rem', color: 'var(--color-muted)' }}>
                  All pharmaceutical preparations formulated with <strong>{generic.name}</strong> from licensed manufacturers.
                </p>
              </div>
            </div>

            {generic.brands && generic.brands.length > 0 ? (
              <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
                gap: '16px'
              }}>
                {generic.brands.map((brand) => (
                  <Link
                    key={brand.id}
                    href={`/medicines/${brand.slug}`}
                    className="card"
                    style={{
                      padding: '18px',
                      background: 'var(--color-white)',
                      border: '1px solid var(--color-border)',
                      borderRadius: 'var(--radius-lg)',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '14px',
                      textDecoration: 'none',
                      transition: 'transform 150ms ease, box-shadow 150ms ease'
                    }}
                  >
                    <MedicineImageBadge
                      dosageForm={brand.dosage_form}
                      brandName={brand.name}
                      size="sm"
                    />
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <h4 style={{ fontSize: '1.05rem', fontWeight: 700, color: 'var(--color-forest-green)', marginBottom: '2px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {brand.name}
                      </h4>
                      <p style={{ fontSize: '0.8rem', color: 'var(--color-muted)', margin: 0 }}>
                        {brand.dosage_form} {brand.strength && `• ${brand.strength}`}
                      </p>
                      <p style={{ fontSize: '0.75rem', color: '#64748B', margin: '2px 0 0', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {brand.manufacturer}
                      </p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      <span style={{ fontSize: '0.88rem', fontWeight: 700, color: 'var(--color-forest-green)', display: 'block' }}>
                        {brand.price}
                      </span>
                    </div>
                  </Link>
                ))}
              </div>
            ) : (
              <div className="card" style={{ textAlign: 'center', padding: '40px', background: 'var(--color-white)' }}>
                <AlertTriangle size={36} color="var(--color-restrained-amber)" style={{ margin: '0 auto 12px' }} />
                <h4 style={{ fontSize: '1.1rem', marginBottom: '6px' }}>No Commercial Brands Listed</h4>
                <p style={{ color: 'var(--color-muted)', fontSize: '0.9rem' }}>
                  This active generic substance is utilized in hospital regimens or specialized formulations without retail brand packaging.
                </p>
              </div>
            )}
          </div>

          {/* Section: Comprehensive Clinical Monograph */}
          {monographSections.length > 0 && (
            <div style={{ marginTop: '20px' }}>
              <div style={{
                background: 'var(--color-white)',
                border: '1px solid var(--color-border)',
                borderRadius: '24px',
                padding: '36px',
                boxShadow: 'var(--shadow-sm)'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '28px', paddingBottom: '16px', borderBottom: '1px solid var(--color-border)' }}>
                  <BookOpen size={24} color="var(--color-forest-green)" />
                  <h2 style={{ fontSize: '1.6rem', color: 'var(--color-forest-green)', margin: 0 }}>
                    Official Clinical Monograph
                  </h2>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
                  {monographSections.map((sec, idx) => (
                    <div key={idx} style={{ paddingBottom: '24px', borderBottom: idx < monographSections.length - 1 ? '1px dashed var(--color-border)' : 'none' }}>
                      <h3 style={{
                        fontSize: '1.2rem',
                        color: 'var(--color-forest-green)',
                        marginBottom: '12px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px'
                      }}>
                        <span style={{ width: '6px', height: '18px', background: 'var(--color-fresh-green)', borderRadius: '3px', display: 'inline-block' }} />
                        {sec.title}
                      </h3>
                      <div
                        style={{
                          fontSize: '0.96rem',
                          color: 'var(--color-deep-ink)',
                          lineHeight: 1.7
                        }}
                        dangerouslySetInnerHTML={{
                          __html: sanitizeClinicalHtml(sec.content)
                        }}
                      />
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Educational Disclaimer */}
          <div style={{
            background: 'var(--color-soft-sage)',
            borderRadius: '16px',
            padding: '24px',
            border: '1px solid var(--color-border)',
            display: 'flex',
            alignItems: 'flex-start',
            gap: '14px'
          }}>
            <ShieldAlert size={26} color="var(--color-forest-green)" style={{ flexShrink: 0, marginTop: '2px' }} />
            <div>
              <h4 style={{ fontSize: '1rem', color: 'var(--color-forest-green)', marginBottom: '4px', fontWeight: 700 }}>
                Clinical Reference Notice
              </h4>
              <p style={{ fontSize: '0.88rem', color: 'var(--color-deep-ink)', lineHeight: 1.5, margin: 0 }}>
                This monograph is compiled for educational reference from validated manufacturer filings and national formulary standards. Do not substitute, discontinue, or alter dosages without explicit guidance from a registered healthcare professional.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
