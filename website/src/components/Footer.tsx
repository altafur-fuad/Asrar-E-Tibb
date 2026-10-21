import React from 'react';
import Link from 'next/link';
import { HeartHandshake, ShieldCheck, Mail, MapPin, Phone, Github } from 'lucide-react';

export function Footer() {
  return (
    <footer style={{
      background: 'var(--color-forest-green)',
      color: 'var(--color-white)',
      paddingTop: '64px',
      paddingBottom: '32px',
      marginTop: '80px',
      borderTop: '4px solid var(--color-fresh-green)'
    }}>
      <div className="container">
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
          gap: '40px',
          marginBottom: '48px'
        }}>
          {/* Brand Col */}
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
              <div style={{
                width: '36px',
                height: '36px',
                borderRadius: '10px',
                background: 'var(--color-fresh-green)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <HeartHandshake size={20} color="#FFFFFF" />
              </div>
              <span style={{
                fontFamily: 'var(--font-heading)',
                fontSize: '1.25rem',
                fontWeight: 800,
                color: 'var(--color-white)'
              }}>
                Asrar-e-Tibb
              </span>
            </div>
            <p style={{ fontSize: '0.9rem', color: '#CBD5E1', lineHeight: 1.6, marginBottom: '20px' }}>
              Bridging classical natural healthcare and modern evidence-based pharmacy. Offering genuine medicine intelligence, professional directory lookups, and community health insights.
            </p>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--color-restrained-amber)', fontSize: '0.85rem' }}>
              <ShieldCheck size={18} />
              <span>Verified Clinical Datasets</span>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 style={{ color: 'var(--color-white)', fontSize: '1.05rem', marginBottom: '18px' }}>
              Directory & Services
            </h4>
            <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.9rem' }}>
              <li>
                <Link href="/medicines" style={{ color: '#E2E8F0', transition: 'color 150ms' }}>
                  Medicine Directory
                </Link>
              </li>
              <li>
                <Link href="/farmacia" style={{ color: '#E2E8F0' }}>
                  Farmacia Storefront
                </Link>
              </li>
              <li>
                <Link href="/news" style={{ color: '#E2E8F0' }}>
                  TibbNews Health Feed
                </Link>
              </li>
              <li>
                <Link href="/download" style={{ color: '#E2E8F0' }}>
                  Android Mobile Application
                </Link>
              </li>
              <li>
                <Link href="/prescription-upload" style={{ color: '#94A3B8' }}>
                  AI Prescription OCR (Coming Soon)
                </Link>
              </li>
            </ul>
          </div>

          {/* Support & Legal */}
          <div>
            <h4 style={{ color: 'var(--color-white)', fontSize: '1.05rem', marginBottom: '18px' }}>
              Support & Ethics
            </h4>
            <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.9rem' }}>
              <li>
                <Link href="/about" style={{ color: '#E2E8F0' }}>
                  About Our Mission
                </Link>
              </li>
              <li>
                <Link href="/contact" style={{ color: '#E2E8F0' }}>
                  Contact Pharmacists
                </Link>
              </li>
              <li>
                <Link href="/privacy" style={{ color: '#E2E8F0' }}>
                  Health Privacy Standards
                </Link>
              </li>
              <li>
                <Link href="/terms" style={{ color: '#E2E8F0' }}>
                  Terms of Service & Usage
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact & GitHub */}
          <div>
            <h4 style={{ color: 'var(--color-white)', fontSize: '1.05rem', marginBottom: '18px' }}>
              Official Repository
            </h4>
            <p style={{ fontSize: '0.88rem', color: '#CBD5E1', marginBottom: '14px' }}>
              Open-source healthcare technology built with Flutter, Next.js, Axum, and Supabase.
            </p>
            <a
              href="https://github.com/altafur-fuad/Asrar-E-Tibb"
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-secondary btn-sm"
              style={{ background: 'rgba(255,255,255,0.1)', color: 'white', border: '1px solid rgba(255,255,255,0.2)' }}
            >
              <Github size={16} />
              <span>altafur-fuad/Asrar-E-Tibb</span>
            </a>
          </div>
        </div>

        {/* Clinical Disclaimer */}
        <div style={{
          padding: '20px',
          borderRadius: '12px',
          background: 'rgba(0, 0, 0, 0.2)',
          fontSize: '0.8rem',
          color: '#94A3B8',
          lineHeight: 1.5,
          marginBottom: '24px'
        }}>
          <strong>Medical Information Disclaimer:</strong> Asrar-e-Tibb provides pharmaceutical indications, generic references, and dosage information for educational and reference purposes only. Always consult a registered medical doctor or certified pharmacist before starting or modifying any treatment regimen. In emergency situations, visit your nearest hospital immediately.
        </div>

        {/* Bottom bar */}
        <div style={{
          paddingTop: '20px',
          borderTop: '1px solid rgba(255, 255, 255, 0.1)',
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          justifyContent: 'space-between',
          fontSize: '0.82rem',
          color: '#94A3B8',
          gap: '12px'
        }}>
          <span>© {new Date().getFullYear()} Asrar-e-Tibb. All rights reserved.</span>
          <span>Designed with Forest Green, Evergreen & Warm Ivory healthcare tokens.</span>
        </div>
      </div>
    </footer>
  );
}

