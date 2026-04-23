import { useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import PetHeader from '../components/PetHeader';
import { analyzeNutrients } from '../data/nutrients';
import { HelpCircle, Check, AlertCircle, Leaf, Droplets, Bone, Brain, Shield, Store, Heart, ExternalLink } from 'lucide-react';

const categoryIcons: Record<string, React.ReactNode> = {
  'skin-coat': <Leaf className="w-5 h-5" />,
  'joints': <Bone className="w-5 h-5" />,
  'digestion': <Droplets className="w-5 h-5" />,
  'immunity': <Shield className="w-5 h-5" />,
  'cognitive': <Brain className="w-5 h-5" />,
};

// General wellness tips always shown
const wellnessTips = [
  { icon: <Heart className="w-4 h-4 text-terracotta" />, text: 'Los suplementos complementan, no reemplazan, una dieta balanceada.' },
  { icon: <Droplets className="w-4 h-4 text-olive" />, text: 'Asegúrate de que tu perro siempre tenga agua fresca disponible.' },
  { icon: <Leaf className="w-4 h-4 text-sage" />, text: 'Introduce un suplemento a la vez y observa la respuesta durante 2 semanas.' },
  { icon: <Shield className="w-4 h-4 text-olive" />, text: 'La mejor fuente de omega-3 es el aceite de pescado de aguas frías.' },
  { icon: <Bone className="w-4 h-4 text-sage" />, text: 'Para articulaciones, la glucosamina de origen marino tiene mejor absorción.' },
  { icon: <Brain className="w-4 h-4 text-terracotta" />, text: 'Los prebióticos alimentan las bacterias buenas; los probióticos las reintroducen.' },
];

export default function SupplementsScreen() {
  const navigate = useNavigate();
  const { pet, selectedKibbleId } = usePet();

  const analysis = useMemo(() => {
    if (!selectedKibbleId) return null;
    return analyzeNutrients(selectedKibbleId, (pet?.lifeStage as 'adult' | 'puppy') || 'adult');
  }, [selectedKibbleId, pet]);

  if (!selectedKibbleId || !analysis) {
    return (
      <div className="min-h-[100dvh] bg-cream pt-20 pb-12 px-4 flex items-center justify-center">
        <div className="text-center max-w-sm">
          <div className="w-16 h-16 rounded-full bg-sage/20 flex items-center justify-center mx-auto mb-4">
            <Leaf className="w-8 h-8 text-olive" />
          </div>
          <h2 className="font-display text-2xl text-espresso mb-2">Sin Análisis Disponible</h2>
          <p className="text-sm text-taupe mb-6">
            {pet ? 'Selecciona una croqueta para ver las recomendaciones de suplementos.' : 'Empieza creando el perfil de tu perro para obtener recomendaciones de suplementos.'}
          </p>
          <button onClick={() => navigate(pet ? '/kibble' : '/add-pet')} className="bg-terracotta text-white font-medium px-6 py-3 rounded-full hover:bg-terracotta-dark transition-all">
            {pet ? 'Seleccionar Croquetas' : 'Comenzar Análisis'}
          </button>
        </div>
      </div>
    );
  }

  const { recommendedCategories, deficient, borderline } = analysis;

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12">
      <div className="max-w-[800px] mx-auto px-4">
        <PetHeader title={pet ? `Suplementos para ${pet.name}` : 'Recomendaciones de Suplementos'} subtitle={analysis.kibble ? `${analysis.kibble.brand} ${analysis.kibble.name}` : undefined} />

        {/* Breaches found */}
        <div className="bg-white rounded-2xl border border-border-subtle p-5 mb-6">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-terracotta/10 flex items-center justify-center flex-shrink-0">
              <AlertCircle className="w-5 h-5 text-terracotta" />
            </div>
            <div>
              <h3 className="text-sm font-semibold text-espresso">Brechas Nutricionales Encontradas</h3>
              <p className="text-sm text-taupe mt-1">
                Encontramos <span className="font-medium text-terracotta">{deficient.length} deficiente{deficient.length !== 1 ? 's' : ''}</span> y{' '}
                <span className="font-medium text-sage">{borderline.length} al límite</span>.
                {recommendedCategories.length === 0 && ' Aun así, estos consejos generales pueden ayudar a mantener la salud óptima de tu perro.'}
              </p>
            </div>
          </div>
        </div>

        {/* Specific recommendations when there are deficiencies */}
        {recommendedCategories.length > 0 ? (
          <div className="space-y-6 mb-6">
            {recommendedCategories.map((cat) => (
              <div key={cat.id} className="bg-white rounded-2xl border border-border-subtle p-5">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 rounded-xl bg-sage/15 flex items-center justify-center text-olive">
                    {categoryIcons[cat.id]}
                  </div>
                  <div>
                    <h3 className="text-base font-semibold text-espresso">{cat.name}</h3>
                    <p className="text-xs text-warm-gray">{cat.when}</p>
                  </div>
                </div>

                {/* Natural options */}
                <div className="mb-4">
                  <h4 className="text-xs font-semibold text-olive uppercase tracking-wider mb-2">Opciones Naturales</h4>
                  <div className="space-y-3">
                    {cat.supplements.map((sup, i) => (
                      <div key={i} className="bg-cream rounded-xl p-4 border border-border-subtle">
                        <div className="flex items-start justify-between gap-3">
                          <div>
                            <div className="text-sm font-medium text-espresso">{sup.name}</div>
                            <div className="text-xs text-terracotta font-medium mt-0.5">{sup.dosage}</div>
                          </div>
                          <div className="w-6 h-6 rounded-full bg-olive/10 flex items-center justify-center flex-shrink-0">
                            <Check className="w-3.5 h-3.5 text-olive" />
                          </div>
                        </div>
                        <p className="text-xs text-taupe mt-2">{sup.notes}</p>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Commercial options */}
                {cat.commercial && cat.commercial.length > 0 && (
                  <div>
                    <h4 className="text-xs font-semibold text-terracotta uppercase tracking-wider mb-2 flex items-center gap-1">
                      <Store className="w-3 h-3" /> Opciones Comerciales / Premix
                    </h4>
                    <div className="space-y-3">
                      {cat.commercial.map((sup, i) => (
                        <div key={i} className="bg-terracotta/5 rounded-xl p-4 border border-terracotta/10">
                          <div className="flex items-start justify-between gap-3">
                            <div>
                              <div className="text-sm font-medium text-espresso">{sup.name}</div>
                              <div className="text-xs text-terracotta font-medium mt-0.5">{sup.dosage}</div>
                            </div>
                            <div className="w-6 h-6 rounded-full bg-terracotta/10 flex items-center justify-center flex-shrink-0">
                              <Store className="w-3.5 h-3.5 text-terracotta" />
                            </div>
                          </div>
                          <p className="text-xs text-taupe mt-2">{sup.notes}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        ) : (
          /* No specific recommendations - show wellness message */
          <div className="bg-olive/5 rounded-2xl border border-olive/20 p-6 mb-6">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full bg-olive/15 flex items-center justify-center flex-shrink-0">
                <Check className="w-5 h-5 text-olive" />
              </div>
              <div>
                <h3 className="text-sm font-semibold text-espresso">Cobertura nutricional adecuada</h3>
                <p className="text-sm text-taupe mt-1">
                  La croqueta seleccionada cubre todos los nutrientes esenciales a niveles adecuados según AAFCO.
                  No se detectaron deficiencias que requieran suplementación específica.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* General Wellness Tips - ALWAYS shown */}
        <div className="bg-white rounded-2xl border border-border-subtle p-5 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <Heart className="w-4 h-4 text-terracotta" />
            <h3 className="text-sm font-semibold text-espresso">Consejos de Bienestar General</h3>
          </div>
          <div className="grid md:grid-cols-2 gap-3">
            {wellnessTips.map((tip, i) => (
              <div key={i} className="flex items-start gap-2.5 p-3 bg-cream rounded-lg">
                <div className="flex-shrink-0 mt-0.5">{tip.icon}</div>
                <p className="text-xs text-taupe leading-relaxed">{tip.text}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Tips section */}
        <div className="bg-olive/5 rounded-2xl border border-olive/20 p-5 mb-6">
          <div className="flex items-center gap-2 mb-3">
            <HelpCircle className="w-4 h-4 text-olive" />
            <h3 className="text-sm font-semibold text-olive">¿Cuándo consultar al veterinario?</h3>
          </div>
          <ul className="space-y-2 text-sm text-taupe">
            <li>• Antes de iniciar cualquier régimen de suplementación si tu perro tiene condiciones médicas.</li>
            <li>• Si observas cambios en el apetito, energía o comportamiento después de introducir un suplemento.</li>
            <li>• Si tu perro está gestando o lactando — los requerimientos son mayores y específicos.</li>
            <li>• Para perros senior (7+ años) se recomienda chequeo semestral con análisis de sangre.</li>
          </ul>
          <button onClick={() => navigate('/education')}
            className="mt-3 text-xs text-terracotta font-medium hover:underline flex items-center gap-1">
            <ExternalLink className="w-3 h-3" /> Más información en la Guía de Nutrición Canina
          </button>
        </div>

        <div className="p-4 bg-cream rounded-xl border border-border-subtle">
          <p className="text-xs text-warm-gray leading-relaxed">
            <strong className="text-taupe">Importante:</strong> Estas recomendaciones son orientativas basadas en los estándares AAFCO y el estudio PROFECO 2023. No sustituyen el consejo veterinario. Consulta a tu médico veterinario antes de iniciar cualquier régimen de suplementación.
          </p>
        </div>
      </div>
    </div>
  );
}
