import React from 'react';
import Link from 'next/link';
import { HeartHandshake, ShieldCheck, BookOpen, Sparkles, Building2, CheckCircle2 } from 'lucide-react';

export default function AboutPage() {
  return (
    <div style={{ padding: '60px 0 96px' }}>
      <div className="container" style={{ maxWidth: '860px' }}>
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <span className="pill pill-green" style={{ marginBottom: '8px' }}>
            Our Heritage & Purpose
          </span>
          <h1 style={{ fontSize: '2.6rem', color: 'var(--color-forest-green)', marginBottom: '16px' }}>
            About Asrar-e-Tibb
          </h1>
          <p style={{ fontSize: '1.15rem', color: 'var(--color-muted)', lineHeight: 1.6 }}>
            Bridging the timeless wisdom of traditional natural healing (Tibb) with contemporary evidence-based pharmaceutical science.
          </p>
        </div>

        <div className="card" style={{ padding: '40px', background: 'var(--color-white)', borderRadius: '24px', marginBottom: '32px' }}>
          <h2 style={{ fontSize: '1.6rem', color: 'var(--color-forest-green)', marginBottom: '14px' }}>
            Our Core Mission
          </h2>
          <p style={{ fontSize: '1rem', color: 'var(--color-deep-ink)', lineHeight: 1.7, marginBottom: '20px' }}>
            Asrar-e-Tibb (&quot;Secrets of Medicine&quot;) was founded with a singular conviction: access to accurate pharmaceutical intelligence and ethical wellness guidance should be transparent, accessible, and grounded in verified science.
          </p>
          <p style={{ fontSize: '1rem', color: 'var(--color-deep-ink)', lineHeight: 1.7 }}>
            In an era of rampant misinformation and unverified digital drug claims, our platform maintains a comprehensive registry of over 21,700 verified medicines, linking proprietary brand names to their active generic ingredients, official strengths, approved indications, and packaging standards.
          </p>
        </div>

        <div className="grid-2" style={{ gap: '24px', marginBottom: '32px' }}>
          <div className="card" style={{ padding: '32px' }}>
            <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: 'var(--color-soft-sage)', color: 'var(--color-forest-green)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px' }}>
              <BookOpen size={24} />
            </div>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '8px' }}>Authentic Classical Tibb</h3>
            <p style={{ fontSize: '0.92rem', color: 'var(--color-muted)', lineHeight: 1.6 }}>
              Preserving traditional Unani, Ayurvedic, and herbal formulations with rigorous documentation of indications and preventive lifestyle regimens.
            </p>
          </div>

          <div className="card" style={{ padding: '32px' }}>
            <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: '#FEF3C7', color: '#92400E', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px' }}>
              <ShieldCheck size={24} />
            </div>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '8px' }}>Modern Evidence Base</h3>
            <p style={{ fontSize: '0.92rem', color: 'var(--color-muted)', lineHeight: 1.6 }}>
              Cross-referencing all pharmaceutical entities with government health registries, ensuring safe dispensing and zero counterfeit promotions.
            </p>
          </div>
        </div>

        <div style={{ textAlign: 'center', paddingTop: '20px' }}>
          <Link href="/medicines" className="btn btn-primary btn-lg">
            Explore Medicine Directory
          </Link>
        </div>
      </div>
    </div>
  );
}
