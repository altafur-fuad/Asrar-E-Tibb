'use client';

import React, { useState, useMemo } from 'react';
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
  ExternalLink,
  BookOpen,
  Filter,
  SlidersHorizontal,
  Building2
} from 'lucide-react';
import { MedicineCard } from '../components/MedicineCard';
import { Pagination } from '../components/Pagination';
import { Medicine } from '../lib/medicines';
import rawMedicines from '../data/medicines.json';
import rawFilters from '../data/filters.json';

const allMedicines: Medicine[] = rawMedicines as Medicine[];
const filterOptions = rawFilters;

const popularSearches = [
  'Adalimumab',
  'Paracetamol',
  'Omeprazole',
  'Azithromycin',
  'Metformin',
  'Ciprofloxacin',
  'Amlodipine',
  'Montelukast'
];

const categories = [
  { name: 'Tablets', count: '10,000+ items', icon: Pill, slug: 'Tablet', color: '#ECFDF5', text: '#065F46' },
  { name: 'Syrups & Liquids', count: '3,200+ items', icon: FlaskConical, slug: 'Syrup', color: '#E0F2FE', text: '#0369A1' },
  { name: 'Capsules', count: '2,800+ items', icon: Layers, slug: 'Capsule', color: '#FEF3C7', text: '#92400E' },
  { name: 'Injectables', count: '1,500+ items', icon: Syringe, slug: 'Injection', color: '#FEE2E2', text: '#991B1B' },
  { name: 'Eye & Nasal Drops', count: '850+ items', icon: Droplet, slug: 'Drops', color: '#CCFBF1', text: '#115E59' },
  { name: 'Topicals & Creams', count: '1,100+ items', icon: Sparkles, slug: 'Cream', color: '#FEF9C3', text: '#854D0E' },
];

// Featured clinical generic monographs
const featuredGenerics = [
  { name: 'Adalimumab', slug: 'adalimumab-31', drug_class: 'Immunosuppressant / TNF Blocker', indication: 'Rheumatoid Arthritis, Crohn’s Disease, Psoriasis' },
  { name: 'Paracetamol', slug: 'paracetamol-1', drug_class: 'Non-opioid Analgesic & Antipyretic', indication: 'Fever, mild-to-moderate pain management' },
  { name: 'Omeprazole', slug: 'omeprazole-2', drug_class: 'Proton Pump Inhibitor (PPI)', indication: 'GERD, Peptic Ulcer Disease, Acid Dyspepsia' },
  { name: 'Azithromycin', slug: 'azithromycin-3', drug_class: 'Macrolide Antibacterial', indication: 'Respiratory tract infections, Skin & soft tissue infections' },
];

