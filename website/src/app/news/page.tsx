'use client';

import React, { useState } from 'react';
import { Newspaper, Calendar, Clock, User, Tag, ArrowRight, ShieldCheck } from 'lucide-react';
import articles from '../../data/news.json';

export default function NewsFeedPage() {
  const [selectedTag, setSelectedTag] = useState('All');

  const allTags = ['All', 'Antibiotics', 'Classical Tibb', 'Respiratory', 'Storage', 'Hypertension'];

  const filteredArticles = selectedTag === 'All'
    ? articles
    : articles.filter((a) => a.tags.includes(selectedTag));

  return (
    <div style={{ padding: '48px 0 80px' }}>
      <div className="container">
        {/* Header */}
        <div style={{ maxWidth: '720px', marginBottom: '36px' }}>
          <span className="pill pill-green" style={{ marginBottom: '8px' }}>
            Clinical & Wellness Editorial
          </span>
          <h1 style={{ fontSize: '2.4rem', marginBottom: '12px' }}>
            TibbNews — Healthcare Intelligence
          </h1>
          <p style={{ color: 'var(--color-muted)', fontSize: '1.05rem', lineHeight: 1.6 }}>
            Evidence-based medical updates, pharmaceutical stewardship insights, and classical herbal therapy wisdom curated by licensed practitioners.
          </p>
        </div>

        {/* Filter tags */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '32px' }}>
          {allTags.map((tag) => (
            <button
              key={tag}
              onClick={() => setSelectedTag(tag)}
              style={{
                padding: '6px 16px',
                borderRadius: 'var(--radius-full)',
                fontWeight: 600,
                fontSize: '0.85rem',
                border: `1.5px solid ${selectedTag === tag ? 'var(--color-forest-green)' : 'var(--color-border)'}`,
                background: selectedTag === tag ? 'var(--color-forest-green)' : 'var(--color-white)',
                color: selectedTag === tag ? 'white' : 'var(--color-deep-ink)',
                cursor: 'pointer',
                transition: 'all 150ms ease'
              }}
            >
              {tag}
            </button>
          ))}
        </div>

        {/* Articles List */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '880px' }}>
          {filteredArticles.map((article) => (
            <article
              key={article.id}
              className="card"
              style={{ padding: '32px', background: 'var(--color-white)' }}
            >
              <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '14px', marginBottom: '12px', fontSize: '0.82rem', color: 'var(--color-muted)' }}>
                <span className="pill pill-green" style={{ fontSize: '0.72rem' }}>
                  {article.category}
                </span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Calendar size={14} />
                  {article.published_at}
                </span>
                <span>•</span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Clock size={14} />
                  {article.read_time}
                </span>
              </div>

              <h2 style={{ fontSize: '1.5rem', marginBottom: '10px', color: 'var(--color-forest-green)' }}>
                {article.title}
              </h2>

              <p style={{ color: 'var(--color-deep-ink)', fontSize: '0.98rem', lineHeight: 1.6, marginBottom: '18px' }}>
                {article.summary}
              </p>

              <div style={{
                display: 'flex',
                flexWrap: 'wrap',
                alignItems: 'center',
                justifyContent: 'space-between',
                paddingTop: '16px',
                borderTop: '1px solid var(--color-border)',
                gap: '12px'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.88rem', color: 'var(--color-forest-green)', fontWeight: 600 }}>
                  <User size={16} />
                  <span>{article.author}</span>
                </div>

                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                  {article.tags.map((t) => (
                    <span key={t} className="pill pill-outline" style={{ fontSize: '0.7rem' }}>
                      #{t}
                    </span>
                  ))}
                </div>
              </div>
            </article>
          ))}
        </div>
      </div>
    </div>
  );
}

