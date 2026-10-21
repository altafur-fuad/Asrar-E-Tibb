'use client';

import React, { useState, useMemo, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import {
  ShoppingBag,
  Search,
  Truck,
  ShieldCheck,
  FileCheck,
  Clock,
  ArrowRight,
  Filter
} from 'lucide-react';
import { MedicineCard, Medicine } from '../../components/MedicineCard';
import { useCart } from '../../context/CartContext';
import rawMedicines from '../../data/medicines.json';

const farmaciaCatalog: Medicine[] = rawMedicines.slice(0, 48) as Medicine[];

function FarmaciaContent() {
  const searchParams = useSearchParams();
  const { addToCart, setIsCartOpen, totalItems, totalPrice } = useCart();
  const [filterQuery, setFilterQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');

  const categories = ['All', 'Tablet', 'Syrup', 'Capsule', 'Injection', 'Drop'];

  const filteredItems = useMemo(() => {
    return farmaciaCatalog.filter((item) => {
      const matchesQ =
        !filterQuery ||
        item.name.toLowerCase().includes(filterQuery.toLowerCase()) ||
        item.generic.toLowerCase().includes(filterQuery.toLowerCase());

      const matchesCat =
        activeCategory === 'All' ||
        item.dosage_form.toLowerCase().includes(activeCategory.toLowerCase());

      return matchesQ && matchesCat;
    });
  }, [filterQuery, activeCategory]);

  return (
    <div style={{ padding: '48px 0 80px' }}>
      <div className="container">
        {/* Banner */}
        <div style={{
          background: 'linear-gradient(135deg, var(--color-forest-green) 0%, var(--color-evergreen) 100%)',
          borderRadius: '20px',
          padding: '40px',
          color: 'white',
          marginBottom: '40px',
          boxShadow: 'var(--shadow-lg)',
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: '24px'
        }}>
          <div style={{ maxWidth: '600px' }}>
            <span style={{
              display: 'inline-block',
              background: 'rgba(255,255,255,0.15)',
              padding: '4px 12px',
              borderRadius: 'var(--radius-full)',
              fontSize: '0.75rem',
              fontWeight: 700,
              textTransform: 'uppercase',
              letterSpacing: '1px',
              marginBottom: '12px'
            }}>
              Licensed Pharmacy Partner Network
            </span>
            <h1 style={{ color: 'white', fontSize: '2.4rem', marginBottom: '10px' }}>
              Farmacia Digital Storefront
            </h1>
            <p style={{ color: '#D1FAE5', fontSize: '1rem', lineHeight: 1.5 }}>
              Order genuine prescription and wellness medications directly. Every order is reviewed by a licensed clinical pharmacist before dispatch.
            </p>
          </div>

          <div style={{
            background: 'rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(8px)',
            borderRadius: '16px',
            padding: '20px',
            border: '1px solid rgba(255, 255, 255, 0.2)',
            minWidth: '220px',
            textAlign: 'center'
          }}>
            <ShoppingBag size={32} color="var(--color-restrained-amber)" style={{ margin: '0 auto 8px' }} />
            <div style={{ fontSize: '1.25rem', fontWeight: 800 }}>
              {totalItems} {totalItems === 1 ? 'Item' : 'Items'} in Cart
            </div>
            <div style={{ fontSize: '0.9rem', color: '#D1FAE5', marginBottom: '12px' }}>
              Subtotal: ৳ {totalPrice.toFixed(2)}
            </div>
            <button
              onClick={() => setIsCartOpen(true)}
              className="btn btn-amber btn-sm"
              style={{ width: '100%' }}
            >
              View Cart Drawer
            </button>
          </div>
        </div>

        {/* Pharmacy Trust Badges */}
        <div className="grid-3" style={{ gap: '20px', marginBottom: '36px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', background: 'var(--color-white)', padding: '16px 20px', borderRadius: '12px', border: '1px solid var(--color-border)' }}>
            <ShieldCheck size={28} color="var(--color-forest-green)" />
            <div>
              <h4 style={{ fontSize: '0.95rem', marginBottom: '2px' }}>100% Genuine Formulations</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--color-muted)' }}>Direct from registered manufacturers</p>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', background: 'var(--color-white)', padding: '16px 20px', borderRadius: '12px', border: '1px solid var(--color-border)' }}>
            <FileCheck size={28} color="var(--color-forest-green)" />
            <div>
              <h4 style={{ fontSize: '0.95rem', marginBottom: '2px' }}>Prescription Verification</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--color-muted)' }}>Pharmacist validation on every item</p>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', background: 'var(--color-white)', padding: '16px 20px', borderRadius: '12px', border: '1px solid var(--color-border)' }}>
            <Truck size={28} color="var(--color-forest-green)" />
            <div>
              <h4 style={{ fontSize: '0.95rem', marginBottom: '2px' }}>Temperature-Controlled</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--color-muted)' }}>Cold-chain integrity preserved</p>
            </div>
          </div>
        </div>

        {/* Filter controls */}
        <div style={{
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: '16px',
          marginBottom: '28px'
        }}>
          {/* Category Chips */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                style={{
                  padding: '8px 18px',
                  borderRadius: 'var(--radius-full)',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  border: `1.5px solid ${activeCategory === cat ? 'var(--color-forest-green)' : 'var(--color-border)'}`,
                  background: activeCategory === cat ? 'var(--color-forest-green)' : 'var(--color-white)',
                  color: activeCategory === cat ? 'white' : 'var(--color-deep-ink)',
                  transition: 'all 150ms ease'
                }}
              >
                {cat}
              </button>
            ))}
          </div>

          {/* Quick Search */}
          <div style={{ position: 'relative', width: '280px' }}>
            <Search size={18} color="var(--color-muted)" style={{ position: 'absolute', left: '12px', top: '12px' }} />
            <input
              type="text"
              value={filterQuery}
              onChange={(e) => setFilterQuery(e.target.value)}
              placeholder="Search storefront items..."
              className="input-field"
              style={{ paddingLeft: '38px', paddingRight: '12px', fontSize: '0.88rem' }}
            />
          </div>
        </div>

        {/* Products Grid */}
        <div className="grid-4" style={{ gap: '20px' }}>
          {filteredItems.map((med) => (
            <MedicineCard key={med.id} medicine={med} showAddToCart={true} />
          ))}
        </div>
      </div>
    </div>
  );
}

export default function FarmaciaPage() {
  return (
    <Suspense fallback={<div className="container" style={{ padding: '60px 0' }}>Loading Farmacia Storefront...</div>}>
      <FarmaciaContent />
    </Suspense>
  );
}

