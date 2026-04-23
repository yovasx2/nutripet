import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import { ChevronRight, Dog, Calendar, Home, Footprints, Zap, HelpCircle, X, Mars, Venus } from 'lucide-react';

const breedList = [
  'Beagle', 'Bichón Frisé', 'Boxer', 'Bulldog Francés', 'Bulldog Inglés',
  'Chihuahua', 'Cocker Spaniel', 'Corgi', 'Dachshund (Salchicha)', 'Doberman',
  'Golden Retriever', 'Gran Danés', 'Husky Siberiano', 'Labrador Retriever',
  'Pastor Alemán', 'Pastor Australiano', 'Pastor Belga Malinois', 'Pitbull Terrier',
  'Poodle', 'Pug', 'Rottweiler', 'Schnauzer', 'Shih Tzu', 'Yorkshire Terrier',
];

const breeds = [...breedList].sort((a, b) => a.localeCompare(b, 'es'));
breeds.push('Mestizo (Sin raza definida)', 'Otra');

export default function AddPetScreen() {
  const navigate = useNavigate();
  const { pet, setPet } = usePet();
  const [step, setStep] = useState(1);
  const [name, setName] = useState('');
  const [breed, setBreed] = useState('');
  const [sex, setSex] = useState<'male' | 'female'>('male');
  const [ageYears, setAgeYears] = useState('');
  const [ageMonths, setAgeMonths] = useState('');
  const [weight, setWeight] = useState('');
  const [activityLevel, setActivityLevel] = useState<'low' | 'moderate' | 'high'>('moderate');
  const [eccScore, setEccScore] = useState(5);
  const [reproductiveStatus, setReproductiveStatus] = useState<'none' | 'gestating' | 'lactating'>('none');
  const [showEccModal, setShowEccModal] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Pre-fill from existing pet data when editing
  useEffect(() => {
    if (pet) {
      setName(pet.name || '');
      setBreed(pet.breed || '');
      setSex(pet.sex || 'male');
      setAgeYears(pet.ageYears?.toString() || '');
      setAgeMonths(pet.ageMonths?.toString() || '');
      setWeight(pet.weight?.toString() || '');
      setActivityLevel(pet.activityLevel || 'moderate');
      setEccScore(pet.eccScore || 5);
      setReproductiveStatus(pet.reproductiveStatus || 'none');
    }
  }, [pet]);

  // Preload ECC image
  useEffect(() => {
    const img = new Image();
    img.src = '/ecc-perros.png';
  }, []);

  // Force scroll to top on mount and when step changes (prevents mobile auto-focus scroll)
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
  }, [step]);

  const totalMonths = Number(ageYears || 0) * 12 + Number(ageMonths || 0);
  const lifeStage = totalMonths < 12 ? 'puppy' : totalMonths > 84 ? 'senior' : 'adult';

  const validateStep = () => {
    const newErrors: Record<string, string> = {};
    if (step === 1) {
      if (!name.trim()) newErrors.name = 'Escribe el nombre de tu perro';
      if (!breed) newErrors.breed = 'Selecciona una raza';
    }
    if (step === 2) {
      if (!ageYears && !ageMonths) newErrors.age = 'Escribe al menos años o meses';
      if (!weight || Number(weight) <= 0) newErrors.weight = 'Escribe un peso válido';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (!validateStep()) return;
    if (step < 3) setStep(step + 1);
    else {
      setPet({
        name: name.trim(),
        breed,
        sex,
        ageYears: Number(ageYears || 0),
        ageMonths: Number(ageMonths || 0),
        weight: Number(weight),
        activityLevel,
        lifeStage: lifeStage as 'puppy' | 'adult' | 'senior',
        eccScore,
        reproductiveStatus,
      });
      navigate('/kibble');
    }
  };

  const eccLabels: Record<number, string> = {
    1: 'Muy delgado', 2: 'Delgado', 3: 'Ligeramente delgado',
    4: 'Ideal', 5: 'Ideal', 6: 'Sobrepeso leve',
    7: 'Sobrepeso', 8: 'Obeso', 9: 'Muy obeso',
  };

  const toggleReproductive = (value: 'gestating' | 'lactating') => {
    setReproductiveStatus(prev => prev === value ? 'none' : value);
  };

  const activityOptions = [
    { value: 'low' as const, label: 'Baja', desc: 'Mayormente en casa, paseos cortos', icon: <Home className="w-5 h-5" /> },
    { value: 'moderate' as const, label: 'Moderada', desc: 'Paseos diarios, algo de juego', icon: <Footprints className="w-5 h-5" /> },
    { value: 'high' as const, label: 'Alta', desc: 'Corre, caminatas, juego activo', icon: <Zap className="w-5 h-5" /> },
  ];

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12 px-4">
      <div className="max-w-[500px] mx-auto">
        {/* Progress bar */}
        <div className="flex items-center gap-3 mb-8">
          {[1, 2, 3].map((s) => (
            <div key={s} className="flex-1 h-1.5 rounded-full overflow-hidden bg-border-subtle">
              <div className={`h-full rounded-full transition-all duration-500 ${s <= step ? 'bg-terracotta' : 'bg-transparent'}`} style={{ width: s <= step ? '100%' : '0%' }} />
            </div>
          ))}
        </div>

        {/* Step 1: Name, Breed, Sex */}
        {step === 1 && (
          <div className="animate-fadeIn">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-full bg-terracotta/10 flex items-center justify-center">
                <Dog className="w-5 h-5 text-terracotta" />
              </div>
              <div>
                <h1 className="font-display text-2xl text-espresso">{pet ? `Editar perfil de ${pet.name}` : '¿Cómo se llama tu perro?'}</h1>
                <p className="text-sm text-taupe">{pet ? 'Actualiza los datos de tu mascota' : 'Empecemos con lo básico'}</p>
              </div>
            </div>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-espresso mb-2">Nombre</label>
                <input type="text" value={name} onChange={(e) => { setName(e.target.value); setErrors(p => ({ ...p, name: '' })); }} placeholder="Ej. Rocky"
                  className={`w-full px-4 py-3 rounded-xl border ${errors.name ? 'border-terracotta' : 'border-border-subtle'} bg-white text-espresso placeholder:text-warm-gray focus:outline-none focus:border-terracotta transition-colors`} />
                {errors.name && <p className="text-xs text-terracotta mt-1">{errors.name}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-espresso mb-2">Raza</label>
                <select value={breed} onChange={(e) => { setBreed(e.target.value); setErrors(p => ({ ...p, breed: '' })); }}
                  className={`w-full px-4 py-3 rounded-xl border ${errors.breed ? 'border-terracotta' : 'border-border-subtle'} bg-white text-espresso focus:outline-none focus:border-terracotta transition-colors appearance-none`}>
                  <option value="">Selecciona raza</option>
                  {breeds.map(b => <option key={b} value={b}>{b}</option>)}
                </select>
                {errors.breed && <p className="text-xs text-terracotta mt-1">{errors.breed}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-espresso mb-2">Sexo</label>
                <div className="flex gap-3">
                  <button onClick={() => setSex('male')}
                    className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl border transition-all ${sex === 'male' ? 'border-terracotta bg-terracotta/5 text-terracotta' : 'border-border-subtle bg-white text-taupe hover:border-sage'}`}>
                    <Mars className="w-5 h-5" />
                    <span className="text-sm font-medium">Macho</span>
                  </button>
                  <button onClick={() => setSex('female')}
                    className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl border transition-all ${sex === 'female' ? 'border-terracotta bg-terracotta/5 text-terracotta' : 'border-border-subtle bg-white text-taupe hover:border-sage'}`}>
                    <Venus className="w-5 h-5" />
                    <span className="text-sm font-medium">Hembra</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Step 2: Age, Weight, ECC, Reproductive */}
        {step === 2 && (
          <div className="animate-fadeIn">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-full bg-sage/20 flex items-center justify-center">
                <Calendar className="w-5 h-5 text-olive" />
              </div>
              <div>
                <h1 className="font-display text-2xl text-espresso">Edad, peso y condición</h1>
                <p className="text-sm text-taupe">Datos para calcular sus necesidades nutricionales</p>
              </div>
            </div>
            <div className="space-y-5">
              <div>
                <label className="block text-sm font-medium text-espresso mb-2">Edad</label>
                <div className="flex gap-3">
                  <div className="flex-1">
                    <input type="number" value={ageYears} onChange={(e) => { setAgeYears(e.target.value); setErrors(p => ({ ...p, age: '' })); }} placeholder="Años" min="0"
                      className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white text-espresso placeholder:text-warm-gray focus:outline-none focus:border-terracotta transition-colors" />
                  </div>
                  <div className="flex-1">
                    <input type="number" value={ageMonths} onChange={(e) => { const v = Math.min(11, Math.max(0, Number(e.target.value))); setAgeMonths(isNaN(v) ? '' : v.toString()); setErrors(p => ({ ...p, age: '' })); }} placeholder="Meses" min="0" max="11"
                      className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white text-espresso placeholder:text-warm-gray focus:outline-none focus:border-terracotta transition-colors" />
                  </div>
                </div>
                {errors.age && <p className="text-xs text-terracotta mt-1">{errors.age}</p>}
                {(ageYears || ageMonths) && (
                  <p className="text-xs text-sage mt-1 font-medium">
                    Etapa: <span className="capitalize">{lifeStage === 'puppy' ? 'Cachorro' : lifeStage === 'senior' ? 'Senior' : 'Adulto'}</span>
                    {totalMonths > 0 && ` · ${totalMonths} meses`}
                  </p>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-espresso mb-2">Peso (kg)</label>
                <input type="number" value={weight} onChange={(e) => { setWeight(e.target.value); setErrors(p => ({ ...p, weight: '' })); }} placeholder="Ej. 20" min="0.1" step="0.1"
                  className={`w-full px-4 py-3 rounded-xl border ${errors.weight ? 'border-terracotta' : 'border-border-subtle'} bg-white text-espresso placeholder:text-warm-gray focus:outline-none focus:border-terracotta transition-colors`} />
                {errors.weight && <p className="text-xs text-terracotta mt-1">{errors.weight}</p>}
              </div>
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="text-sm font-medium text-espresso">Condición Corporal</label>
                  <button onClick={() => setShowEccModal(true)} className="text-xs text-olive hover:underline flex items-center gap-1">
                    <HelpCircle className="w-3 h-3" /> Ver guía visual
                  </button>
                </div>
                <div className="bg-white rounded-xl border border-border-subtle p-4">
                  <p className="text-xs text-warm-gray mb-3">Mantén a tu perro en un rango de <strong className="text-olive">4 a 5</strong> para una salud óptima.</p>
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs text-warm-gray">1 — Muy delgado</span>
                    <span className="text-xs text-warm-gray">Muy obeso — 9</span>
                  </div>
                  <input type="range" min="1" max="9" step="1" value={eccScore} onChange={(e) => setEccScore(Number(e.target.value))} className="w-full accent-terracotta" />
                  <div className="flex justify-between mt-2">
                    {Array.from({ length: 9 }, (_, i) => i + 1).map((n) => (
                      <button key={n} onClick={() => setEccScore(n)}
                        className={`w-7 h-7 rounded-full text-xs font-medium transition-all ${eccScore === n ? (n <= 3 ? 'bg-terracotta text-white' : n <= 5 ? 'bg-olive text-white' : n === 6 ? 'bg-sage text-white' : 'bg-terracotta text-white') : 'bg-border-subtle text-warm-gray hover:bg-sage/30'}`}>
                        {n}
                      </button>
                    ))}
                  </div>
                  <div className="mt-3 text-center">
                    <span className={`text-sm font-semibold ${
                      eccScore <= 3 ? 'text-terracotta' : eccScore <= 5 ? 'text-olive' : eccScore === 6 ? 'text-sage' : 'text-terracotta'
                    }`}>
                      {eccLabels[eccScore]}
                    </span>
                  </div>
                </div>
              </div>
              {sex === 'female' && (
                <div className="bg-white rounded-xl border border-border-subtle p-4">
                  <label className="block text-sm font-medium text-espresso mb-2">Estado reproductivo</label>
                  <div className="flex flex-wrap gap-2">
                    {[
                      { value: 'gestating' as const, label: 'Gestando' },
                      { value: 'lactating' as const, label: 'Lactando' },
                    ].map((opt) => (
                      <button key={opt.value} onClick={() => toggleReproductive(opt.value)}
                        className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                          reproductiveStatus === opt.value
                            ? 'bg-terracotta text-white'
                            : 'bg-cream border border-border-subtle text-taupe hover:border-sage'
                        }`}>
                        {opt.label}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Step 3: Activity Level */}
        {step === 3 && (
          <div className="animate-fadeIn">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-full bg-olive/15 flex items-center justify-center">
                <Footprints className="w-5 h-5 text-olive" />
              </div>
              <div>
                <h1 className="font-display text-2xl text-espresso">Nivel de actividad</h1>
                <p className="text-sm text-taupe">¿Qué tan activo es tu perro diariamente?</p>
              </div>
            </div>
            <div className="space-y-3">
              {activityOptions.map((opt) => (
                <button key={opt.value} onClick={() => setActivityLevel(opt.value)}
                  className={`w-full flex items-center gap-4 p-4 rounded-xl border transition-all duration-200 ${
                    activityLevel === opt.value ? 'border-terracotta bg-terracotta/5 shadow-sm' : 'border-border-subtle bg-white hover:border-sage'
                  }`}>
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${activityLevel === opt.value ? 'bg-terracotta/15 text-terracotta' : 'bg-cream text-taupe'}`}>
                    {opt.icon}
                  </div>
                  <div className="text-left flex-1">
                    <div className="text-sm font-medium text-espresso">{opt.label}</div>
                    <div className="text-xs text-warm-gray">{opt.desc}</div>
                  </div>
                  {activityLevel === opt.value && <div className="w-5 h-5 rounded-full bg-terracotta flex items-center justify-center"><ChevronRight className="w-3 h-3 text-white" /></div>}
                </button>
              ))}
            </div>
            <div className="mt-6 bg-white rounded-xl border border-border-subtle p-4">
              <h3 className="text-sm font-semibold text-espresso mb-3">Resumen del perfil</h3>
              <div className="grid grid-cols-2 gap-2 text-sm">
                <div><span className="text-warm-gray">Nombre:</span> <span className="text-espresso font-medium">{name || '—'}</span></div>
                <div><span className="text-warm-gray">Raza:</span> <span className="text-espresso font-medium">{breed || '—'}</span></div>
                <div><span className="text-warm-gray">Sexo:</span> <span className="text-espresso font-medium">{sex === 'male' ? 'Macho' : 'Hembra'}</span></div>
                <div><span className="text-warm-gray">Edad:</span> <span className="text-espresso font-medium">{ageYears ? `${ageYears} ${Number(ageYears) === 1 ? 'año' : 'años'}` : ''}{ageYears && ageMonths ? ' ' : ''}{ageMonths ? `${ageMonths} ${Number(ageMonths) === 1 ? 'mes' : 'meses'}` : totalMonths > 0 ? '' : '—'}</span></div>
                <div><span className="text-warm-gray">Peso:</span> <span className="text-espresso font-medium">{weight ? `${weight} kg` : '—'}</span></div>
                <div><span className="text-warm-gray">Condición:</span> <span className={`font-medium ${
                  eccScore <= 3 ? 'text-terracotta' : eccScore <= 5 ? 'text-olive' : eccScore === 6 ? 'text-sage' : 'text-terracotta'
                }`}>{eccLabels[eccScore]}</span></div>
                <div><span className="text-warm-gray">Etapa:</span> <span className="text-espresso font-medium capitalize">{lifeStage === 'puppy' ? 'Cachorro' : lifeStage === 'senior' ? 'Senior' : 'Adulto'}</span></div>
              </div>
            </div>
          </div>
        )}
        <div className="flex gap-3 mt-8">
          {step > 1 && (
            <button onClick={() => setStep(step - 1)} className="flex-1 py-3 rounded-full border border-border-subtle text-espresso font-medium text-sm hover:bg-white transition-all duration-200">
              Atrás
            </button>
          )}
          <button onClick={handleNext} className="flex-1 py-3 rounded-full bg-terracotta text-white font-medium text-sm hover:bg-terracotta-dark hover:shadow-glow transition-all duration-200 flex items-center justify-center gap-2">
            {step === 3 ? (pet ? 'Guardar cambios' : 'Continuar') : 'Siguiente'}
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
      {showEccModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm" onClick={() => setShowEccModal(false)}>
          <div className="bg-white rounded-2xl max-w-[600px] w-full max-h-[90vh] overflow-y-auto p-6 relative" onClick={e => e.stopPropagation()}>
            <button onClick={() => setShowEccModal(false)} className="absolute top-4 right-4 w-8 h-8 rounded-full bg-cream flex items-center justify-center hover:bg-border-subtle transition-colors">
              <X className="w-4 h-4 text-espresso" />
            </button>
            <h2 className="font-display text-2xl text-espresso mb-2">Escala de Condición Corporal</h2>
            <p className="text-sm text-taupe mb-4">Mantén a tu perro en un rango de <strong className="text-olive">4 a 5</strong> para una salud óptima.</p>
            <img src="/ecc-perros.png" alt="Escala de Condición Corporal para Perros 1-9" className="w-full rounded-xl mb-6" />
            <div className="grid grid-cols-3 gap-3 mb-6">
              <div className="bg-cream rounded-xl p-3 border border-border-subtle">
                <h3 className="text-xs font-semibold text-espresso mb-1">Vista desde arriba</h3>
                <p className="text-xs text-taupe">Debe verse una cintura detrás de las costillas.</p>
              </div>
              <div className="bg-cream rounded-xl p-3 border border-border-subtle">
                <h3 className="text-xs font-semibold text-espresso mb-1">Vista de lado</h3>
                <p className="text-xs text-taupe">El abdomen debe estar recogido, no colgante.</p>
              </div>
              <div className="bg-cream rounded-xl p-3 border border-border-subtle">
                <h3 className="text-xs font-semibold text-espresso mb-1">Palpación</h3>
                <p className="text-xs text-taupe">Costillas palpables pero no visibles.</p>
              </div>
            </div>
            <div className="space-y-2 text-sm">
              <div className="flex gap-3"><span className="font-medium text-terracotta w-20 flex-shrink-0">ECC 1-3:</span><span className="text-taupe">Consulta a tu veterinario. Tu perro necesita aumentar peso.</span></div>
              <div className="flex gap-3"><span className="font-medium text-olive w-20 flex-shrink-0">ECC 4-5:</span><span className="text-taupe">¡Peso ideal! Mantén la dieta actual y ejercicio regular.</span></div>
              <div className="flex gap-3"><span className="font-medium text-sage w-20 flex-shrink-0">ECC 6:</span><span className="text-taupe">Sobrepeso leve. Reduce porciones un 10% y aumenta paseos.</span></div>
              <div className="flex gap-3"><span className="font-medium text-terracotta w-20 flex-shrink-0">ECC 7-9:</span><span className="text-taupe">Consulta a tu veterinario. Plan de pérdida de peso necesario.</span></div>
            </div>
            <button onClick={() => setShowEccModal(false)} className="w-full mt-6 py-3 rounded-full bg-terracotta text-white font-medium text-sm hover:bg-terracotta-dark transition-all">
              Entendido
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
