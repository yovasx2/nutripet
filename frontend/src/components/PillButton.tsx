import { Link } from 'react-router-dom';
import { cn } from '../lib/utils';

interface PillButtonProps {
  children: React.ReactNode;
  variant?: 'filled' | 'outlined' | 'text';
  to?: string;
  onClick?: () => void;
  className?: string;
  fullWidth?: boolean;
}

export default function PillButton({ children, variant = 'filled', to, onClick, className, fullWidth = false }: PillButtonProps) {
  const baseStyles = 'inline-flex items-center justify-center rounded-full font-medium text-sm transition-all duration-300 cursor-pointer';

  const variants = {
    filled: 'bg-terracotta text-white hover:bg-terracotta-dark hover:shadow-glow hover:scale-[1.02] active:scale-[0.98]',
    outlined: 'bg-white border border-border-subtle text-espresso hover:shadow-md hover:bg-cream active:scale-[0.98]',
    text: 'text-terracotta hover:underline underline-offset-4 active:opacity-70',
  };

  const sizeStyles = fullWidth ? 'w-full py-3 px-6' : 'py-2.5 px-6';

  const combined = cn(baseStyles, variants[variant], sizeStyles, className);

  if (to) {
    return (
      <Link to={to} className={combined}>
        {children}
      </Link>
    );
  }

  return (
    <button onClick={onClick} className={combined}>
      {children}
    </button>
  );
}
