'use client';

import React, { useState } from 'react';
import { Mail, Phone, MapPin, Send, CheckCircle2, MessageSquare } from 'lucide-react';

export default function ContactPage() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (name && email && message) {
      setSubmitted(true);
    }
  };

  return (
    <div style={{ padding: '60px 0 96px' }}>
      <div className="container" style={{ maxWidth: '960px' }}>
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <span className="pill pill-green" style={{ marginBottom: '8px' }}>
            Clinical Support & Inquiries
          </span>
          <h1 style={{ fontSize: '2.6rem', color: 'var(--color-forest-green)', marginBottom: '14px' }}>
            Contact Asrar-e-Tibb
          </h1>
          <p style={{ fontSize: '1.1rem', color: 'var(--color-muted)', maxWidth: '640px', margin: '0 auto' }}>
            Have questions about a medicine entry, clinical trial data, or pharmacy collaboration? Get in touch with our team.
          </p>
        </div>

        <div className="grid-2" style={{ gap: '36px' }}>
          {/* Info Card */}
          <div className="card" style={{ padding: '36px', background: 'var(--color-white)', borderRadius: '24px' }}>
            <h3 style={{ fontSize: '1.4rem', color: 'var(--color-forest-green)', marginBottom: '18px' }}>
              Healthcare Headquarters
            </h3>
            <p style={{ fontSize: '0.95rem', color: 'var(--color-muted)', lineHeight: 1.6, marginBottom: '28px' }}>
              Our clinical editorial and technical engineering teams are headquartered in Chittagong, Bangladesh.
            </p>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'flex', gap: '14px', alignItems: 'flex-start' }}>
                <MapPin size={20} color="var(--color-fresh-green)" style={{ flexShrink: 0, marginTop: '2px' }} />
                <div>
                  <h4 style={{ fontSize: '0.95rem', marginBottom: '2px' }}>Office Location</h4>
                  <span style={{ fontSize: '0.88rem', color: 'var(--color-muted)' }}>
                    Muradpur, Panchlaish, Chittagong, Bangladesh
                  </span>
                </div>
              </div>

              <div style={{ display: 'flex', gap: '14px', alignItems: 'flex-start' }}>
                <Mail size={20} color="var(--color-fresh-green)" style={{ flexShrink: 0, marginTop: '2px' }} />
                <div>
                  <h4 style={{ fontSize: '0.95rem', marginBottom: '2px' }}>Clinical Communications</h4>
                  <span style={{ fontSize: '0.88rem', color: 'var(--color-muted)' }}>
                    support@asraretibb.org • info@asraretibb.org
                  </span>
                </div>
              </div>

              <div style={{ display: 'flex', gap: '14px', alignItems: 'flex-start' }}>
                <Phone size={20} color="var(--color-fresh-green)" style={{ flexShrink: 0, marginTop: '2px' }} />
                <div>
                  <h4 style={{ fontSize: '0.95rem', marginBottom: '2px' }}>Pharmacy Helpline</h4>
                  <span style={{ fontSize: '0.88rem', color: 'var(--color-muted)' }}>
                    +880 1800-ASRAR (27727) • 9:00 AM - 9:00 PM BST
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Form Card */}
          <div className="card" style={{ padding: '36px', background: 'var(--color-white)', borderRadius: '24px' }}>
            {submitted ? (
              <div style={{ textAlign: 'center', padding: '40px 10px' }}>
                <CheckCircle2 size={54} color="var(--color-success)" style={{ margin: '0 auto 16px' }} />
                <h3 style={{ fontSize: '1.4rem', marginBottom: '8px' }}>Message Received</h3>
                <p style={{ color: 'var(--color-muted)', fontSize: '0.95rem', marginBottom: '24px' }}>
                  Thank you, <strong>{name}</strong>. A pharmacist or medical engineer will review your message and respond within 24 business hours.
                </p>
                <button
                  onClick={() => setSubmitted(false)}
                  className="btn btn-secondary btn-sm"
                >
                  Send Another Inquiry
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div>
                  <label style={{ fontSize: '0.85rem', fontWeight: 600, display: 'block', marginBottom: '6px' }}>
                    Your Name
                  </label>
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Altafur Rahman"
                    className="input-field"
                  />
                </div>

                <div>
                  <label style={{ fontSize: '0.85rem', fontWeight: 600, display: 'block', marginBottom: '6px' }}>
                    Your Email
                  </label>
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="name@example.com"
                    className="input-field"
                  />
                </div>

                <div>
                  <label style={{ fontSize: '0.85rem', fontWeight: 600, display: 'block', marginBottom: '6px' }}>
                    Subject
                  </label>
                  <input
                    type="text"
                    value={subject}
                    onChange={(e) => setSubject(e.target.value)}
                    placeholder="Medicine listing inquiry / Pharmacy partnership"
                    className="input-field"
                  />
                </div>

                <div>
                  <label style={{ fontSize: '0.85rem', fontWeight: 600, display: 'block', marginBottom: '6px' }}>
                    Message Details
                  </label>
                  <textarea
                    required
                    rows={4}
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Please explain your question or feedback in detail..."
                    className="input-field"
                    style={{ resize: 'vertical' }}
                  />
                </div>

                <button type="submit" className="btn btn-primary" style={{ width: '100%', justifyContent: 'center', marginTop: '6px' }}>
                  <Send size={16} />
                  <span>Transmit Inquiry</span>
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

