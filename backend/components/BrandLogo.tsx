'use client';

import { useState } from 'react';

type Props = {
  src: string;
  alt: string;
  className?: string;
};

export default function BrandLogo({ src, alt, className }: Props) {
  const [hide, setHide] = useState(false);

  if (hide) return null;

  return (
    <img
      src={src}
      alt={alt}
      className={className}
      onError={() => setHide(true)}
    />
  );
}