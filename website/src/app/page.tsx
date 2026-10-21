'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  Search,
  ArrowRight,
  Download,
  ShieldCheck,
  Pill,
  FlaskConical,
  Layers,
  Syringe,
  Droplet,
  Sparkles,
  Clock,
  CheckCircle,
  Smartphone,
  ExternalLink
} from 'lucide-react';
import { MedicineCard, Medicine } from '../components/MedicineCard';
import rawMedicines from '../data/medicines.json';

const medicines: Medicine[] = rawMedicines.slice(0, 8) as Medicine[];

const categories = [
  { name: 'Tablets', count: '10,000+ items', icon: Pill, slug: 'tablet', color: '#ECFDF5', text: '#065F46' },
  { name: 'Syrups & Liquids', count: '3,200+ items', icon: FlaskConical, slug: 'syrup', color: '#E0F2FE', text: '#0369A1' },
  { name: 'Capsules', count: '2,800+ items', icon: Layers, slug: 'capsule', color: '#FEF3C7', text: '#92400E' },
  { name: 'Injectables', count: '1,500+ items', icon: Syringe, slug: 'injection', color: '#FEE2E2', text: '#991B1B' },
  { name: 'Drops & Sprays', count: '850+ items', icon: Droplet, slug: 'drop', color: '#CCFBF1', text: '#115E59' },
  { name: 'Topicals & Creams', count: '1,100+ items', icon: Sparkles, slug: 'cream', color: '#FEF9C3', text: '#854D0E' },
];

