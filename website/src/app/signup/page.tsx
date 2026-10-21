'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { HeartHandshake, Lock, Mail, User, ShieldCheck, AlertCircle, ArrowRight } from 'lucide-react';

export default function SignUpPage() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('patient');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [registered, setRegistered] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    setTimeout(() => {
      setLoading(false);
      if (!name || !email.includes('@') || password.length < 6) {
        setError('Please fill all required fields with a password of at least 6 characters.');
      } else {
        setRegistered(true);
      }
    }, 600);
  };

  return (
    <div style={{ padding: '64px 0 96px' }}>
      <div className="container" style={{ maxWidth: '520px' }}>
        <div className="card" style={{ padding: '40px', background: 'var(--color-white)', borderRadius: '24px', boxShadow: 'var(--shadow-lg)' }}>
          {/* Logo Header */}
          <div style={{ textAlign: 'center', marginBottom: '28px' }}>
            <div style={{
              width: '48px',
              height: '48px',
              borderRadius: '14px',
              background: 'linear-gradient(135deg, var(--color-forest-green) 0%, var(--color-evergreen) 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 14px'
            }}>
              <HeartHandshake size={28} color="#FFFFFF" />
            </div>
            <h1 style={{ fontSize: '1.75rem', color: 'var(--color-forest-green)', marginBottom: '6px' }}>
              Create Your Account
            </h1>
            <p style={{ fontSize: '0.9rem', color: 'var(--color-muted)' }}>
              Join the Asrar-e-Tibb healthcare & pharmacy network.
            </p>
          </div>

          {registered ? (
            <div style={{ textAlign: 'center', padding: '24px 0' }}>
              <div style={{ width: '54px', height: '54px', borderRadius: '50%', background: 'var(--color-soft-sage)', color: 'var(--color-forest-green)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
                <ShieldCheck size={32} />
              </div>
              <h3 style={{ fontSize: '1.25rem', marginBottom: '8px' }}>Account Registered!</h3>
              <p style={{ color: 'var(--color-muted)', fontSize: '0.9rem', marginBottom: '24px' }}>
                Account registered for <strong>{name}</strong> ({role}). A confirmation link has been simulated for staging review.
              </p>
              <Link href="/login" className="btn btn-primary" style={{ width: '100%', justifyContent: 'center' }}>
                Proceed to Sign In
              </Link>
            </div>
          ) : (
            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
              {error && (
                <div style={{
                  padding: '12px 16px',
                  borderRadius: 'var(--radius-md)',
                  background: '#FEE2E2',
                  border: '1px solid #FCA5A5',
                  color: '#991B1B',
                  fontSize: '0.85rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px'
                }}>
                  <AlertCircle size={18} style={{ flexShrink: 0 }} />
                  <span>{error}</span>
                </div>
              )}

              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--color-deep-ink)', display: 'block', marginBottom: '6px' }}>
                  Full Name
                </label>
                <div style={{ position: 'relative' }}>
                  <User size={18} color="var(--color-muted)" style={{ position: 'absolute', left: '14px', top: '14px' }} />
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. Altafur Rahman"
                    className="input-field"
                    style={{ paddingLeft: '42px' }}
                  />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--color-deep-ink)', display: 'block', marginBottom: '6px' }}>
                  Email Address
                </label>
                <div style={{ position: 'relative' }}>
                  <Mail size={18} color="var(--color-muted)" style={{ position: 'absolute', left: '14px', top: '14px' }} />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="name@example.com"
                    className="input-field"
                    style={{ paddingLeft: '42px' }}
                  />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--color-deep-ink)', display: 'block', marginBottom: '6px' }}>
                  Account Role
                </label>
                <select
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                  className="input-field"
                  style={{ background: 'var(--color-white)' }}
                >
                  <option value="patient">Patient (General Wellness)</option>
                  <option value="doctor">Medical Doctor (Physician)</option>
                  <option value="pharmacist">Registered Pharmacist</option>
                  <option value="shop owner">Pharmacy / Medicine Shop Owner</option>
                </select>
                <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)', marginTop: '4px', display: 'block' }}>
                  *Note: Administrative accounts cannot be created via public registration per database security policy.
                </span>
              </div>

              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--color-deep-ink)', display: 'block', marginBottom: '6px' }}>
                  Password
                </label>
                <div style={{ position: 'relative' }}>
                  <Lock size={18} color="var(--color-muted)" style={{ position: 'absolute', left: '14px', top: '14px' }} />
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="At least 6 characters"
                    className="input-field"
                    style={{ paddingLeft: '42px' }}
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="btn btn-primary"
                style={{ width: '100%', justifyContent: 'center', marginTop: '6px' }}
              >
                {loading ? 'Creating Account...' : 'Complete Registration'}
                <ArrowRight size={18} />
              </button>

              <div style={{
                textAlign: 'center',
                paddingTop: '16px',
                borderTop: '1px solid var(--color-border)',
                fontSize: '0.88rem',
                color: 'var(--color-muted)'
              }}>
                Already have an account?{' '}
                <Link href="/login" style={{ color: 'var(--color-forest-green)', fontWeight: 700 }}>
                  Sign In
                </Link>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
