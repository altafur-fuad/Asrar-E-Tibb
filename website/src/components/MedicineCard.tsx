'use client';

import React from 'react';
import Link from 'next/link';
import { ShoppingBag, ArrowRight } from 'lucide-react';
import { MedicineImageBadge } from './MedicineImageBadge';
import { useCart } from '../context/CartContext';

export interface Medicine {
  id: string;
  name: string;
  slug: string;
  dosage_form: string;
  generic: string;
  strength: string;
  manufacturer: string;
  price: string;
  package_container?: string;
  drug_class?: string;
  indication?: string;
  type?: string;
}

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
      height: '100%'
    }}>
      <div>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: '12px' }}>
          <MedicineImageBadge dosageForm={medicine.dosage_form} size="md" />
          <span className="pill pill-outline" style={{ fontSize: '0.72rem' }}>
            {medicine.dosage_form}
          </span>
        </div>

        <div style={{ marginTop: '16px' }}>
          <h3 style={{ fontSize: '1.15rem', marginBottom: '4px' }}>
            <Link href={`/medicines/${medicine.slug}`} style={{ color: 'var(--color-forest-green)' }}>
              {medicine.name}
            </Link>
          </h3>
          <p style={{ fontSize: '0.88rem', color: 'var(--color-muted)', fontWeight: 500, marginBottom: '6px' }}>
            {medicine.strength ? `${medicine.generic} (${medicine.strength})` : medicine.generic}
          </p>
          <p style={{ fontSize: '0.8rem', color: '#718096' }}>
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
            title="View clinical details"
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
