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
  ShieldAlert,
  BookOpen,
  Layers,
  ChevronRight,
  ExternalLink,
  Pill,
  ArrowRight
} from 'lucide-react';
import {
  getMedicineBySlug,
  getMonographBySlug,
  getAlternativeBrands,
  getAllMedicines,
  Medicine
} from '../../../lib/medicines';
import { sanitizeClinicalHtml } from '../../../lib/sanitizeHtml';
import { MedicineImageBadge } from '../../../components/MedicineImageBadge';

interface Props {
  params: {
    id: string;
  };
}

export const dynamic = 'auto';

export default function MedicineDetailPage({ params }: Props) {
  const medicine = getMedicineBySlug(params.id);

  if (!medicine) {
    notFound();
  }

  // Retrieve linked generic monograph
  const monograph = medicine.generic_slug ? getMonographBySlug(medicine.generic_slug) : null;

  // Retrieve genuine alternative brands with the exact same generic ID (excluding this medicine)
  const alternativeBrands = medicine.generic_id
    ? getAlternativeBrands(medicine.generic_id, medicine.id)
    : [];

  // Group alternative brands into like-for-like (same dosage form & strength) vs other preparations
  const sameStrengthAlternatives = alternativeBrands.filter(
    (b) => b.dosage_form.toLowerCase() === medicine.dosage_form.toLowerCase() &&
           (!medicine.strength || b.strength.toLowerCase() === medicine.strength.toLowerCase())
  );
  const otherFormulationAlternatives = alternativeBrands.filter(
    (b) => !sameStrengthAlternatives.some((sa) => sa.id === b.id)
  );

  // Monograph clinical sections
  const clinicalSections = monograph ? [
    { id: 'indications', title: 'Clinical Indications & Usage', content: monograph.indication_description || monograph.indication },
    { id: 'class', title: 'Therapeutic Class & Mechanism', content: monograph.therapeutic_class_description || monograph.drug_class },
    { id: 'pharmacology', title: 'Pharmacology & Action Mechanism', content: monograph.pharmacology_description },
    { id: 'dosage', title: 'Dosage & Administration Regimen', content: monograph.dosage_description },
    { id: 'admin', title: 'Administration Guidelines', content: monograph.administration_description },
    { id: 'side-effects', title: 'Side Effects & Adverse Reactions', content: monograph.side_effects_description },
    { id: 'contraindications', title: 'Contraindications', content: monograph.contraindications_description },
    { id: 'precautions', title: 'Warnings & Precautions', content: monograph.precautions_description },
    { id: 'interactions', title: 'Drug Interactions', content: monograph.interaction_description },
    { id: 'pregnancy', title: 'Pregnancy & Lactation Guidance', content: monograph.pregnancy_and_lactation_description },
    { id: 'pediatric', title: 'Pediatric Use', content: monograph.pediatric_usage_description },
    { id: 'overdose', title: 'Overdose Signs & Management', content: monograph.overdose_effects_description },
    { id: 'storage', title: 'Reconstitution & Storage Conditions', content: monograph.storage_conditions_description || monograph.reconstitution_description }
  ].filter((s) => s.content && s.content.trim().length > 0) : [];

  return (
    <div style={{ padding: '48px 0 96px' }}>
      <div className="container" style={{ maxWidth: '1160px' }}>
        {/* Navigation Breadcrumb */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.88rem', marginBottom: '24px' }}>
          <Link href="/medicines" style={{ color: 'var(--color-forest-green)', display: 'inline-flex', alignItems: 'center', gap: '6px', fontWeight: 600 }}>
            <ArrowLeft size={16} />
            <span>Medicine Directory</span>
          </Link>
          <ChevronRight size={14} color="var(--color-muted)" />
          {medicine.generic_slug ? (
            <Link href={`/generics/${medicine.generic_slug}`} style={{ color: 'var(--color-forest-green)', fontWeight: 600 }}>
              {medicine.generic}
            </Link>
          ) : (
            <span style={{ color: 'var(--color-muted)' }}>{medicine.generic}</span>
          )}
          <ChevronRight size={14} color="var(--color-muted)" />
          <span style={{ fontWeight: 600, color: 'var(--color-deep-ink)' }}>{medicine.name}</span>
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
          <div style={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'flex-start',
            justifyContent: 'space-between',
            gap: '32px'
          }}>
            <div style={{ display: 'flex', gap: '24px', alignItems: 'flex-start', flex: 1, minWidth: '300px' }}>
              <MedicineImageBadge
                dosageForm={medicine.dosage_form}
                brandName={medicine.name}
                imageUrl={medicine.image_url}
                size="lg"
              />

              <div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '10px' }}>
                  <span className="pill pill-green">
                    {medicine.dosage_form}
                  </span>
                  <span className="pill pill-outline">
                    {medicine.type || 'Allopathic'}
                  </span>
                  {medicine.strength && (
                    <span className="pill pill-outline" style={{ fontWeight: 700 }}>
                      {medicine.strength}
                    </span>
                  )}
                </div>

                <h1 style={{ fontSize: 'clamp(2.2rem, 4vw, 3rem)', color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                  {medicine.name}
                </h1>

                {/* Linked Generic Monograph Link */}
                <div style={{ fontSize: '1.2rem', marginBottom: '12px' }}>
                  <span style={{ color: 'var(--color-muted)', fontWeight: 500 }}>Generic Formulation: </span>
                  {medicine.generic_slug ? (
                    <Link
                      href={`/generics/${medicine.generic_slug}`}
                      style={{ color: 'var(--color-forest-green)', fontWeight: 700, textDecoration: 'underline' }}
                      title="View full generic monograph"
                    >
                      {medicine.generic}
                    </Link>
                  ) : (
                    <strong style={{ color: 'var(--color-deep-ink)' }}>{medicine.generic}</strong>
                  )}
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#64748B', fontSize: '0.95rem' }}>
                  <Building2 size={18} />
                  <span>Manufactured by: <strong>{medicine.manufacturer}</strong></span>
                </div>
              </div>
            </div>

            {/* Official Price Box */}
            <div style={{
              background: 'var(--color-soft-sage)',
              padding: '24px 28px',
              borderRadius: 'var(--radius-lg)',
              minWidth: '260px',
              border: '1px solid var(--color-border)',
              textAlign: 'center'
            }}>
              <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
                Official Package Price
              </span>
              <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--color-forest-green)', marginBottom: '8px' }}>
                {medicine.price}
              </div>
              <p style={{ fontSize: '0.82rem', color: 'var(--color-muted)', marginBottom: '16px', lineHeight: 1.4 }}>
                {medicine.package_container || 'Standard dispensing unit'}
              </p>
              <Link
                href={`/farmacia?add=${medicine.id}`}
                className="btn btn-primary"
                style={{ width: '100%', display: 'flex', justifyContent: 'center', gap: '8px' }}
              >
                <ShoppingBag size={18} />
                <span>Buy on Farmacia</span>
              </Link>
            </div>
          </div>
        </div>

        {/* Alternative Brands Section */}
        <section id="alternative-brands" style={{ marginBottom: '48px' }}>
          <div style={{
            background: 'var(--color-white)',
            border: '2px solid var(--color-border)',
            borderRadius: '24px',
            padding: '36px',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '16px', marginBottom: '20px' }}>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <Layers size={24} color="var(--color-forest-green)" />
                  <h2 style={{ fontSize: '1.6rem', color: 'var(--color-forest-green)', margin: 0 }}>
                    Alternative Brands ({alternativeBrands.length})
                  </h2>
                </div>
                <p style={{ fontSize: '0.92rem', color: 'var(--color-muted)', marginTop: '4px', margin: 0 }}>
                  Other commercially registered medicines formulated with identical generic substance <strong>{medicine.generic}</strong>.
                </p>
              </div>

              {medicine.generic_slug && (
                <Link
                  href={`/generics/${medicine.generic_slug}`}
                  className="btn btn-secondary btn-sm"
                  style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}
                >
                  <span>View Complete Monograph</span>
                  <ArrowRight size={14} />
                </Link>
              )}
            </div>

            {/* Substitution Safety Advisory */}
            <div style={{
              background: 'rgba(217, 119, 6, 0.08)',
              border: '1px solid rgba(217, 119, 6, 0.3)',
              borderRadius: '12px',
              padding: '14px 18px',
              marginBottom: '24px',
              display: 'flex',
              alignItems: 'flex-start',
              gap: '12px'
            }}>
              <AlertCircle size={20} color="var(--color-restrained-amber)" style={{ flexShrink: 0, marginTop: '2px' }} />
              <p style={{ fontSize: '0.85rem', color: 'var(--color-deep-ink)', lineHeight: 1.5, margin: 0 }}>
                <strong>Substitution Notice:</strong> Switching brands or formulations requires professional verification by a registered doctor or pharmacist. Never assume differing dosage forms or strengths are directly interchangeable.
              </p>
            </div>

            {/* Like-for-Like Alternatives */}
            {sameStrengthAlternatives.length > 0 && (
              <div style={{ marginBottom: otherFormulationAlternatives.length > 0 ? '32px' : '0' }}>
                <h4 style={{ fontSize: '1.05rem', color: 'var(--color-forest-green)', marginBottom: '14px', fontWeight: 700 }}>
                  Matching Form & Strength ({medicine.dosage_form} {medicine.strength && `• ${medicine.strength}`})
                </h4>
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
                  gap: '14px'
                }}>
                  {sameStrengthAlternatives.map((alt) => (
                    <Link
                      key={alt.id}
                      href={`/medicines/${alt.slug}`}
                      style={{
                        padding: '16px',
                        borderRadius: '16px',
                        border: '1px solid var(--color-border)',
                        background: 'var(--color-warm-ivory)',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        textDecoration: 'none',
                        transition: 'all 150ms ease'
                      }}
                    >
                      <MedicineImageBadge dosageForm={alt.dosage_form} brandName={alt.name} size="sm" />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <h5 style={{ fontSize: '1rem', fontWeight: 700, color: 'var(--color-forest-green)', margin: '0 0 2px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          {alt.name}
                        </h5>
                        <p style={{ fontSize: '0.78rem', color: 'var(--color-muted)', margin: 0 }}>
                          {alt.manufacturer}
                        </p>
                      </div>
                      <span style={{ fontSize: '0.88rem', fontWeight: 700, color: 'var(--color-forest-green)' }}>
                        {alt.price}
                      </span>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Other Formulations / Strengths */}
            {otherFormulationAlternatives.length > 0 && (
              <div>
                <h4 style={{ fontSize: '1.05rem', color: 'var(--color-muted)', marginBottom: '14px', fontWeight: 600 }}>
                  Other Strengths & Formulations ({otherFormulationAlternatives.length})
                </h4>
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
                  gap: '14px'
                }}>
                  {otherFormulationAlternatives.slice(0, 16).map((alt) => (
                    <Link
                      key={alt.id}
                      href={`/medicines/${alt.slug}`}
                      style={{
                        padding: '14px',
                        borderRadius: '14px',
                        border: '1px solid var(--color-border)',
                        background: 'var(--color-white)',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        textDecoration: 'none'
                      }}
                    >
                      <MedicineImageBadge dosageForm={alt.dosage_form} brandName={alt.name} size="sm" />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <h5 style={{ fontSize: '0.95rem', fontWeight: 700, color: 'var(--color-forest-green)', margin: '0 0 2px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          {alt.name}
                        </h5>
                        <p style={{ fontSize: '0.75rem', color: 'var(--color-muted)', margin: 0 }}>
                          {alt.dosage_form} {alt.strength && `• ${alt.strength}`}
                        </p>
                      </div>
                      <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--color-deep-ink)' }}>
                        {alt.price}
                      </span>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {alternativeBrands.length === 0 && (
              <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem', margin: 0 }}>
                No other commercial brands are currently indexed for this specific generic substance.
              </p>
            )}
          </div>
        </section>

        {/* Detailed Clinical Monograph */}
        {clinicalSections.length > 0 && (
          <section id="clinical-monograph" style={{ marginBottom: '48px' }}>
            <div style={{
              background: 'var(--color-white)',
              border: '1px solid var(--color-border)',
              borderRadius: '24px',
              padding: '40px',
              boxShadow: 'var(--shadow-sm)'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '28px', paddingBottom: '16px', borderBottom: '1px solid var(--color-border)' }}>
                <BookOpen size={24} color="var(--color-forest-green)" />
                <h2 style={{ fontSize: '1.65rem', color: 'var(--color-forest-green)', margin: 0 }}>
                  Complete Clinical Monograph ({medicine.generic})
                </h2>
              </div>

              {/* Table of contents quick jumps */}
              <div style={{
                background: 'var(--color-warm-ivory)',
                padding: '16px 20px',
                borderRadius: '16px',
                border: '1px solid var(--color-border)',
                marginBottom: '36px'
              }}>
                <span style={{ fontSize: '0.82rem', fontWeight: 700, color: 'var(--color-forest-green)', textTransform: 'uppercase', display: 'block', marginBottom: '10px' }}>
                  Section Navigation:
                </span>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                  {clinicalSections.map((sec) => (
                    <a
                      key={sec.id}
                      href={`#${sec.id}`}
                      style={{
                        padding: '4px 12px',
                        background: 'var(--color-white)',
                        borderRadius: 'var(--radius-full)',
                        fontSize: '0.8rem',
                        fontWeight: 600,
                        color: 'var(--color-forest-green)',
                        textDecoration: 'none',
                        border: '1px solid var(--color-border)'
                      }}
                    >
                      {sec.title}
                    </a>
                  ))}
                </div>
              </div>

              {/* Monograph Content Sections */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
                {clinicalSections.map((sec, idx) => (
                  <div key={sec.id} id={sec.id} style={{ paddingBottom: '28px', borderBottom: idx < clinicalSections.length - 1 ? '1px dashed var(--color-border)' : 'none' }}>
                    <h3 style={{
                      fontSize: '1.25rem',
                      color: 'var(--color-forest-green)',
                      marginBottom: '14px',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '10px'
                    }}>
                      <span style={{ width: '6px', height: '20px', background: 'var(--color-fresh-green)', borderRadius: '3px', display: 'inline-block' }} />
                      {sec.title}
                    </h3>
                    <div
                      style={{
                        fontSize: '0.98rem',
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
          </section>
        )}

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
            <h4 style={{ fontSize: '1.05rem', color: 'var(--color-forest-green)', marginBottom: '4px', fontWeight: 700 }}>
              Evidence-Based Practice Notice
            </h4>
            <p style={{ fontSize: '0.88rem', color: 'var(--color-deep-ink)', lineHeight: 1.6, margin: 0 }}>
              All indications, drug classes, dosages, and monographs for <strong>{medicine.name}</strong> ({medicine.generic}) are compiled directly from manufacturer clinical filings and national regulatory registers. Asrar-e-Tibb is an informational healthcare directory and does not endorse self-medication. Always follow the explicit instructions of your attending licensed physician.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
