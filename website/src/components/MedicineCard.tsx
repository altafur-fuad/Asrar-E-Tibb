'use client';

import React from 'react';
import Link from 'next/link';
import { ShoppingBag, ArrowRight } from 'lucide-react';
import { MedicineImageBadge } from './MedicineImageBadge';
import { useCart } from '../context/CartContext';
import { Medicine } from '../lib/medicines';

interface MedicineCardProps {
  medicine: Medicine;
  showAddToCart?: boolean;
}

export function MedicineCard({ medicine, showAddToCart = true }: MedicineCardProps) {
  const { addToCart } = useCart();

  return (
    <div className="card" style={{
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      gap: '16px',
      height: '100%',
      background: 'var(--color-white)',
      border: '1px solid var(--color-border)',
      borderRadius: 'var(--radius-lg)',
      padding: '20px',
      transition: 'transform 150ms ease, box-shadow 150ms ease'
    }}>
      <div>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: '12px' }}>
          <MedicineImageBadge
            dosageForm={medicine.dosage_form}
            brandName={medicine.name}
            imageUrl={medicine.image_url}
            size="md"
          />
          <span className="pill pill-outline" style={{ fontSize: '0.72rem', textTransform: 'capitalize' }}>
            {medicine.dosage_form}
          </span>
        </div>

        <div style={{ marginTop: '16px' }}>
          <h3 style={{ fontSize: '1.15rem', marginBottom: '4px', fontWeight: 700 }}>
            <Link href={`/medicines/${medicine.slug}`} style={{ color: 'var(--color-forest-green)' }}>
              {medicine.name}
            </Link>
          </h3>

          {/* Generic Link */}
          <p style={{ fontSize: '0.88rem', color: 'var(--color-muted)', fontWeight: 500, marginBottom: '6px' }}>
            {medicine.generic_slug ? (
              <Link
                href={`/generics/${medicine.generic_slug}`}
                style={{ color: 'var(--color-forest-green)', textDecoration: 'underline', textDecorationColor: 'rgba(6,78,59,0.3)' }}
                title="View generic monograph & all brand alternatives"
              >
                {medicine.generic}
              </Link>
            ) : (
              medicine.generic
            )}
            {medicine.strength && <span style={{ color: 'var(--color-deep-ink)' }}> • {medicine.strength}</span>}
          </p>

          <p style={{ fontSize: '0.8rem', color: '#64748B' }}>
            {medicine.manufacturer}
          </p>
        </div>
      </div>

      <div style={{
        paddingTop: '14px',
        borderTop: '1px solid var(--color-border)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between'
      }}>
        <div>
          <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)', display: 'block' }}>Package Price</span>
          <span style={{ fontSize: '1.05rem', fontWeight: 700, color: 'var(--color-forest-green)' }}>
            {medicine.price}
          </span>
        </div>

        <div style={{ display: 'flex', gap: '8px' }}>
          <Link
            href={`/medicines/${medicine.slug}`}
            className="btn btn-secondary btn-sm"
            title="View complete clinical details and alternative brands"
          >
            <ArrowRight size={16} />
          </Link>
          {showAddToCart && (
            <button
              onClick={() => addToCart({
                id: medicine.id,
                name: medicine.name,
                slug: medicine.slug,
                dosage_form: medicine.dosage_form,
                strength: medicine.strength,
                price: medicine.price
              })}
              className="btn btn-primary btn-sm"
              title="Add to Farmacia Cart"
            >
              <ShoppingBag size={16} />
              <span>Add</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
export type { Medicine };
