'use client';

import React, { useState, useMemo, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import {
  Search,
  Filter,
  RefreshCcw,
  Pill,
  ChevronLeft,
  ChevronRight,
  X,
  SlidersHorizontal,
  Building2,
  BookOpen,
  ArrowRight
} from 'lucide-react';
import { MedicineCard } from '../../components/MedicineCard';
import { Pagination } from '../../components/Pagination';
import { Medicine } from '../../lib/medicines';
import rawMedicines from '../../data/medicines.json';
import rawFilters from '../../data/filters.json';

const allMedicines: Medicine[] = rawMedicines as Medicine[];
const filterOptions = rawFilters;

const quickDosageFilters = [
  'All Forms',
  'Tablet',
  'Syrup',
  'Capsule',
  'Injection',
  'Suspension',
  'Drops',
  'Cream',
  'Inhaler',
  'Ointment',
];

function MedicineDirectoryContent() {
  const searchParams = useSearchParams();
  const router = useRouter();

  const initialQuery = searchParams.get('q') || '';
  const initialForm = searchParams.get('dosage_form') || 'All Forms';
  const initialMfg = searchParams.get('manufacturer') || 'All Manufacturers';
  const initialClass = searchParams.get('drug_class') || 'All Classes';

  const [query, setQuery] = useState(initialQuery);
  const [selectedForm, setSelectedForm] = useState(initialForm);
  const [selectedMfg, setSelectedMfg] = useState(initialMfg);
  const [selectedClass, setSelectedClass] = useState(initialClass);
  const [currentPage, setCurrentPage] = useState(1);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const itemsPerPage = 24;

  const filteredMedicines = useMemo(() => {
    const qLower = query.toLowerCase().trim();

    return allMedicines.filter((med) => {
      // 1. Text Query match across brand, generic, indication, drug class, strength, manufacturer
      const matchesQuery =
        !qLower ||
        med.name.toLowerCase().includes(qLower) ||
        med.generic.toLowerCase().includes(qLower) ||
        med.manufacturer.toLowerCase().includes(qLower) ||
        (med.strength && med.strength.toLowerCase().includes(qLower)) ||
        (med.drug_class && med.drug_class.toLowerCase().includes(qLower)) ||
        (med.indication && med.indication.toLowerCase().includes(qLower));

      // 2. Dosage Form match
      const matchesForm =
        selectedForm === 'All Forms' ||
        med.dosage_form.toLowerCase().includes(selectedForm.toLowerCase());

      // 3. Manufacturer match
      const matchesMfg =
        selectedMfg === 'All Manufacturers' ||
        med.manufacturer.toLowerCase() === selectedMfg.toLowerCase();

      // 4. Drug class match
      const matchesClass =
        selectedClass === 'All Classes' ||
        (med.drug_class && med.drug_class.toLowerCase().includes(selectedClass.toLowerCase()));

      return matchesQuery && matchesForm && matchesMfg && matchesClass;
    });
  }, [query, selectedForm, selectedMfg, selectedClass]);

  const totalPages = Math.ceil(filteredMedicines.length / itemsPerPage);
  const paginatedMedicines = useMemo(() => {
    const start = (currentPage - 1) * itemsPerPage;
    return filteredMedicines.slice(start, start + itemsPerPage);
  }, [filteredMedicines, currentPage]);

  const handleReset = () => {
    setQuery('');
    setSelectedForm('All Forms');
    setSelectedMfg('All Manufacturers');
    setSelectedClass('All Classes');
    setCurrentPage(1);
  };

  const hasActiveFilters =
    query.trim().length > 0 ||
    selectedForm !== 'All Forms' ||
    selectedMfg !== 'All Manufacturers' ||
    selectedClass !== 'All Classes';

  return (
    <div style={{ padding: '48px 0 88px' }}>
      <div className="container">
        {/* Header */}
        <div style={{ marginBottom: '32px' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '4px 12px', borderRadius: 'var(--radius-full)', background: 'var(--color-soft-sage)', color: 'var(--color-forest-green)', fontSize: '0.82rem', fontWeight: 700, marginBottom: '12px' }}>
            <Pill size={16} />
            <span>National Pharmaceutical Index • 21,700+ Products</span>
          </div>
          <h1 style={{ fontSize: 'clamp(2.2rem, 4vw, 2.8rem)', color: 'var(--color-forest-green)', marginBottom: '10px' }}>
            Verified Medicine Directory
          </h1>
          <p style={{ color: 'var(--color-muted)', fontSize: '1.05rem', maxWidth: '780px', lineHeight: 1.6 }}>
            Search through comprehensive clinical data covering generics, commercial brand alternatives, dosages, manufacturers, official package prices, and pharmacological monographs.
          </p>
        </div>

        {/* Filter Card */}
        <div className="card" style={{
          padding: '24px',
          marginBottom: '32px',
          background: 'var(--color-white)',
          border: '1px solid var(--color-border)',
          borderRadius: '20px',
          boxShadow: 'var(--shadow-sm)'
        }}>
          {/* Main Search Input */}
          <div style={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            gap: '12px',
            marginBottom: '18px'
          }}>
            <div style={{
              flex: 1,
              minWidth: '280px',
              position: 'relative',
              display: 'flex',
              alignItems: 'center'
            }}>
              <Search size={20} color="var(--color-muted)" style={{ position: 'absolute', left: '16px' }} />
              <input
                type="text"
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setCurrentPage(1);
                }}
                placeholder="Search by brand name, generic ingredient (e.g. Adalimumab, Paracetamol), indication, or company..."
                className="input-field"
                style={{ paddingLeft: '48px', height: '48px', fontSize: '0.98rem' }}
              />
              {query && (
                <button
                  onClick={() => setQuery('')}
                  style={{
                    position: 'absolute',
                    right: '12px',
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    color: 'var(--color-muted)'
                  }}
                >
                  <X size={18} />
                </button>
              )}
            </div>

            <button
              onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
              className="btn btn-secondary"
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '8px',
                height: '48px',
                padding: '0 18px',
                background: showAdvancedFilters ? 'var(--color-soft-sage)' : 'var(--color-white)'
              }}
            >
              <SlidersHorizontal size={18} />
              <span>{showAdvancedFilters ? 'Hide Filters' : 'More Filters'}</span>
            </button>

            {hasActiveFilters && (
              <button
                onClick={handleReset}
                className="btn btn-secondary"
                style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', height: '48px' }}
                title="Clear all search parameters"
              >
                <RefreshCcw size={16} />
                <span>Reset</span>
              </button>
            )}
          </div>

          {/* Quick Dosage Form Filter Pills */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', alignItems: 'center', marginBottom: showAdvancedFilters ? '18px' : '0' }}>
            <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, marginRight: '4px' }}>
              Dosage Form:
            </span>
            {quickDosageFilters.map((form) => {
              const isSelected = selectedForm.toLowerCase() === form.toLowerCase() || (form === 'All Forms' && selectedForm === 'All Forms');
              return (
                <button
                  key={form}
                  onClick={() => {
                    setSelectedForm(form);
                    setCurrentPage(1);
                  }}
                  style={{
                    padding: '5px 12px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '0.8rem',
                    fontWeight: 600,
                    transition: 'all 150ms ease',
                    background: isSelected ? 'var(--color-forest-green)' : 'var(--color-warm-ivory)',
                    color: isSelected ? 'white' : 'var(--color-deep-ink)',
                    border: `1px solid ${isSelected ? 'var(--color-forest-green)' : 'var(--color-border)'}`,
                    cursor: 'pointer'
                  }}
                >
                  {form}
                </button>
              );
            })}
          </div>

          {/* Advanced Dropdown Filters (Manufacturer & Drug Class) */}
          {showAdvancedFilters && (
            <div style={{
              paddingTop: '16px',
              borderTop: '1px solid var(--color-border)',
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
              gap: '16px'
            }}>
              {/* Manufacturer Filter */}
              <div>
                <label style={{ fontSize: '0.82rem', fontWeight: 600, color: 'var(--color-muted)', display: 'block', marginBottom: '6px' }}>
                  Filter by Manufacturer:
                </label>
                <select
                  value={selectedMfg}
                  onChange={(e) => {
                    setSelectedMfg(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="input-field"
                  style={{ width: '100%', height: '42px', padding: '0 12px', fontSize: '0.88rem' }}
                >
                  <option value="All Manufacturers">All Manufacturers ({filterOptions.manufacturers.length}+)</option>
                  {filterOptions.manufacturers.map((mfg) => (
                    <option key={mfg} value={mfg}>{mfg}</option>
                  ))}
                </select>
              </div>

              {/* Drug Class Filter */}
              <div>
                <label style={{ fontSize: '0.82rem', fontWeight: 600, color: 'var(--color-muted)', display: 'block', marginBottom: '6px' }}>
                  Filter by Therapeutic Class:
                </label>
                <select
                  value={selectedClass}
                  onChange={(e) => {
                    setSelectedClass(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="input-field"
                  style={{ width: '100%', height: '42px', padding: '0 12px', fontSize: '0.88rem' }}
                >
                  <option value="All Classes">All Therapeutic Classes</option>
                  {filterOptions.drug_classes.map((dc) => (
                    <option key={dc} value={dc}>{dc}</option>
                  ))}
                </select>
              </div>
            </div>
          )}

          {/* Active Filter Chips */}
          {hasActiveFilters && (
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', alignItems: 'center', marginTop: '16px', paddingTop: '12px', borderTop: '1px dashed var(--color-border)' }}>
              <span style={{ fontSize: '0.78rem', color: 'var(--color-muted)', fontWeight: 600 }}>Active Filters:</span>

              {query && (
                <span className="pill pill-green" style={{ fontSize: '0.75rem', display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
                  Query: &quot;{query}&quot;
                  <X size={12} style={{ cursor: 'pointer' }} onClick={() => setQuery('')} />
                </span>
              )}

              {selectedForm !== 'All Forms' && (
                <span className="pill pill-green" style={{ fontSize: '0.75rem', display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
                  Form: {selectedForm}
                  <X size={12} style={{ cursor: 'pointer' }} onClick={() => setSelectedForm('All Forms')} />
                </span>
              )}

              {selectedMfg !== 'All Manufacturers' && (
                <span className="pill pill-green" style={{ fontSize: '0.75rem', display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
                  Mfg: {selectedMfg}
                  <X size={12} style={{ cursor: 'pointer' }} onClick={() => setSelectedMfg('All Manufacturers')} />
                </span>
              )}

              {selectedClass !== 'All Classes' && (
                <span className="pill pill-green" style={{ fontSize: '0.75rem', display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
                  Class: {selectedClass}
                  <X size={12} style={{ cursor: 'pointer' }} onClick={() => setSelectedClass('All Classes')} />
                </span>
              )}

              <button
                onClick={handleReset}
                style={{
                  background: 'none',
                  border: 'none',
                  fontSize: '0.75rem',
                  color: 'var(--color-forest-green)',
                  textDecoration: 'underline',
                  cursor: 'pointer',
                  fontWeight: 600,
                  marginLeft: '4px'
                }}
              >
                Clear All
              </button>
            </div>
          )}
        </div>

        {/* Results Counter Bar */}
        <div style={{
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '20px',
          fontSize: '0.9rem',
          color: 'var(--color-muted)',
          gap: '12px'
        }}>
          <div>
            Showing <strong>{filteredMedicines.length === 0 ? 0 : (currentPage - 1) * itemsPerPage + 1}</strong> – <strong>{Math.min(currentPage * itemsPerPage, filteredMedicines.length)}</strong> of <strong>{filteredMedicines.length}</strong> matching medicines
          </div>
          {totalPages > 1 && (
            <div style={{ fontWeight: 600 }}>Page {currentPage} of {totalPages}</div>
          )}
        </div>

        {/* Medicine Cards Grid */}
        {paginatedMedicines.length === 0 ? (
          <div className="card" style={{ textAlign: 'center', padding: '64px 20px', background: 'var(--color-white)' }}>
            <Pill size={48} color="var(--color-muted)" style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '1.35rem', marginBottom: '8px', color: 'var(--color-forest-green)' }}>No matching medicines found</h3>
            <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem', marginBottom: '24px', maxWidth: '520px', margin: '0 auto 24px' }}>
              We could not find any medicine matching your active criteria. Try searching by generic name (e.g. <em>Paracetamol</em>, <em>Omeprazole</em>) or reset your filters.
            </p>
            <button onClick={handleReset} className="btn btn-primary btn-sm">
              Clear All Filters
            </button>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
            gap: '20px',
            marginBottom: '40px'
          }}>
            {paginatedMedicines.map((med) => (
              <MedicineCard key={med.id} medicine={med} />
            ))}
          </div>
        )}

        {/* Numbered Pagination Controls */}
        <Pagination
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={(p) => {
            setCurrentPage(p);
            window.scrollTo({ top: 0, behavior: 'smooth' });
          }}
        />
      </div>
    </div>
  );
}

export default function MedicineDirectoryPage() {
  return (
    <Suspense fallback={<div className="container" style={{ padding: '60px 0', textAlign: 'center' }}>Loading Medicine Directory...</div>}>
      <MedicineDirectoryContent />
    </Suspense>
  );
}