export default function HomePage() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDosage, setSelectedDosage] = useState('All Forms');
  const [selectedMfg, setSelectedMfg] = useState('All Manufacturers');

  // Interactive Homepage Medicine Directory Pagination
  const [directoryPage, setDirectoryPage] = useState(1);
  const [activeFormTab, setActiveFormTab] = useState('All Forms');

  const filteredHomeMeds = useMemo(() => {
    if (activeFormTab === 'All Forms') return allMedicines;
    return allMedicines.filter(
      (m) => m.dosage_form && m.dosage_form.toLowerCase().includes(activeFormTab.toLowerCase())
    );
  }, [activeFormTab]);

  const itemsPerPage = 12;
  const totalHomePages = Math.ceil(filteredHomeMeds.length / itemsPerPage);
  const currentHomeMeds = filteredHomeMeds.slice(
    (directoryPage - 1) * itemsPerPage,
    directoryPage * itemsPerPage
  );

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const params = new URLSearchParams();
    if (searchQuery.trim()) params.set('q', searchQuery.trim());
    if (selectedDosage !== 'All Forms') params.set('dosage_form', selectedDosage);
    if (selectedMfg !== 'All Manufacturers') params.set('manufacturer', selectedMfg);

    router.push(`/medicines?${params.toString()}`);
  };

  const handleQuickSearch = (term: string) => {
    router.push(`/medicines?q=${encodeURIComponent(term)}`);
  };

  return (
    <div>
      {/* 1. HERO & MEDICINE DISCOVERY SECTION */}
      <section style={{
        background: 'linear-gradient(180deg, #E6F0EA 0%, var(--color-warm-ivory) 100%)',
        padding: '56px 0 80px',
        borderBottom: '1px solid var(--color-border)',
        position: 'relative'
      }}>
        <div className="container">
          <div style={{ maxWidth: '880px', margin: '0 auto', textAlign: 'center' }}>
            <div style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              padding: '6px 16px',
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
              <span>National Medicine Directory • Bangladesh Index</span>
            </div>

            <h1 style={{
              fontSize: 'clamp(2.4rem, 5vw, 3.6rem)',
              color: 'var(--color-forest-green)',
              marginBottom: '18px',
              letterSpacing: '-0.5px',
              lineHeight: 1.15
            }}>
              Explore 21,700+ Verified Medicines & Generic Monographs
            </h1>

            <p style={{
              fontSize: '1.15rem',
              color: 'var(--color-muted)',
              lineHeight: 1.6,
              marginBottom: '36px'
            }}>
              Look up active chemical generics, indications, dosage regimens, brand alternatives, and verified prices from certified pharmaceutical laboratories.
            </p>

            {/* Medicine Discovery Search Form */}
            <form onSubmit={handleSearchSubmit} style={{
              background: 'var(--color-white)',
              padding: '16px',
              borderRadius: '24px',
              boxShadow: 'var(--shadow-lg)',
              border: '2px solid var(--color-border)',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
              textAlign: 'left'
            }}>
              {/* Primary Search Input */}
              <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
                <Search size={22} color="var(--color-muted)" style={{ position: 'absolute', left: '16px' }} />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search by Generic (e.g. Adalimumab, Paracetamol), Brand Name, Indication, or Drug Class..."
                  style={{
                    width: '100%',
                    height: '52px',
                    padding: '0 16px 0 52px',
                    border: '1px solid var(--color-border)',
                    borderRadius: '16px',
                    fontSize: '1.02rem',
                    outline: 'none',
                    background: 'var(--color-warm-ivory)'
                  }}
                />
              </div>

              {/* Filters & Submit Row */}
              <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
                gap: '10px',
                alignItems: 'center'
              }}>
                {/* Dosage Form Filter */}
                <select
                  value={selectedDosage}
                  onChange={(e) => setSelectedDosage(e.target.value)}
                  style={{
                    height: '44px',
                    padding: '0 12px',
                    borderRadius: '12px',
                    border: '1px solid var(--color-border)',
                    fontSize: '0.88rem',
                    background: 'var(--color-white)',
                    color: 'var(--color-deep-ink)'
                  }}
                >
                  <option value="All Forms">All Dosage Forms</option>
                  <option value="Tablet">Tablets</option>
                  <option value="Capsule">Capsules</option>
                  <option value="Syrup">Syrups / Oral Liquids</option>
                  <option value="Injection">Injectables</option>
                  <option value="Drops">Eye / Nasal Drops</option>
                  <option value="Cream">Creams & Ointments</option>
                  <option value="Inhaler">Inhalers & Sprays</option>
                </select>

                {/* Manufacturer Filter */}
                <select
                  value={selectedMfg}
                  onChange={(e) => setSelectedMfg(e.target.value)}
                  style={{
                    height: '44px',
                    padding: '0 12px',
                    borderRadius: '12px',
                    border: '1px solid var(--color-border)',
                    fontSize: '0.88rem',
                    background: 'var(--color-white)',
                    color: 'var(--color-deep-ink)'
                  }}
                >
                  <option value="All Manufacturers">All Top Manufacturers</option>
                  {filterOptions.manufacturers.slice(0, 30).map((mfg) => (
                    <option key={mfg} value={mfg}>{mfg}</option>
                  ))}
                </select>

                {/* Submit Button */}
                <button
                  type="submit"
                  className="btn btn-primary"
                  style={{ height: '44px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', fontSize: '0.98rem' }}
                >
                  <Search size={18} />
                  <span>Search Directory</span>
                </button>
              </div>

              {/* Quick Search Suggestions */}
              <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '6px', paddingTop: '8px', borderTop: '1px solid var(--color-border)' }}>
                <span style={{ fontSize: '0.78rem', color: 'var(--color-muted)', fontWeight: 600 }}>Popular:</span>
                {popularSearches.map((term) => (
                  <button
                    key={term}
                    type="button"
                    onClick={() => handleQuickSearch(term)}
                    style={{
                      background: 'none',
                      border: '1px solid var(--color-border)',
                      borderRadius: 'var(--radius-full)',
                      padding: '3px 10px',
                      fontSize: '0.78rem',
                      color: 'var(--color-forest-green)',
                      cursor: 'pointer',
                      fontWeight: 600,
                      transition: 'background 150ms ease'
                    }}
                  >
                    {term}
                  </button>
                ))}
              </div>
            </form>
          </div>
        </div>
      </section>

      {/* 2. DOSAGE CATEGORIES SHORTCUTS */}
      <section style={{ padding: '64px 0', borderBottom: '1px solid var(--color-border)' }}>
        <div className="container">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '32px' }}>
            <div>
              <span className="pill pill-green" style={{ marginBottom: '8px' }}>Categorized Formulations</span>
              <h2 style={{ fontSize: '1.8rem', color: 'var(--color-forest-green)' }}>Browse by Pharmaceutical Form</h2>
            </div>
            <Link href="/medicines" className="btn btn-secondary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span>View All 112 Forms</span>
              <ArrowRight size={14} />
            </Link>
          </div>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(170px, 1fr))',
            gap: '16px'
          }}>
            {categories.map((cat) => {
              const Icon = cat.icon;
              return (
                <Link
                  key={cat.name}
                  href={`/medicines?dosage_form=${cat.slug}`}
                  className="card"
                  style={{
                    padding: '24px 20px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    textAlign: 'center',
                    gap: '12px',
                    textDecoration: 'none',
                    background: 'var(--color-white)',
                    transition: 'transform 150ms ease, box-shadow 150ms ease'
                  }}
                >
                  <div style={{
                    width: '56px',
                    height: '56px',
                    borderRadius: '50%',
                    background: cat.color,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: cat.text
                  }}>
                    <Icon size={26} strokeWidth={2} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '1.02rem', fontWeight: 700, marginBottom: '2px', color: 'var(--color-forest-green)' }}>{cat.name}</h3>
                    <span style={{ fontSize: '0.8rem', color: 'var(--color-muted)' }}>{cat.count}</span>
                  </div>
                </Link>
              );
            })}
          </div>
        </div>
      </section>

      {/* 3. FEATURED GENERIC MONOGRAPHS */}
      <section style={{ padding: '64px 0', background: 'var(--color-white)', borderBottom: '1px solid var(--color-border)' }}>
        <div className="container">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '32px' }}>
            <div>
              <span className="pill pill-green" style={{ marginBottom: '8px' }}>Clinical Reference</span>
              <h2 style={{ fontSize: '1.8rem', color: 'var(--color-forest-green)' }}>Featured Generic Monographs</h2>
              <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem' }}>
                Access verified active ingredients with detailed indications, mechanisms, dosage instructions, and registered brand alternatives.
              </p>
            </div>
            <Link href="/medicines" className="btn btn-secondary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span>Search All 1,711 Generics</span>
              <ArrowRight size={14} />
            </Link>
          </div>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
            gap: '20px'
          }}>
            {featuredGenerics.map((gen) => (
              <Link
                key={gen.slug}
                href={`/generics/${gen.slug}`}
                className="card"
                style={{
                  padding: '24px',
                  background: 'var(--color-warm-ivory)',
                  border: '1px solid var(--color-border)',
                  borderRadius: '16px',
                  textDecoration: 'none',
                  display: 'flex',
                  flexDirection: 'column',
                  justifyContent: 'space-between',
                  gap: '16px'
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '10px' }}>
                    <BookOpen size={18} color="var(--color-forest-green)" />
                    <span style={{ fontSize: '0.78rem', fontWeight: 700, color: 'var(--color-forest-green)', textTransform: 'uppercase' }}>
                      Clinical Monograph
                    </span>
                  </div>
                  <h3 style={{ fontSize: '1.3rem', color: 'var(--color-forest-green)', marginBottom: '6px' }}>
                    {gen.name}
                  </h3>
                  <span className="pill pill-outline" style={{ fontSize: '0.75rem', marginBottom: '12px', display: 'inline-block' }}>
                    {gen.drug_class}
                  </span>
                  <p style={{ fontSize: '0.85rem', color: 'var(--color-deep-ink)', lineHeight: 1.5, margin: 0 }}>
                    <strong>Indications:</strong> {gen.indication}
                  </p>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--color-forest-green)', fontSize: '0.85rem', fontWeight: 600 }}>
                  <span>Read Monograph & Brands</span>
                  <ArrowRight size={14} />
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* 4. COMMERCIAL MEDICINES DIRECTORY & NUMBERED PAGINATION */}
      <section id="directory" style={{ padding: '64px 0', borderBottom: '1px solid var(--color-border)' }}>
        <div className="container">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
            <div>
              <span className="pill pill-green" style={{ marginBottom: '8px' }}>Commercial Directory</span>
              <h2 style={{ fontSize: '1.8rem', color: 'var(--color-forest-green)' }}>Browse Commercial Medicines</h2>
              <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem' }}>
                Showing page {directoryPage} of {totalHomePages} ({filteredHomeMeds.length} commercial preparations in directory).
              </p>
            </div>
            <Link href="/medicines" className="btn btn-secondary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span>Advanced Filters</span>
              <ArrowRight size={14} />
            </Link>
          </div>

          {/* Quick Dosage Form Filter Tabs */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '28px', alignItems: 'center' }}>
            <span style={{ fontSize: '0.82rem', fontWeight: 600, color: 'var(--color-muted)', marginRight: '6px' }}>
              Filter Form:
            </span>
            {['All Forms', 'Tablet', 'Capsule', 'Syrup', 'Injection', 'Suspension', 'Drops', 'Cream'].map((form) => {
              const isSelected = activeFormTab === form;
              return (
                <button
                  key={form}
                  type="button"
                  onClick={() => {
                    setActiveFormTab(form);
                    setDirectoryPage(1);
                  }}
                  style={{
                    padding: '6px 14px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '0.82rem',
                    fontWeight: 600,
                    cursor: 'pointer',
                    transition: 'all 150ms ease',
                    background: isSelected ? 'var(--color-forest-green)' : 'var(--color-white)',
                    color: isSelected ? 'white' : 'var(--color-deep-ink)',
                    border: `1px solid ${isSelected ? 'var(--color-forest-green)' : 'var(--color-border)'}`,
                    boxShadow: isSelected ? '0 2px 4px rgba(6, 78, 59, 0.15)' : 'none'
                  }}
                >
                  {form}
                </button>
              );
            })}
          </div>

          {/* Medicine Cards Grid */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
            gap: '20px',
            marginBottom: '16px'
          }}>
            {currentHomeMeds.map((med) => (
              <MedicineCard key={med.id} medicine={med} />
            ))}
          </div>

          {/* Numbered Pagination: 1, 2, 3, 4, 5, 6... */}
          <Pagination
            currentPage={directoryPage}
            totalPages={totalHomePages}
            onPageChange={(p) => {
              setDirectoryPage(p);
              const el = document.getElementById('directory');
              if (el) el.scrollIntoView({ behavior: 'smooth' });
            }}
          />
        </div>
      </section>

      {/* 5. NATIVE APP CTA */}
      <section style={{ padding: '64px 0' }}>
        <div className="container">
          <div className="card" style={{
            background: 'linear-gradient(135deg, var(--color-forest-green) 0%, #064E3B 100%)',
            color: 'white',
            borderRadius: '24px',
            padding: '56px 48px',
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '32px'
          }}>
            <div style={{ maxWidth: '580px' }}>
              <div style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '8px',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                background: 'rgba(255, 255, 255, 0.15)',
                fontSize: '0.82rem',
                fontWeight: 600,
                marginBottom: '16px'
              }}>
                <Smartphone size={16} />
                <span>Mobile Experience</span>
              </div>
              <h2 style={{ fontSize: 'clamp(1.8rem, 3.5vw, 2.4rem)', color: 'white', marginBottom: '16px' }}>
                Access Medicine Intelligence Offline on Your Android Device
              </h2>
              <p style={{ fontSize: '1rem', color: 'rgba(255, 255, 255, 0.85)', lineHeight: 1.6, marginBottom: '24px' }}>
                Install the native Asrar-e-Tibb app for instant offline search across 21,700+ medicines, dosage reminders, and symptom journaling.
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px' }}>
                <Link href="/download" className="btn btn-lg" style={{ background: 'var(--color-warm-ivory)', color: 'var(--color-forest-green)', fontWeight: 700 }}>
                  <Download size={20} />
                  <span>Download Android APK</span>
                </Link>
                <Link href="/about" className="btn btn-secondary btn-lg" style={{ background: 'transparent', borderColor: 'rgba(255,255,255,0.4)', color: 'white' }}>
                  <span>Learn More</span>
                </Link>
              </div>
            </div>

            <div style={{
              background: 'rgba(255, 255, 255, 0.08)',
              padding: '24px',
              borderRadius: '20px',
              border: '1px solid rgba(255, 255, 255, 0.15)',
              minWidth: '240px'
            }}>
              <h4 style={{ fontSize: '1.05rem', color: 'white', marginBottom: '14px', fontWeight: 700 }}>Directory Integrity</h4>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.85rem', color: 'rgba(255,255,255,0.9)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-fresh-green)" />
                  <span>21,714 Verified Medicines</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-fresh-green)" />
                  <span>1,711 Generic Monographs</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-fresh-green)" />
                  <span>112 Registered Dosage Forms</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CheckCircle size={16} color="var(--color-fresh-green)" />
                  <span>232 Certified Manufacturers</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
