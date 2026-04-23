import { useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import { Mars, Venus, Settings } from 'lucide-react';

interface PetHeaderProps {
  title?: string;
  subtitle?: string;
}

const eccLabel = (score: number): { text: string; color: string } => {
  const labels: Record<number, { text: string; color: string }> = {
    1: { text: 'Muy delgado', color: 'text-terracotta' },
    2: { text: 'Delgado', color: 'text-terracotta' },
    3: { text: 'Ligeramente delgado', color: 'text-terracotta' },
    4: { text: 'Ideal', color: 'text-olive' },
    5: { text: 'Ideal', color: 'text-olive' },
    6: { text: 'Sobrepeso leve', color: 'text-sage' },
    7: { text: 'Sobrepeso', color: 'text-sage' },
    8: { text: 'Obeso', color: 'text-terracotta' },
    9: { text: 'Muy obeso', color: 'text-terracotta' },
  };
  return labels[score] || { text: 'No registrado', color: 'text-warm-gray' };
};

export default function PetHeader({ title, subtitle }: PetHeaderProps) {
  const navigate = useNavigate();
  const { pet } = usePet();

  if (!pet) return null;

  const ecc = eccLabel(pet.eccScore);

  return (
    <div className="mb-6">
      <div className="flex items-center justify-between">
        <h1 className="font-display text-2xl md:text-3xl text-espresso">
          {title || pet.name}
        </h1>
        <button
          onClick={() => navigate('/add-pet')}
          className="p-2.5 rounded-full text-warm-gray hover:text-terracotta hover:bg-terracotta/5 transition-all"
          aria-label={`Editar perfil de ${pet.name}`}
          title="Editar perfil"
        >
          <Settings className="w-5 h-5" />
        </button>
      </div>
      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1.5 text-sm text-taupe">
        <span className="flex items-center gap-1">
          {pet.sex === 'male' ? <Mars className="w-3.5 h-3.5 text-terracotta" /> : <Venus className="w-3.5 h-3.5 text-terracotta" />}
          {pet.breed}
        </span>
        <span>·</span>
        <span>
          {pet.ageYears ? `${pet.ageYears} ${pet.ageYears === 1 ? 'año' : 'años'}` : ''}
          {pet.ageYears && pet.ageMonths ? ' ' : ''}
          {pet.ageMonths ? `${pet.ageMonths} ${pet.ageMonths === 1 ? 'mes' : 'meses'}` : ''}
        </span>
        <span>·</span>
        <span>{pet.weight} kg</span>
        <span>·</span>
        <span className="capitalize">{pet.lifeStage === 'puppy' ? 'Cachorro' : pet.lifeStage === 'senior' ? 'Senior' : 'Adulto'}</span>
        <span>·</span>
        <span className={`font-medium ${ecc.color}`}>{ecc.text}</span>
        {pet.reproductiveStatus !== 'none' && (
          <>
            <span>·</span>
            <span className="text-terracotta font-medium">{pet.reproductiveStatus === 'gestating' ? 'Gestando' : 'Lactando'}</span>
          </>
        )}
        {subtitle && (
          <>
            <span>·</span>
            <span>{subtitle}</span>
          </>
        )}
      </div>
    </div>
  );
}
