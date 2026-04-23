interface SectionEyebrowProps {
  text: string;
  className?: string;
  light?: boolean;
}

export default function SectionEyebrow({ text, className = '', light = false }: SectionEyebrowProps) {
  return (
    <span className={`text-xs font-medium tracking-[0.1em] uppercase ${light ? 'text-white/80' : 'text-terracotta'} ${className}`}>
      {text}
    </span>
  );
}
