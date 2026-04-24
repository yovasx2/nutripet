import { useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import PetHeader from '../components/PetHeader';
import { analyzeNutrients, kibbles, nutrients } from '../data/nutrients';
import { useMemo } from 'react';
import { Dog, Utensils, Leaf, FileText, ChevronRight, Plus, TrendingUp, Shield } from 'lucide-react';

export default function DashboardScreen() {
  const navigate = useNavigate();
  const { pets, pet, activePetId, setActivePetId, selectedKibbleId } = usePet();

  const selectedKibble = selectedKibbleId ? kibbles.find(k => k.id === selectedKibbleId) : null;
  const analysis = useMemo(() => {
    if (!selectedKibbleId || !pet) return null;
    return analyzeNutrients(selectedKibbleId, pet.lifeStage as 'adult' | 'puppy');
  }, [selectedKibbleId, pet]);

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12">
      <div className="max-w-[800px] mx-auto px-4">
        {/* Pet switcher — visible when there are multiple pets or at least one */}
        {pets.length > 0 && (
          <div className="flex items-center gap-2 mb-6 overflow-x-auto pb-1 -mx-1 px-1">
            {pets.map(p => (
              <button
                key={p.id}
                onClick={() => setActivePetId(p.id)}
                className={`flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all shrink-0 ${
                  p.id === activePetId
                    ? 'bg-terracotta text-white shadow-sm'
                    : 'bg-white border border-border-subtle text-taupe hover:border-terracotta hover:text-terracotta'
                }`}
              >
                <Dog className="w-3.5 h-3.5" />
                {p.name}
              </button>
            ))}
            <button
              onClick={() => navigate('/add-pet')}
              className="flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap shrink-0 bg-white border border-dashed border-border-subtle text-warm-gray hover:border-terracotta hover:text-terracotta transition-all"
            >
              <Plus className="w-3.5 h-3.5" />
              Agregar
            </button>
          </div>
        )}

        {pet && <PetHeader title={`Perfil de ${pet.name}`} />}

        {!pet && (
          <div className="mb-8">
            <h1 className="font-display text-3xl md:text-4xl text-espresso">Bienvenido a NutriPet</h1>
          </div>
        )}

        {!pet ? (
          <div className="bg-white rounded-2xl border border-border-subtle p-8 text-center">
            <div className="w-16 h-16 rounded-full bg-terracotta/10 flex items-center justify-center mx-auto mb-4">
              <Dog className="w-8 h-8 text-terracotta" />
            </div>
            <h2 className="font-display text-xl text-espresso mb-2">Agrega a tu Primera Mascota</h2>
            <p className="text-sm text-taupe mb-6 max-w-xs mx-auto">
              Crea el perfil de tu perro para recibir un análisis nutricional personalizado.
            </p>
            <button onClick={() => navigate('/add-pet')}
              className="bg-terracotta text-white font-medium px-8 py-3 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all flex items-center gap-2 mx-auto">
              <Plus className="w-4 h-4" /> Agregar Perro
            </button>
          </div>
        ) : (
          <>
            {/* Quick Stats */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              <div className="bg-white rounded-xl border border-border-subtle p-4 text-center">
                <div className="w-8 h-8 rounded-full bg-olive/10 flex items-center justify-center mx-auto mb-2">
                  <TrendingUp className="w-4 h-4 text-olive" />
                </div>
                <div className="text-lg font-semibold text-espresso">{analysis ? Math.round((analysis.adequate.length / nutrients.length) * 100) : 0}%</div>
                <div className="text-xs text-warm-gray">Cobertura</div>
              </div>
              <div className="bg-white rounded-xl border border-border-subtle p-4 text-center">
                <div className="w-8 h-8 rounded-full bg-terracotta/10 flex items-center justify-center mx-auto mb-2">
                  <Leaf className="w-4 h-4 text-terracotta" />
                </div>
                <div className="text-lg font-semibold text-espresso">{analysis ? analysis.deficient.length + analysis.borderline.length : 0}</div>
                <div className="text-xs text-warm-gray">Brechas</div>
              </div>
              <div className="bg-white rounded-xl border border-border-subtle p-4 text-center">
                <div className="w-8 h-8 rounded-full bg-sage/15 flex items-center justify-center mx-auto mb-2">
                  <Shield className="w-4 h-4 text-sage" />
                </div>
                <div className="text-lg font-semibold text-espresso">{analysis ? analysis.adequate.length : 0}</div>
                <div className="text-xs text-warm-gray">Óptimos</div>
              </div>
            </div>

            {/* Current Food — prominent standalone card, Cambiar is the hero */}
            <div className="bg-white rounded-2xl border border-border-subtle p-5 mb-6">
              <h2 className="text-sm font-semibold text-espresso mb-3">Croqueta Actual</h2>
              {selectedKibble ? (
                <>
                  <div className="flex items-center gap-4 mb-4">
                    <div className="w-14 h-14 rounded-xl bg-olive/10 flex items-center justify-center flex-shrink-0">
                      <Utensils className="w-6 h-6 text-olive" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-espresso">{selectedKibble.brand} {selectedKibble.name}</p>
                      <div className="flex gap-2 mt-1">
                        <span className="text-xs px-2 py-0.5 rounded-full bg-olive/10 text-olive">{(selectedKibble.nutrients['Proteína cruda'] || 0).toFixed(1)}% proteína</span>
                        <span className="text-xs px-2 py-0.5 rounded-full bg-sage/10 text-sage">{(selectedKibble.nutrients['Grasa cruda'] || 0).toFixed(1)}% grasa</span>
                      </div>
                    </div>
                  </div>
                  <button onClick={() => navigate('/kibble')}
                    className="w-full bg-terracotta text-white font-medium py-3 rounded-full hover:bg-terracotta-dark transition-all flex items-center justify-center gap-2">
                    <Utensils className="w-4 h-4" /> Cambiar Croqueta
                  </button>
                </>
              ) : (
                <button onClick={() => navigate('/kibble')}
                  className="w-full py-4 border border-dashed border-border-subtle rounded-xl text-sm text-warm-gray hover:border-terracotta hover:text-terracotta transition-colors flex items-center justify-center gap-2">
                  <Plus className="w-4 h-4" /> Seleccionar una croqueta
                </button>
              )}
            </div>

            {/* Quick Actions — no Cambiar Croqueta here, it's the hero above */}
            <div className="bg-white rounded-2xl border border-border-subtle p-5 mb-6">
              <h2 className="text-sm font-semibold text-espresso mb-3">Acciones Rápidas</h2>
              <div className="space-y-2">
                <button onClick={() => navigate('/plan')} className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-cream transition-colors text-left">
                  <div className="w-9 h-9 rounded-lg bg-terracotta/10 flex items-center justify-center"><FileText className="w-4 h-4 text-terracotta" /></div>
                  <div className="flex-1">
                    <div className="text-sm font-medium text-espresso">Ver Análisis Completo</div>
                    <div className="text-xs text-warm-gray">Todos los nutrientes y brechas</div>
                  </div>
                  <ChevronRight className="w-4 h-4 text-warm-gray" />
                </button>
                <button onClick={() => navigate('/supplements')} className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-cream transition-colors text-left">
                  <div className="w-9 h-9 rounded-lg bg-sage/15 flex items-center justify-center"><Leaf className="w-4 h-4 text-olive" /></div>
                  <div className="flex-1">
                    <div className="text-sm font-medium text-espresso">Guía de Suplementos</div>
                    <div className="text-xs text-warm-gray">Opciones naturales y comerciales</div>
                  </div>
                  <ChevronRight className="w-4 h-4 text-warm-gray" />
                </button>
              </div>
            </div>

            {/* Nutrient Alert */}
            {analysis && (analysis.deficient.length > 0 || analysis.borderline.length > 0) && (
              <div className="bg-terracotta/5 rounded-2xl border border-terracotta/20 p-5 mb-6">
                <h3 className="text-sm font-semibold text-terracotta mb-2">Alerta Nutricional</h3>
                <p className="text-sm text-taupe mb-3">
                  {analysis.deficient.length > 0
                    ? `Encontramos ${analysis.deficient.length} nutriente${analysis.deficient.length > 1 ? 's' : ''} debajo del nivel óptimo en la comida de ${pet.name}.`
                    : `${analysis.borderline.length} nutriente${analysis.borderline.length > 1 ? 's están' : ' está'} al límite. Considera suplementos naturales o un cambio de croqueta.`}
                </p>
                <div className="flex flex-wrap gap-2 mb-3">
                  {analysis.deficient.slice(0, 4).map(n => (
                    <span key={n.name} className="text-xs px-2 py-1 rounded-full bg-terracotta/10 text-terracotta font-medium">{n.name}</span>
                  ))}
                  {analysis.borderline.slice(0, 3).map(n => (
                    <span key={n.name} className="text-xs px-2 py-1 rounded-full bg-sage/20 text-sage font-medium">{n.name}</span>
                  ))}
                </div>
                <button onClick={() => navigate('/supplements')} className="text-xs text-terracotta font-medium hover:underline flex items-center gap-1">
                  Ver recomendaciones <ChevronRight className="w-3 h-3" />
                </button>
              </div>
            )}

            {/* Disclaimer */}
            <div className="p-4 bg-cream rounded-xl border border-border-subtle mb-6">
              <p className="text-xs text-warm-gray leading-relaxed">
                <strong className="text-taupe">Nota:</strong> NutriPet es una herramienta informativa. No está revisada por veterinarios y no sustituye el diagnóstico profesional. Consulta a tu médico veterinario antes de cambiar la dieta o iniciar suplementos.
              </p>
            </div>

          </>
        )}
      </div>
    </div>
  );
}