export default function HomePage() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/medicines?q=${encodeURIComponent(searchQuery.trim())}`);
    }
  };

  return (
    <div>
      {/* 1. HERO SECTION */}
      <section style={{
        background: 'linear-gradient(180deg, #E6F0EA 0%, var(--color-warm-ivory) 100%)',
        padding: '64px 0 80px',
        borderBottom: '1px solid var(--color-border)',
        position: 'relative',
        overflow: 'hidden'
      }}>
        <div className="container">
          <div style={{ maxWidth: '800px', margin: '0 auto', textAlign: 'center' }}>
            <div style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              padding: '6px 14px',
              borderRadius: 'var(--radius-full)',
              background: 'rgba(6, 78, 59, 0.08)',
              color: 'var(--color-forest-green)',
              fontSize: '0.82rem',
              fontWeight: 700,
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
              marginBottom: '20px'
            }}>
              <ShieldCheck size={16} />
              <span>Verified Clinical Database • Bangladesh Pharmaceutical Index</span>
            </div>

            <h1 style={{
              fontSize: 'clamp(2.2rem, 5vw, 3.4rem)',
              color: 'var(--color-forest-green)',
              marginBottom: '20px',
              letterSpacing: '-0.5px'
            }}>
              Trusted Medicine Intelligence & Modern Pharmacy Care
            </h1>

            <p style={{
              fontSize: '1.12rem',
              color: 'var(--color-muted)',
              lineHeight: 1.6,
              marginBottom: '36px'
            }}>
              Search through over <strong>21,000+ verified medicines</strong>, generic indications, dosages, and therapeutic guides. Powered by genuine clinical datasets and classical wellness heritage.
            </p>

            {/* Live Search Form */}
            <form onSubmit={handleSearchSubmit} style={{
              display: 'flex',
              background: 'var(--color-white)',
              padding: '8px',
              borderRadius: 'var(--radius-lg)',
              boxShadow: 'var(--shadow-lg)',
              border: '2px solid var(--color-forest-green)',
              marginBottom: '18px'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', padding: '0 12px', color: 'var(--color-muted)' }}>
                <Search size={22} />
              </div>
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search by brand name (e.g. Napa, A-Cold, Seclo) or generic name..."
                style={{
                  flex: 1,
                  border: 'none',
                  outline: 'none',
                  fontSize: '1.05rem',
                  fontFamily: 'var(--font-body)',
                  color: 'var(--color-deep-ink)'
                }}
              />
              <button type="submit" className="btn btn-primary" style={{ padding: '12px 28px' }}>
                Search
              </button>
            </form>

            {/* Quick search tags */}
            <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'center', gap: '8px', fontSize: '0.85rem' }}>
              <span style={{ color: 'var(--color-muted)', fontWeight: 600 }}>Popular:</span>
              {['A-Cold', 'Paracetamol', 'Omeprazole', 'Cloxacillin', 'Azithromycin'].map((term) => (
                <Link
                  key={term}
                  href={`/medicines?q=${encodeURIComponent(term)}`}
                  style={{
                    color: 'var(--color-forest-green)',
                    background: 'var(--color-soft-sage)',
                    padding: '4px 10px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '0.8rem',
                    fontWeight: 600
                  }}
                >
                  {term}
                </Link>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 2. CATEGORY SHORTCUTS */}
      <section style={{ padding: '60px 0' }}>
        <div className="container">
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: '32px' }}>
            <div>
              <span className="pill pill-green" style={{ marginBottom: '8px' }}>Catalog Navigation</span>
              <h2 style={{ fontSize: '1.85rem' }}>Dosage Form Categories</h2>
            </div>
            <Link href="/medicines" className="btn btn-secondary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span>View All 112 Forms</span>
              <ArrowRight size={16} />
            </Link>
          </div>

          <div className="grid-3" style={{ gap: '20px' }}>
            {categories.map((cat) => {
              const Icon = cat.icon;
              return (
                <Link
                  key={cat.name}
                  href={`/medicines?dosage_form=${cat.slug}`}
                  className="card"
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '16px',
                    padding: '20px',
                    transition: 'all 200ms ease'
                  }}
                >
                  <div style={{
                    width: '54px',
                    height: '54px',
                    borderRadius: '12px',
                    background: cat.color,
                    color: cat.text,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0
                  }}>
                    <Icon size={26} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '1.1rem', marginBottom: '2px', color: 'var(--color-forest-green)' }}>
                      {cat.name}
                    </h3>
                    <p style={{ fontSize: '0.85rem', color: 'var(--color-muted)' }}>
                      {cat.count}
                    </p>
                  </div>
                </Link>
              );
            })}
          </div>
        </div>
      </section>

      {/* 3. FEATURED AUTHENTIC MEDICINES */}
      <section style={{ padding: '60px 0', background: 'var(--color-white)', borderTop: '1px solid var(--color-border)', borderBottom: '1px solid var(--color-border)' }}>
        <div className="container">
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: '36px' }}>
            <div>
              <span className="pill pill-amber" style={{ marginBottom: '8px' }}>Directory Highlights</span>
              <h2 style={{ fontSize: '1.85rem' }}>Essential Healthcare Formulations</h2>
              <p style={{ fontSize: '0.95rem', color: 'var(--color-muted)' }}>
                Directly retrieved from the verified 21,716-record national medicine dataset.
              </p>
            </div>
            <Link href="/medicines" className="btn btn-primary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span>Open Full Directory</span>
              <ArrowRight size={16} />
            </Link>
          </div>

          <div className="grid-4" style={{ gap: '20px' }}>
            {medicines.map((med) => (
              <MedicineCard key={med.id} medicine={med} />
            ))}
          </div>
        </div>
      </section>

      {/* 4. APP DOWNLOAD PROMO BANNER */}
      <section style={{ padding: '72px 0' }}>
        <div className="container">
          <div style={{
            background: 'linear-gradient(135deg, var(--color-forest-green) 0%, var(--color-evergreen) 100%)',
            borderRadius: '24px',
            padding: '48px 40px',
            color: 'var(--color-white)',
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '32px',
            boxShadow: 'var(--shadow-xl)'
          }}>
            <div style={{ maxWidth: '580px' }}>
              <div style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '8px',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                background: 'rgba(255, 255, 255, 0.15)',
                fontSize: '0.8rem',
                fontWeight: 700,
                textTransform: 'uppercase',
                marginBottom: '16px'
              }}>
                <Smartphone size={16} />
                <span>Native Android Mobile Experience</span>
              </div>
              <h2 style={{ fontSize: '2.2rem', color: 'var(--color-white)', marginBottom: '14px' }}>
                Carry Asrar-e-Tibb In Your Pocket
              </h2>
              <p style={{ fontSize: '1.05rem', color: '#D1FAE5', lineHeight: 1.6, marginBottom: '24px' }}>
                Access offline medicine schedules, personal health reminders, interactive symptom logs, and TibbNews articles on the go with zero ads and strict biometric security.
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '14px' }}>
                <Link href="/download" className="btn btn-amber btn-lg">
                  <Download size={20} />
                  <span>Download Android APK</span>
                </Link>
                <Link href="/medicines" className="btn btn-secondary btn-lg" style={{ background: 'transparent', color: 'white', borderColor: 'rgba(255,255,255,0.4)' }}>
                  <span>Explore Online</span>
                </Link>
              </div>
            </div>

            <div style={{
              background: 'rgba(255, 255, 255, 0.1)',
              backdropFilter: 'blur(10px)',
              borderRadius: '20px',
              padding: '24px',
              border: '1px solid rgba(255, 255, 255, 0.2)',
              minWidth: '260px'
            }}>
              <h4 style={{ color: 'white', fontSize: '1rem', marginBottom: '12px' }}>Release Highlights</h4>
              <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.88rem' }}>
                <li style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-restrained-amber)" />
                  <span>Version 1.0.0 Stable Build</span>
                </li>
                <li style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-restrained-amber)" />
                  <span>SHA-256 Checksum Verified</span>
                </li>
                <li style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-restrained-amber)" />
                  <span>21,700+ Offline Database</span>
                </li>
                <li style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-restrained-amber)" />
                  <span>Hardware Back & Navigation Protected</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* 5. HEALTHCARE PILLARS */}
      <section style={{ padding: '60px 0', borderTop: '1px solid var(--color-border)', background: 'var(--color-soft-sage)' }}>
        <div className="container">
          <div style={{ textAlign: 'center', maxWidth: '640px', margin: '0 auto 48px' }}>
            <span className="pill pill-green" style={{ marginBottom: '8px' }}>Our Standards</span>
            <h2 style={{ fontSize: '1.85rem', marginBottom: '12px' }}>Engineered for Clinical Honesty</h2>
            <p style={{ fontSize: '0.95rem', color: 'var(--color-muted)' }}>
              We do not fabricate doctor reviews, stock levels, or miracle cures. Every feature reflects verified medicine science.
            </p>
          </div>

          <div className="grid-3" style={{ gap: '24px' }}>
            <div className="card" style={{ padding: '28px' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'var(--color-soft-sage)', color: 'var(--color-forest-green)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '18px' }}>
                <ShieldCheck size={26} />
              </div>
              <h3 style={{ fontSize: '1.2rem', marginBottom: '8px' }}>Uncompromised Privacy</h3>
              <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)', lineHeight: 1.6 }}>
                Personal medication schedules, private notes, and health conditions are protected with PostgreSQL Row Level Security. We never sell patient profiles.
              </p>
            </div>

            <div className="card" style={{ padding: '28px' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: '#FEF3C7', color: '#92400E', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '18px' }}>
                <Clock size={26} />
              </div>
              <h3 style={{ fontSize: '1.2rem', marginBottom: '8px' }}>Authentic Indication Data</h3>
              <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)', lineHeight: 1.6 }}>
                Comprehensive cross-references linking brands, active generics, strength metrics, dosage forms, and indications directly from official manufacturer registries.
              </p>
            </div>

            <div className="card" style={{ padding: '28px' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: '#E0F2FE', color: '#0369A1', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '18px' }}>
                <Smartphone size={26} />
              </div>
              <h3 style={{ fontSize: '1.2rem', marginBottom: '8px' }}>Open Android Distribution</h3>
              <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)', lineHeight: 1.6 }}>
                Direct APK releases signed and published transparently on GitHub, accompanied by cryptographic SHA-256 hashes for total patient security.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

