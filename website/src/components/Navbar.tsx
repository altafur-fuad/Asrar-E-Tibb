'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  HeartHandshake,
  ShoppingBag,
  Download,
  Menu,
  X,
  User,
  Newspaper,
  Pill,
  FileText,
  Video
} from 'lucide-react';
import { useCart } from '../context/CartContext';

export function Navbar() {
  const pathname = usePathname();
  const { totalItems, setIsCartOpen } = useCart();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navItems = [
    { name: 'Medicines', href: '/medicines', icon: Pill },
    { name: 'Farmacia', href: '/farmacia', icon: ShoppingBag },
    { name: 'TibbNews', href: '/news', icon: Newspaper },
    { name: 'Prescription AI', href: '/prescription-upload', icon: FileText, tag: 'Preview' },
    { name: 'Consultations', href: '/consultations', icon: Video, tag: 'Coming Soon' },
    { name: 'Download App', href: '/download', icon: Download },
  ];

  return (
    <header className="navbar-wrapper">
      <div className="container">
        <nav className="navbar">
          {/* Logo */}
          <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div style={{
              width: '42px',
              height: '42px',
              borderRadius: '12px',
              background: 'linear-gradient(135deg, var(--color-forest-green) 0%, var(--color-evergreen) 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 4px 10px rgba(6, 78, 59, 0.25)'
            }}>
              <HeartHandshake size={24} color="#FFFFFF" strokeWidth={2.2} />
            </div>
            <div>
              <span style={{
                fontFamily: 'var(--font-heading)',
                fontSize: '1.35rem',
                fontWeight: 800,
                color: 'var(--color-forest-green)',
                letterSpacing: '-0.3px',
                display: 'block',
                lineHeight: 1.1
              }}>
                Asrar-e-Tibb
              </span>
              <span style={{
                fontSize: '0.7rem',
                color: 'var(--color-fresh-green)',
                fontWeight: 600,
                letterSpacing: '1px',
                textTransform: 'uppercase'
              }}>
                Healthcare & Pharmacy
              </span>
            </div>
          </Link>

          {/* Desktop Nav Links */}
          <div className="nav-links">
            {navItems.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`nav-link ${isActive ? 'active' : ''}`}
                  style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
                >
                  <span>{item.name}</span>
                  {item.tag && (
                    <span style={{
                      fontSize: '0.62rem',
                      fontWeight: 700,
                      padding: '2px 6px',
                      borderRadius: '4px',
                      background: item.tag === 'Preview' ? '#E0F2FE' : '#FEF3C7',
                      color: item.tag === 'Preview' ? '#0369A1' : '#92400E'
                    }}>
                      {item.tag}
                    </span>
                  )}
                </Link>
              );
            })}
          </div>

          {/* Right Action Buttons */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
            {/* Cart Button */}
            <button
              onClick={() => setIsCartOpen(true)}
              style={{
                position: 'relative',
                padding: '10px',
                borderRadius: 'var(--radius-md)',
                color: 'var(--color-forest-green)',
                background: 'var(--color-soft-sage)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                transition: 'all var(--transition-fast)'
              }}
              title="Open Shopping Cart"
            >
              <ShoppingBag size={20} />
              {totalItems > 0 && (
                <span style={{
                  position: 'absolute',
                  top: '-4px',
                  right: '-4px',
                  background: 'var(--color-error)',
                  color: 'white',
                  fontSize: '0.7rem',
                  fontWeight: 700,
                  width: '18px',
                  height: '18px',
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  {totalItems}
                </span>
              )}
            </button>

            {/* Account Link */}
            <Link
              href="/login"
              className="btn btn-secondary btn-sm"
              style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
            >
              <User size={16} />
              <span>Sign In</span>
            </Link>

            {/* Mobile Menu Trigger */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              style={{ display: 'none', padding: '8px', color: 'var(--color-forest-green)' }}
              className="mobile-toggle"
            >
              {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </nav>

        {/* Mobile Dropdown */}
        {mobileMenuOpen && (
          <div style={{
            padding: '16px 0 24px',
            borderTop: '1px solid var(--color-border)',
            display: 'flex',
            flexDirection: 'column',
            gap: '14px'
          }}>
            {navItems.map((item) => {
              const Icon = item.icon;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  onClick={() => setMobileMenuOpen(false)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '10px',
                    padding: '8px 12px',
                    borderRadius: '8px',
                    fontWeight: 600,
                    color: pathname === item.href ? 'var(--color-fresh-green)' : 'var(--color-deep-ink)',
                    background: pathname === item.href ? 'var(--color-soft-sage)' : 'transparent'
                  }}
                >
                  <Icon size={18} />
                  <span>{item.name}</span>
                </Link>
              );
            })}
          </div>
        )}
      </div>
    </header>
  );
}

