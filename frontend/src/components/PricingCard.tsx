import { Check } from 'lucide-react';
import PillButton from './PillButton';
import { cn } from '../lib/utils';

interface PricingCardProps {
  badge: string;
  price: string;
  period: string;
  features: string[];
  cta: string;
  ctaVariant?: 'filled' | 'outlined';
  popular?: boolean;
  to?: string;
}

export default function PricingCard({ badge, price, period, features, cta, ctaVariant = 'outlined', popular = false, to = '/add-pet' }: PricingCardProps) {
  return (
    <div className={cn(
      'relative bg-white rounded-2xl p-8 transition-all duration-300 hover:-translate-y-1',
      popular ? 'shadow-lg border-2 border-terracotta' : 'shadow-sm border border-border-subtle'
    )}>
      {popular && (
        <div className="absolute -top-3 right-6 bg-terracotta text-white text-xs font-medium px-4 py-1 rounded-full">
          Most Popular
        </div>
      )}

      <span className="text-xs font-medium tracking-[0.1em] uppercase text-warm-gray">
        {badge}
      </span>

      <div className="mt-2 flex items-baseline gap-1">
        <span className="font-display text-4xl text-espresso">{price}</span>
        <span className="text-sm text-warm-gray">{period}</span>
      </div>

      <div className="h-px bg-border-subtle my-6" />

      <ul className="space-y-3">
        {features.map((feature, i) => (
          <li key={i} className="flex items-center gap-3">
            <div className="w-5 h-5 rounded-full bg-olive/10 flex items-center justify-center flex-shrink-0">
              <Check className="w-3 h-3 text-olive" />
            </div>
            <span className="text-sm text-taupe">{feature}</span>
          </li>
        ))}
      </ul>

      <div className="mt-8">
        <PillButton variant={ctaVariant} to={to} fullWidth>
          {cta}
        </PillButton>
      </div>
    </div>
  );
}
