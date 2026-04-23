import { cn } from '../lib/utils';

interface StepCardProps {
  step: number;
  icon: React.ReactNode;
  iconBg: string;
  title: string;
  body: string;
}

export default function StepCard({ step, icon, iconBg, title, body }: StepCardProps) {
  return (
    <div className="bg-cream rounded-2xl p-8 shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300 group h-full flex flex-col">
      <div className={cn('w-12 h-12 rounded-full flex items-center justify-center', iconBg)}>
        {icon}
      </div>
      <div className="flex items-center gap-2 mt-6">
        <span className="text-xs font-medium text-warm-gray">Step {step}</span>
        <div className="h-px flex-1 bg-border-subtle" />
      </div>
      <h3 className="text-lg font-semibold text-espresso mt-3">{title}</h3>
      <p className="text-sm text-taupe mt-2 leading-relaxed flex-1">{body}</p>
    </div>
  );
}
