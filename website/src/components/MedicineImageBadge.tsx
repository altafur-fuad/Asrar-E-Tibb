'use client';

import React, { useState } from 'react';
import {
  Pill,
  FlaskConical,
  Syringe,
  Wind,
  Droplet,
  Sparkles,
  Layers,
  HelpCircle
} from 'lucide-react';

interface MedicineImageBadgeProps {
  dosageForm: string;
  brandName?: string;
  imageUrl?: string | null;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function MedicineImageBadge({
  dosageForm,
  brandName = '',
  imageUrl,
  size = 'md',
  className = ''
}: MedicineImageBadgeProps) {
  const [imgError, setImgError] = useState(false);

  const formLower = (dosageForm || '').toLowerCase();

  // Validate that the image URL is not a monograph PDF/document or developer photo
  const isValidImageUrl =
    imageUrl &&
    !imgError &&
    typeof imageUrl === 'string' &&
    imageUrl.trim().length > 0 &&
    !imageUrl.includes('pic.png') &&
    !imageUrl.includes('medex.com.bd/attachments') &&
    !imageUrl.includes('prescribing-information') &&
    !imageUrl.toLowerCase().endsWith('.pdf');

  let Icon = Pill;
  let bgGradient = 'linear-gradient(135deg, #E6F0EA 0%, #D0E4D7 100%)';
  let iconColor = '#064E3B';
  let badgeLabel = 'Medicine';

  if (formLower.includes('tablet')) {
    Icon = Pill;
    bgGradient = 'linear-gradient(135deg, #ECFDF5 0%, #D1FAE5 100%)';
    iconColor = '#065F46';
    badgeLabel = 'Tablet';
  } else if (formLower.includes('capsule')) {
    Icon = Layers;
    bgGradient = 'linear-gradient(135deg, #FEF3C7 0%, #FDE68A 100%)';
    iconColor = '#92400E';
    badgeLabel = 'Capsule';
  } else if (formLower.includes('syrup') || formLower.includes('suspension') || formLower.includes('solution') || formLower.includes('liquid')) {
    Icon = FlaskConical;
    bgGradient = 'linear-gradient(135deg, #E0F2FE 0%, #BAE6FD 100%)';
    iconColor = '#0369A1';
    badgeLabel = 'Liquid';
  } else if (formLower.includes('injection') || formLower.includes('infusion') || formLower.includes('vial') || formLower.includes('ampoule')) {
    Icon = Syringe;
    bgGradient = 'linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%)';
    iconColor = '#991B1B';
    badgeLabel = 'Injectable';
  } else if (formLower.includes('inhaler') || formLower.includes('spray') || formLower.includes('nebuliser')) {
    Icon = Wind;
    bgGradient = 'linear-gradient(135deg, #F3E8FF 0%, #E9D5FF 100%)';
    iconColor = '#6B21A8';
    badgeLabel = 'Inhalation';
  } else if (formLower.includes('drop')) {
    Icon = Droplet;
    bgGradient = 'linear-gradient(135deg, #CCFBF1 0%, #99F6E4 100%)';
    iconColor = '#115E59';
    badgeLabel = 'Drops';
  } else if (formLower.includes('cream') || formLower.includes('ointment') || formLower.includes('gel')) {
    Icon = Sparkles;
    bgGradient = 'linear-gradient(135deg, #FEF9C3 0%, #FEF08A 100%)';
    iconColor = '#854D0E';
    badgeLabel = 'Topical';
  }

  const dimensions = {
    sm: { box: '48px', iconSize: 22, fontSize: '0.65rem' },
    md: { box: '80px', iconSize: 36, fontSize: '0.75rem' },
    lg: { box: '140px', iconSize: 64, fontSize: '0.85rem' }
  }[size];

  // Extract brand initials monogram (e.g. "A-Cold" -> "AC", "Napa Extra" -> "NE")
  const monogram = brandName
    .split(/[\s\-]+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0].toUpperCase())
    .join('');

  if (isValidImageUrl) {
    return (
      <div
        className={`medicine-badge ${className}`}
        style={{
          width: dimensions.box,
          height: dimensions.box,
          borderRadius: size === 'sm' ? '8px' : '16px',
          overflow: 'hidden',
          border: '1px solid var(--color-border)',
          background: 'var(--color-white)',
          flexShrink: 0
        }}
      >
        <img
          src={imageUrl!}
          alt={brandName ? `${brandName} product image` : 'Medicine product image'}
          style={{ width: '100%', height: '100%', objectFit: 'contain' }}
          onError={() => setImgError(true)}
        />
      </div>
    );
  }

  return (
    <div
      className={`medicine-badge ${className}`}
      style={{
        width: dimensions.box,
        height: dimensions.box,
        background: bgGradient,
        borderRadius: size === 'sm' ? '8px' : '16px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: size === 'sm' ? '2px' : '4px',
        boxShadow: 'inset 0 1px 2px rgba(255,255,255,0.8), 0 2px 6px rgba(18,35,29,0.06)',
        border: '1px solid rgba(0,0,0,0.06)',
        position: 'relative',
        overflow: 'hidden',
        flexShrink: 0
      }}
      title={`${badgeLabel} — Asrar-e-Tibb Pharmaceutical Standard`}
    >
      {/* Subtle brand monogram in background */}
      {monogram && size !== 'sm' && (
        <span
          style={{
            position: 'absolute',
            bottom: '2px',
            right: '6px',
            fontSize: size === 'lg' ? '2.4rem' : '1.4rem',
            fontWeight: 900,
            color: iconColor,
            opacity: 0.08,
            userSelect: 'none',
            lineHeight: 1
          }}
        >
          {monogram}
        </span>
      )}

      <Icon size={dimensions.iconSize} color={iconColor} strokeWidth={1.75} />
      {size !== 'sm' && (
        <span
          style={{
            fontSize: dimensions.fontSize,
            fontWeight: 700,
            color: iconColor,
            letterSpacing: '0.2px',
            textTransform: 'uppercase',
            textAlign: 'center',
            lineHeight: 1
          }}
        >
          {badgeLabel}
        </span>
      )}
    </div>
  );
}
