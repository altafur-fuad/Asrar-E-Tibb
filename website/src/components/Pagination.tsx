'use client';

import React from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export function Pagination({ currentPage, totalPages, onPageChange }: PaginationProps) {
  if (totalPages <= 1) return null;

  const getPageNumbers = (): (number | string)[] => {
    const pages: (number | string)[] = [];
    const maxVisible = 7;

    if (totalPages <= maxVisible) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      if (currentPage <= 4) {
        for (let i = 1; i <= 5; i++) {
          pages.push(i);
        }
        pages.push('...');
        pages.push(totalPages);
      } else if (currentPage >= totalPages - 3) {
        pages.push(1);
        pages.push('...');
        for (let i = totalPages - 4; i <= totalPages; i++) {
          pages.push(i);
        }
      } else {
        pages.push(1);
        pages.push('...');
        pages.push(currentPage - 1);
        pages.push(currentPage);
        pages.push(currentPage + 1);
        pages.push('...');
        pages.push(totalPages);
      }
    }

    return pages;
  };

  const pages = getPageNumbers();

  return (
    <nav
      aria-label="Medicine pagination"
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        flexWrap: 'wrap',
        gap: '6px',
        marginTop: '32px'
      }}
    >
      {/* Previous Button */}
      <button
        type="button"
        onClick={() => onPageChange(Math.max(currentPage - 1, 1))}
        disabled={currentPage === 1}
        className="btn btn-secondary btn-sm"
        style={{
          height: '38px',
          padding: '0 12px',
          display: 'inline-flex',
          alignItems: 'center',
          gap: '4px',
          opacity: currentPage === 1 ? 0.4 : 1,
          cursor: currentPage === 1 ? 'not-allowed' : 'pointer'
        }}
      >
        <ChevronLeft size={16} />
        <span className="hidden sm:inline">Prev</span>
      </button>

      {/* Numbered Page Buttons */}
      {pages.map((item, idx) => {
        if (item === '...') {
          return (
            <span
              key={`ellipsis-${idx}`}
              style={{
                width: '38px',
                height: '38px',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'var(--color-muted)',
                fontWeight: 600,
                fontSize: '0.9rem'
              }}
            >
              ...
            </span>
          );
        }

        const pageNum = item as number;
        const isActive = pageNum === currentPage;

        return (
          <button
            key={pageNum}
            type="button"
            onClick={() => onPageChange(pageNum)}
            aria-current={isActive ? 'page' : undefined}
            style={{
              minWidth: '38px',
              height: '38px',
              padding: '0 10px',
              borderRadius: '8px',
              fontSize: '0.88rem',
              fontWeight: isActive ? 700 : 500,
              background: isActive ? 'var(--color-forest-green)' : 'var(--color-white)',
              color: isActive ? 'white' : 'var(--color-deep-ink)',
              border: `1px solid ${isActive ? 'var(--color-forest-green)' : 'var(--color-border)'}`,
              cursor: 'pointer',
              transition: 'all 150ms ease',
              boxShadow: isActive ? '0 2px 4px rgba(6, 78, 59, 0.2)' : 'none'
            }}
          >
            {pageNum}
          </button>
        );
      })}

      {/* Next Button */}
      <button
        type="button"
        onClick={() => onPageChange(Math.min(currentPage + 1, totalPages))}
        disabled={currentPage === totalPages}
        className="btn btn-secondary btn-sm"
        style={{
          height: '38px',
          padding: '0 12px',
          display: 'inline-flex',
          alignItems: 'center',
          gap: '4px',
          opacity: currentPage === totalPages ? 0.4 : 1,
          cursor: currentPage === totalPages ? 'not-allowed' : 'pointer'
        }}
      >
        <span className="hidden sm:inline">Next</span>
        <ChevronRight size={16} />
      </button>
    </nav>
  );
}
