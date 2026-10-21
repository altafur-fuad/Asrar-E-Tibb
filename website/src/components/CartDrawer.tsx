'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { X, Trash2, Plus, Minus, ShoppingBag, ArrowRight, CheckCircle2 } from 'lucide-react';
import { useCart } from '../context/CartContext';
import { MedicineImageBadge } from './MedicineImageBadge';

export function CartDrawer() {
  const { items, isCartOpen, setIsCartOpen, removeFromCart, updateQuantity, totalPrice, clearCart } = useCart();
  const [checkoutComplete, setCheckoutComplete] = useState(false);
  const [deliveryAddress, setDeliveryAddress] = useState('Home: Muradpur, Chittagong');

  if (!isCartOpen) return null;

  const handleCheckout = () => {
    setCheckoutComplete(true);
    setTimeout(() => {
      clearCart();
    }, 3000);
  };

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      zIndex: 100,
      display: 'flex',
      justifyContent: 'flex-end',
      background: 'rgba(18, 35, 29, 0.5)',
      backdropFilter: 'blur(4px)'
    }}>
      <div
        style={{
          width: '100%',
          maxWidth: '460px',
          background: 'var(--color-white)',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          boxShadow: '-4px 0 24px rgba(0,0,0,0.15)',
          animation: 'slideIn 250ms ease-out'
        }}
      >
        {/* Header */}
        <div style={{
          padding: '20px 24px',
          borderBottom: '1px solid var(--color-border)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <ShoppingBag size={22} color="var(--color-forest-green)" />
            <h3 style={{ fontSize: '1.25rem' }}>Farmacia Cart</h3>
            <span className="pill pill-green" style={{ fontSize: '0.75rem' }}>
              {items.length} {items.length === 1 ? 'item' : 'items'}
            </span>
          </div>
          <button
            onClick={() => {
              setIsCartOpen(false);
              setCheckoutComplete(false);
            }}
            style={{ padding: '6px', color: 'var(--color-muted)' }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '24px' }}>
          {checkoutComplete ? (
            <div style={{ textAlign: 'center', padding: '48px 12px' }}>
              <CheckCircle2 size={56} color="var(--color-success)" style={{ margin: '0 auto 16px' }} />
              <h3 style={{ fontSize: '1.35rem', marginBottom: '8px' }}>Order Submitted for Review</h3>
              <p style={{ color: 'var(--color-muted)', fontSize: '0.92rem', marginBottom: '20px' }}>
                Your medication order has been registered in the demonstration storefront for delivery to <strong>{deliveryAddress}</strong>.
              </p>
              <div style={{
                background: 'var(--color-soft-sage)',
                padding: '16px',
                borderRadius: 'var(--radius-md)',
                fontSize: '0.85rem',
                color: 'var(--color-forest-green)',
                textAlign: 'left'
              }}>
                <strong>Honest Architecture Note:</strong> Asrar-e-Tibb does not accept unverified electronic medicine payments without physician prescription verification. Pharmacy dispatch occurs via licensed partners.
              </div>
            </div>
          ) : items.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--color-muted)' }}>
              <ShoppingBag size={48} strokeWidth={1.2} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
              <h4 style={{ fontSize: '1.1rem', marginBottom: '8px' }}>Your cart is empty</h4>
              <p style={{ fontSize: '0.9rem', marginBottom: '24px' }}>
                Explore authentic medicines and herbal formulations in our directory.
              </p>
              <Link
                href="/medicines"
                onClick={() => setIsCartOpen(false)}
                className="btn btn-primary btn-sm"
              >
                Browse Medicines
              </Link>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {items.map((item) => (
                <div
                  key={item.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '14px',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--color-border)',
                    background: 'var(--color-warm-ivory)'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <MedicineImageBadge dosageForm={item.dosage_form} size="sm" />
                    <div>
                      <h4 style={{ fontSize: '0.98rem', marginBottom: '2px' }}>{item.name}</h4>
                      <p style={{ fontSize: '0.8rem', color: 'var(--color-muted)' }}>
                        {item.dosage_form} • {item.price}
                      </p>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{
                      display: 'flex',
                      alignItems: 'center',
                      background: 'var(--color-white)',
                      border: '1px solid var(--color-border)',
                      borderRadius: 'var(--radius-sm)'
                    }}>
                      <button
                        onClick={() => updateQuantity(item.id, -1)}
                        style={{ padding: '4px 8px' }}
                      >
                        <Minus size={14} />
                      </button>
                      <span style={{ fontSize: '0.85rem', fontWeight: 600, minWidth: '24px', textAlign: 'center' }}>
                        {item.quantity}
                      </span>
                      <button
                        onClick={() => updateQuantity(item.id, 1)}
                        style={{ padding: '4px 8px' }}
                      >
                        <Plus size={14} />
                      </button>
                    </div>

                    <button
                      onClick={() => removeFromCart(item.id)}
                      style={{ padding: '6px', color: 'var(--color-error)' }}
                      title="Remove"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Footer */}
        {items.length > 0 && !checkoutComplete && (
          <div style={{
            padding: '20px 24px',
            borderTop: '1px solid var(--color-border)',
            background: 'var(--color-white)'
          }}>
            <div style={{ marginBottom: '16px' }}>
              <label style={{ fontSize: '0.8rem', color: 'var(--color-muted)', fontWeight: 600, display: 'block', marginBottom: '6px' }}>
                Delivery Destination
              </label>
              <input
                type="text"
                value={deliveryAddress}
                onChange={(e) => setDeliveryAddress(e.target.value)}
                className="input-field"
                style={{ padding: '8px 12px', fontSize: '0.88rem' }}
              />
            </div>

            <div style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginBottom: '18px'
            }}>
              <span style={{ fontSize: '0.95rem', color: 'var(--color-muted)', fontWeight: 500 }}>
                Estimated Subtotal:
              </span>
              <span style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--color-forest-green)' }}>
                ৳ {totalPrice.toFixed(2)}
              </span>
            </div>

            <button
              onClick={handleCheckout}
              className="btn btn-primary"
              style={{ width: '100%' }}
            >
              <span>Confirm Order Request</span>
              <ArrowRight size={18} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

