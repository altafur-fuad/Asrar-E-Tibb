import type { Metadata } from 'next';
import './globals.css';
import { Navbar } from '../components/Navbar';
import { Footer } from '../components/Footer';
import { CartDrawer } from '../components/CartDrawer';
import { CartProvider } from '../context/CartContext';

export const metadata: Metadata = {
  title: 'Asrar-e-Tibb | Modern Healthcare, Verified Medicine Directory & Pharmacy',
  description: 'Explore over 21,000 verified medicines, generic indications, dosages, pharmaceutical storefront, and Android mobile healthcare app from Asrar-e-Tibb.',
  keywords: ['Asrar-e-Tibb', 'Medicine Directory', 'Pharmacy Bangladesh', 'Healthcare', 'Generic Medicine', 'Farmacia', 'TibbNews'],
  authors: [{ name: 'Asrar-e-Tibb Medical Engineering Team' }],
  icons: {
    icon: '/favicon.ico',
  },
};

export const viewport = {
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <CartProvider>
          <Navbar />
          <CartDrawer />
          <main className="site-main">
            {children}
          </main>
          <Footer />
        </CartProvider>
      </body>
    </html>
  );
}
