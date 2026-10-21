import React from 'react';
import {
  Pill,
  FlaskConical,
  Syringe,
  Wind,
  Droplet,
  Sparkles,
  Layers,
  ShieldAlert,
  PackageCheck
} from 'lucide-react';

interface MedicineImageBadgeProps {
  dosageForm: string;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function MedicineImageBadge({
  dosageForm,
  size = 'md',
  className = ''
}: MedicineImageBadgeProps) {
  const formLower = (dosageForm || '').toLowerCase();

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
  } else if (formLower.includes('syrup') || formLower.includes('suspension')) {
    Icon = FlaskConical;
    bgGradient = 'linear-gradient(135deg, #E0F2FE 0%, #BAE6FD 100%)';
    iconColor = '#0369A1';
    badgeLabel = 'Liquid / Syrup';
  } else if (formLower.includes('injection') || formLower.includes('infusion')) {
    Icon = Syringe;
    bgGradient = 'linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%)';
    iconColor = '#991B1B';
    badgeLabel = 'Injectable';
  } else if (formLower.includes('inhaler') || formLower.includes('spray')) {
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
        gap: size === 'sm' ? '2px' : '6px',
        boxShadow: 'inset 0 1px 2px rgba(255,255,255,0.8), 0 2px 6px rgba(18,35,29,0.06)',
        border: '1px solid rgba(0,0,0,0.06)',
        flexShrink: 0
      }}
      title={`${badgeLabel} — Asrar-e-Tibb Pharmaceutical Standard`}
    >
      <Icon size={dimensions.iconSize} color={iconColor} strokeWidth={1.75} />
      {size !== 'sm' && (
        <span style={{
          fontSize: dimensions.fontSize,
          fontWeight: 700,
          color: iconColor,
          letterSpacing: '0.2px',
          textTransform: 'uppercase',
          textAlign: 'center',
          lineHeight: 1
        }}>
          {badgeLabel}
        </span>
      )}
    </div>
  );
}

