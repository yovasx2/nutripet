import { cn } from '../lib/utils';

interface NutrientListItemProps {
  dotColor: string;
  name: string;
  badgeText: string;
  badgeBg: string;
  badgeTextColor: string;
}

export default function NutrientListItem({ dotColor, name, badgeText, badgeBg, badgeTextColor }: NutrientListItemProps) {
  return (
    <div className="flex items-center gap-3">
      <div className={cn('w-2 h-2 rounded-full flex-shrink-0', dotColor)} />
      <span className="text-sm text-espresso flex-1">{name}</span>
      <span className={cn('text-xs font-medium px-3 py-1 rounded-full', badgeBg, badgeTextColor)}>
        {badgeText}
      </span>
    </div>
  );
}
