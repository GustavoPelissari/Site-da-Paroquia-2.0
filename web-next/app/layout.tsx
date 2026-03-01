import './globals.css';
import { Inter, Playfair_Display } from 'next/font/google';

const inter = Inter({ subsets: ['latin'], variable: '--font-inter' });
const playfair = Playfair_Display({
  subsets: ['latin'],
  variable: '--font-playfair',
  weight: ['700']
});

export const metadata = {
  title: 'Paróquia São Paulo Apóstolo',
  description: 'PDGP - Plataforma Digital de Gestão Paroquial'
};

export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR" className={`${inter.variable} ${playfair.variable}`}>
      <body className="min-h-screen bg-white text-zinc-900">{children}</body>
    </html>
  );
}