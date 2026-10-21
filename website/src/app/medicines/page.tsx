'use client';

import React, { useState, useMemo, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { Search, Filter, RefreshCcw, Pill, ChevronLeft, ChevronRight } from 'lucide-react';
import { MedicineCard, Medicine } from '../../components/MedicineCard';
import rawMedicines from '../../data/medicines.json';

const allMedicines: Medicine[] = rawMedicines as Medicine[];

const dosageFilters = [
  'All Forms',
  'Tablet',
  'Syrup',
  'Capsule',
  'Injection',
  'Suspension',
  'Drop',
  'Cream',
  'Inhaler',
  'Ointment',
];

function MedicineDirectoryContent() {
  const searchParams = useSearchParams();
  const initialQuery = searchParams.get('q') || '';
  const initialForm = searchParams.get('dosage_form') || 'All Forms';

  const [query, setQuery] = useState(initialQuery);
  const [selectedForm, setSelectedForm] = useState(initialForm);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 24;

  const filteredMedicines = useMemo(() => {
    return allMedicines.filter((med) => {
      const qLower = query.toLowerCase().trim();
      const matchesQuery =
        !qLower ||
        med.name.toLowerCase().includes(qLower) ||
        med.generic.toLowerCase().includes(qLower) ||
        med.manufacturer.toLowerCase().includes(qLower);

      const matchesForm =
        selectedForm === 'All Forms' ||
        med.dosage_form.toLowerCase().includes(selectedForm.toLowerCase());

      return matchesQuery && matchesForm;
    });
  }, [query, selectedForm]);

  const totalPages = Math.ceil(filteredMedicines.length / itemsPerPage);
  const paginatedMedicines = useMemo(() => {
    const start = (currentPage - 1) * itemsPerPage;
    return filteredMedicines.slice(start, start + itemsPerPage);
  }, [filteredMedicines, currentPage]);

  const handleReset = () => {
    setQuery('');
    setSelectedForm('All Forms');
    setCurrentPage(1);
  };

  return (
    <div style={{ padding: '48px 0 80px' }}>
      <div className="container">
        {/* Header */}
        <div style={{ marginBottom: '32px' }}>
          <span className="pill pill-green" style={{ marginBottom: '8px' }}>
            Verified Directory
          </span>
          <h1 style={{ fontSize: '2.4rem', marginBottom: '10px' }}>
            National Medicine Directory
          </h1>
          <p style={{ color: 'var(--color-muted)', fontSize: '1.05rem', maxWidth: '720px' }}>
            Browse through over 2,900 curated pharmaceuticals, generic formulations, strengths, and official packaging prices from certified manufacturers.
          </p>
        </div>

        {/* Filter & Search Bar */}
        <div className="card" style={{ padding: '20px', marginBottom: '36px', background: 'var(--color-white)' }}>
          <div style={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            gap: '16px',
            marginBottom: '16px'
          }}>
            {/* Search input */}
            <div style={{
              flex: 1,
              minWidth: '260px',
              position: 'relative',
              display: 'flex',
              alignItems: 'center'
            }}>
              <Search size={20} color="var(--color-muted)" style={{ position: 'absolute', left: '14px' }} />
              <input
                type="text"
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setCurrentPage(1);
                }}
                placeholder="Search by brand name, generic ingredient, or manufacturer..."
                className="input-field"
                style={{ paddingLeft: '44px' }}
              />
            </div>

            {/* Reset button */}
            {(query || selectedForm !== 'All Forms') && (
              <button
                onClick={handleReset}
                className="btn btn-secondary btn-sm"
                style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <RefreshCcw size={14} />
                <span>Reset Filters</span>
              </button>
            )}
          </div>

          {/* Dosage Form Pills */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', alignItems: 'center' }}>
            <span style={{ fontSize: '0.82rem', color: 'var(--color-muted)', fontWeight: 600, marginRight: '4px' }}>
              Dosage Form:
            </span>
            {dosageFilters.map((form) => {
              const isSelected = selectedForm.toLowerCase() === form.toLowerCase() || (form === 'All Forms' && selectedForm === 'All Forms');
              return (
                <button
                  key={form}
                  onClick={() => {
                    setSelectedForm(form);
                    setCurrentPage(1);
                  }}
                  style={{
                    padding: '6px 14px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '0.82rem',
                    fontWeight: 600,
                    transition: 'all 150ms ease',
                    background: isSelected ? 'var(--color-forest-green)' : 'var(--color-warm-ivory)',
                    color: isSelected ? 'white' : 'var(--color-deep-ink)',
                    border: `1px solid ${isSelected ? 'var(--color-forest-green)' : 'var(--color-border)'}`
                  }}
                >
                  {form}
                </button>
              );
            })}
          </div>
        </div>

        {/* Results Counter */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '20px',
          fontSize: '0.9rem',
          color: 'var(--color-muted)'
        }}>
          <span>
            Showing <strong>{filteredMedicines.length === 0 ? 0 : (currentPage - 1) * itemsPerPage + 1}</strong> – <strong>{Math.min(currentPage * itemsPerPage, filteredMedicines.length)}</strong> of <strong>{filteredMedicines.length}</strong> items
          </span>
          {totalPages > 1 && (
            <span>Page {currentPage} of {totalPages}</span>
          )}
        </div>

        {/* Medicine Grid */}
        {paginatedMedicines.length === 0 ? (
          <div className="card" style={{ textAlign: 'center', padding: '64px 20px' }}>
            <Pill size={48} color="var(--color-muted)" style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>No matching medicines found</h3>
            <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem', marginBottom: '20px' }}>
              We could not find any medicine matching <strong>&quot;{query}&quot;</strong> under the selected dosage filter.
            </p>
            <button onClick={handleReset} className="btn btn-primary btn-sm">
              Clear All Filters
            </button>
          </div>
        ) : (
          <div className="grid-4" style={{ gap: '20px', marginBottom: '40px' }}>
            {paginatedMedicines.map((med) => (
              <MedicineCard key={med.id} medicine={med} />
            ))}
          </div>
        )}

        {/* Pagination Controls */}
        {totalPages > 1 && (
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '12px',
            marginTop: '32px'
          }}>
            <button
              onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
              disabled={currentPage === 1}
              className="btn btn-secondary btn-sm"
              style={{ opacity: currentPage === 1 ? 0.5 : 1 }}
            >
              <ChevronLeft size={16} />
              <span>Previous</span>
            </button>

            <span style={{ fontSize: '0.9rem', fontWeight: 600, color: 'var(--color-forest-green)', padding: '0 8px' }}>
              {currentPage} / {totalPages}
            </span>

            <button
              onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
              disabled={currentPage === totalPages}
              className="btn btn-secondary btn-sm"
              style={{ opacity: currentPage === totalPages ? 0.5 : 1 }}
            >
              <span>Next</span>
              <ChevronRight size={16} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default function MedicineDirectoryPage() {
  return (
    <Suspense fallback={<div className="container" style={{ padding: '60px 0' }}>Loading Medicine Directory...</div>}>
      <MedicineDirectoryContent />
    </Suspense>
  );
}

