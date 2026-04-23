import { useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import PetHeader from '../components/PetHeader';
import { analyzeNutrients, kibbles, nutrients, calculateDailyGrams, getToppingsForWeight } from '../data/nutrients';
import { Check, AlertTriangle, X, FileText, BookOpen, Leaf, ExternalLink } from 'lucide-react';

const daysOfWeek = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

// Fixed topping schedule - rotates through the week
const dayToppings = [0, 1, 2, 0, 3, 4, 5]; // index into toppings array for each day

export default function MealPlanScreen() {
  const navigate = useNavigate();
  const { pet, selectedKibbleId } = usePet();

  const analysis = useMemo(() => {
    if (!selectedKibbleId) return null;
    return analyzeNutrients(selectedKibbleId, (pet?.lifeStage as 'adult' | 'puppy') || 'adult');
  }, [selectedKibbleId, pet]);

  const selectedKibble = useMemo(() => {
    if (!selectedKibbleId) return null;
    return kibbles.find(k => k.id === selectedKibbleId);
  }, [selectedKibbleId]);

  const dailyGrams = useMemo(() => {
    if (!pet || !selectedKibble) return null;
    return calculateDailyGrams(
      pet.weight,
      pet.activityLevel,
      pet.lifeStage as 'puppy' | 'adult' | 'senior',
      selectedKibble.energy,
      pet.reproductiveStatus
    );
  }, [pet, selectedKibble]);

  const gramsPerMeal = dailyGrams ? Math.round(dailyGrams / 2) : null;

  // Weight-based toppings
  const weightBasedToppings = useMemo(() => {
    if (!pet) return [];
    return getToppingsForWeight(pet.weight);
  }, [pet]);

  if (!selectedKibbleId || !analysis) {
    return (
      <div className="min-h-[100dvh] bg-cream pt-20 pb-12 px-4 flex items-center justify-center">
        <div className="text-center max-w-sm">
          <div className="w-16 h-16 rounded-full bg-sage/20 flex items-center justify-center mx-auto mb-4">
            <FileText className="w-8 h-8 text-olive" />
          </div>
          <h2 className="font-display text-2xl text-espresso mb-2">Ningún Alimento Seleccionado</h2>
          <p className="text-sm text-taupe mb-6">
            {pet ? 'Selecciona una croqueta para ver el análisis nutricional.' : 'Empieza creando el perfil de tu perro para analizar su croqueta.'}
          </p>
          <button onClick={() => navigate(pet ? '/kibble' : '/add-pet')} className="bg-terracotta text-white font-medium px-6 py-3 rounded-full hover:bg-terracotta-dark transition-all">
            {pet ? 'Seleccionar Croquetas' : 'Comenzar Análisis'}
          </button>
        </div>
      </div>
    );
  }

  const { deficient, borderline, adequate, excess, caP_ratio } = analysis;
  const totalNutrients = nutrients.length;
  const coveragePercent = Math.round((adequate.length / totalNutrients) * 100);

  const eccLabels: Record<number, string> = {
    1: 'Muy delgado', 2: 'Delgado', 3: 'Ligeramente delgado',
    4: 'Ideal', 5: 'Ideal', 6: 'Sobrepeso leve',
    7: 'Sobrepeso', 8: 'Obeso', 9: 'Muy obeso',
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'adequate': return <Check className="w-3.5 h-3.5 text-olive" />;
      case 'borderline': return <AlertTriangle className="w-3.5 h-3.5 text-sage" />;
      case 'deficient': return <X className="w-3.5 h-3.5 text-terracotta" />;
      case 'excess': return <AlertTriangle className="w-3.5 h-3.5 text-terracotta" />;
      default: return null;
    }
  };

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12">
      <div className="max-w-[800px] mx-auto px-4">
        <PetHeader title={pet ? `Plan nutricional de ${pet.name}` : 'Análisis Nutricional'} subtitle={selectedKibble ? `${selectedKibble.brand} ${selectedKibble.name}` : undefined} />

        {/* Coverage Score */}
        <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="text-lg font-semibold text-espresso">Cobertura Nutricional</h2>
              <p className="text-sm text-taupe">{adequate.length} de {totalNutrients} nutrientes al nivel óptimo</p>
            </div>
            <div className="text-right">
              <div className="font-display text-4xl text-espresso">{coveragePercent}%</div>
              <div className="text-xs text-warm-gray">cobertura</div>
            </div>
          </div>
          <div className="h-3 bg-border-subtle rounded-full overflow-hidden flex">
            <div className="h-full bg-olive rounded-l-full" style={{ width: `${(adequate.length / totalNutrients) * 100}%` }} />
            <div className="h-full bg-sage" style={{ width: `${(borderline.length / totalNutrients) * 100}%` }} />
            <div className="h-full bg-terracotta rounded-r-full" style={{ width: `${((deficient.length + excess.length) / totalNutrients) * 100}%` }} />
          </div>
          <div className="flex gap-4 mt-3">
            <div className="flex items-center gap-1.5">
              <div className="w-2.5 h-2.5 rounded-full bg-olive" />
              <span className="text-xs text-warm-gray">{adequate.length} Óptimo</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-2.5 h-2.5 rounded-full bg-sage" />
              <span className="text-xs text-warm-gray">{borderline.length} Al límite</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-2.5 h-2.5 rounded-full bg-terracotta" />
              <span className="text-xs text-warm-gray">{deficient.length + excess.length} Deficiente/Exceso</span>
            </div>
          </div>
        </div>

        {/* Daily Grams - 2 Portions */}
        {dailyGrams && gramsPerMeal && (
          <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
            <h2 className="text-lg font-semibold text-espresso mb-4">Cantidad Diaria Recomendada</h2>
            <div className="flex flex-wrap items-center gap-4 md:gap-6">
              <div className="text-center flex-1 min-w-[100px]">
                <div className="font-display text-3xl text-terracotta">{dailyGrams}g</div>
                <div className="text-xs text-warm-gray">total al día</div>
              </div>
              <div className="h-10 w-px bg-border-subtle hidden md:block" />
              <div className="flex items-center gap-4 flex-1">
                <div className="text-center flex-1">
                  <div className="font-display text-2xl text-espresso">{gramsPerMeal}g</div>
                  <div className="text-xs text-warm-gray">Porción mañana</div>
                </div>
                <span className="text-warm-gray text-lg">+</span>
                <div className="text-center flex-1">
                  <div className="font-display text-2xl text-espresso">{gramsPerMeal}g</div>
                  <div className="text-xs text-warm-gray">Porción tarde/noche</div>
                </div>
              </div>
            </div>
            <p className="text-xs text-taupe mt-4 pt-3 border-t border-border-subtle">
              Basado en {pet?.weight}kg, actividad {pet?.activityLevel === 'low' ? 'baja' : pet?.activityLevel === 'moderate' ? 'moderada' : 'alta'}
              {pet?.reproductiveStatus !== 'none' && (
                <span className="text-terracotta"> · {pet?.reproductiveStatus === 'gestating' ? 'gestando' : 'lactando'}</span>
              )}
              {' · '}{pet?.eccScore ? eccLabels[pet.eccScore] : 'Condicion no registrada'}
            </p>
          </div>
        )}

        {/* Weekly Meal Plan - 2 portions with daily toppings */}
        <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
          <h2 className="text-lg font-semibold text-espresso mb-4">Horario Semanal de Alimentación</h2>
          <div className="grid grid-cols-7 gap-1.5 md:gap-2">
            {daysOfWeek.map((day, i) => {
              const toppingIdx = dayToppings[i];
              const topping = weightBasedToppings[toppingIdx];
              return (
                <div key={day} className={`text-center p-2 md:p-3 rounded-xl ${i < 5 ? 'bg-cream' : 'bg-sage/10'}`}>
                  <div className="text-xs text-warm-gray font-medium">{day}</div>
                  <div className="space-y-1 mt-2">
                    <div className="bg-terracotta/10 rounded-lg py-1 px-1">
                      <span className="text-[10px] md:text-xs font-medium text-terracotta">{gramsPerMeal || '—'}g</span>
                    </div>
                    <div className="bg-terracotta/5 rounded-lg py-1 px-1">
                      <span className="text-[10px] md:text-xs font-medium text-terracotta">{gramsPerMeal || '—'}g</span>
                    </div>
                  </div>
                  {topping && (
                    <div className="mt-1.5 text-[9px] md:text-[10px] text-olive font-medium leading-tight">
                      +{topping.name.split(' ')[0]}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
          <p className="text-xs text-warm-gray mt-4">
            * Dos porciones diarias de {gramsPerMeal}g cada una. Los toppings rotan por día para variedad nutricional.
          </p>
        </div>

        {/* Weight-based Recommended Toppings */}
        {weightBasedToppings.length > 0 && (
          <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
            <h2 className="text-lg font-semibold text-espresso mb-1">Toppings Recomendados</h2>
            <p className="text-xs text-taupe mb-4">Raciones ajustadas para un perro de {pet?.weight}kg</p>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
              {weightBasedToppings.map((topping) => (
                <div key={topping.name} className="bg-cream rounded-xl p-3 border border-border-subtle">
                  <div className="text-sm font-medium text-espresso">{topping.name}</div>
                  <div className="text-xs text-terracotta font-medium">{topping.benefit}</div>
                  <div className="text-xs text-warm-gray mt-1">{topping.amount}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Dangerous foods warning */}
        <div className="bg-terracotta/5 rounded-2xl border border-terracotta/15 p-5 mb-6 flex items-start gap-4">
          <div className="w-10 h-10 rounded-xl bg-terracotta/10 flex items-center justify-center flex-shrink-0">
            <AlertTriangle className="w-5 h-5 text-terracotta" />
          </div>
          <div className="flex-1">
            <h3 className="text-sm font-semibold text-espresso mb-1">Antes de darle algo a {pet?.name}...</h3>
            <p className="text-xs text-taupe leading-relaxed mb-3">
              Muchos alimentos que consumimos son tóxicos para perros: chocolate, uvas, cebolla, ajo, xilitol y más. Revisa la lista completa antes de compartir comida.
            </p>
            <button onClick={() => navigate('/education?s=dangerous-foods')}
              className="text-xs text-terracotta font-medium hover:underline flex items-center gap-1">
              <ExternalLink className="w-3 h-3" /> Ver alimentos peligrosos y tóxicos
            </button>
          </div>
        </div>

        {/* Supplements CTA — contextual card at the end of the meal plan */}
        <div className="bg-olive/5 rounded-2xl border border-olive/20 p-6 mb-6">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-xl bg-olive/15 flex items-center justify-center flex-shrink-0">
              <Leaf className="w-6 h-6 text-olive" />
            </div>
            <div className="flex-1">
              <h3 className="text-base font-semibold text-espresso mb-1">¿Sigues con dudas sobre la nutrición de {pet?.name}?</h3>
              <p className="text-sm text-taupe mb-4">
                Revisa nuestra guía de suplementos basada en las brechas reales detectadas en el análisis. Solo recomendamos cuando hay deficiencias confirmadas.
              </p>
              <button onClick={() => navigate('/supplements')}
                className="bg-terracotta text-white font-medium px-6 py-2.5 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all flex items-center gap-2">
                <Leaf className="w-4 h-4" />
                Ver Guía de Suplementos
              </button>
            </div>
          </div>
        </div>

        {/* Nutrient Detail */}
        <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
          <h2 className="text-lg font-semibold text-espresso mb-2">
            Análisis Detallado de Nutrientes<sup className="text-terracotta text-xs ml-0.5">*</sup>
          </h2>

          {/* Transparency: label vs estimated */}
          <div className="mb-4 p-3 bg-cream rounded-lg border border-border-subtle">
            <p className="text-xs text-taupe leading-relaxed">
              Los valores se basan en la <strong className="text-espresso">información nutricional reportada por cada marca</strong> en sus etiquetas y certificaciones. Las estimaciones de calcio, fósforo y otros micronutrientes se derivan del análisis de ingredientes declarados.
            </p>
          </div>

          {/* Ca:P Ratio */}
          {caP_ratio !== null && (
            <div className={`mb-4 p-3 rounded-lg border ${caP_ratio >= 1 && caP_ratio <= 2 ? 'bg-olive/5 border-olive/20' : 'bg-terracotta/5 border-terracotta/20'}`}>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm font-medium text-espresso">Relación Calcio : Fósforo (Ca:P)</div>
                  <div className="text-xs text-taupe mt-0.5">Ideal: 1:1 a 2:1 · Recomendado AAFCO: 1.2:1</div>
                </div>
                <div className="text-right">
                  <div className={`font-display text-2xl ${caP_ratio >= 1 && caP_ratio <= 2 ? 'text-olive' : 'text-terracotta'}`}>
                    {caP_ratio}:1
                  </div>
                  <div className="text-[10px] text-warm-gray">
                    {caP_ratio >= 1 && caP_ratio <= 2 ? 'Balanceado' : caP_ratio < 1 ? 'Revisa calcio' : 'Revisa fósforo'}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* On-label nutrients section */}
          <div className="mb-4">
            <h3 className="text-xs font-semibold text-olive uppercase tracking-wider mb-2 flex items-center gap-1">
              <Check className="w-3 h-3" /> De la etiqueta (datos reales)
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
              {analysis.analysis.filter(n => n.onLabel).map((n) => (
                <div key={n.name} className={`flex items-center gap-2 p-2 rounded-lg ${
                  n.status === 'deficient' ? 'bg-terracotta/5' : n.status === 'borderline' ? 'bg-sage/10' : 'bg-olive/5'
                }`}>
                  {getStatusIcon(n.status)}
                  <div className="min-w-0">
                    <div className="text-xs font-medium text-espresso truncate">{n.name}</div>
                    <div className="text-[10px] text-warm-gray">{n.asFed}{n.unit} base húmeda · {n.dryMatter}{n.unit} MS</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Estimated nutrients section */}
          {analysis.analysis.filter(n => !n.onLabel).length > 0 && (
            <div className="mb-4">
              <h3 className="text-xs font-semibold text-warm-gray uppercase tracking-wider mb-2">
                Estimados por ingredientes (aproximados)
              </h3>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                {analysis.analysis.filter(n => !n.onLabel).map((n) => (
                  <div key={n.name} className={`flex items-center gap-2 p-2 rounded-lg ${
                    n.status === 'deficient' ? 'bg-terracotta/5' : n.status === 'borderline' ? 'bg-sage/10' : 'bg-olive/5'
                  }`}>
                    {getStatusIcon(n.status)}
                    <div className="min-w-0">
                      <div className="text-xs font-medium text-espresso truncate">{n.name}</div>
                      <div className="text-[10px] text-warm-gray">~{n.dryMatter}{n.unit} MS</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {deficient.length > 0 && (
            <div className="mb-4">
              <h3 className="text-sm font-medium text-terracotta mb-2 flex items-center gap-2">
                <X className="w-4 h-4" /> Debajo del óptimo ({deficient.length})
              </h3>
              <div className="space-y-2">
                {deficient.map((n) => (
                  <div key={n.name} className="grid grid-cols-2 gap-3 p-3 bg-terracotta/5 rounded-xl">
                    <div className="flex items-center gap-3 min-w-0">
                      {getStatusIcon(n.status)}
                      <div className="min-w-0">
                        <div className="text-sm font-medium text-espresso truncate">{n.name}</div>
                        <div className="text-xs text-warm-gray truncate">{n.description}</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-medium text-espresso">{n.dryMatter}{n.unit} MS</div>
                      <div className="text-xs text-warm-gray">mín. AAFCO: {n.aafcoMin}{n.unit}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {borderline.length > 0 && (
            <div className="mb-4">
              <h3 className="text-sm font-medium text-sage mb-2 flex items-center gap-2">
                <AlertTriangle className="w-4 h-4" /> Al límite ({borderline.length})
              </h3>
              <div className="space-y-2">
                {borderline.map((n) => (
                  <div key={n.name} className="grid grid-cols-2 gap-3 p-3 bg-sage/5 rounded-xl">
                    <div className="flex items-center gap-3 min-w-0">
                      {getStatusIcon(n.status)}
                      <div className="min-w-0">
                        <div className="text-sm font-medium text-espresso truncate">{n.name}</div>
                        <div className="text-xs text-warm-gray truncate">{n.description}</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-medium text-espresso">{n.dryMatter}{n.unit} MS</div>
                      <div className="text-xs text-warm-gray">mín. AAFCO: {n.aafcoMin}{n.unit}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {excess.length > 0 && (
            <div className="mb-4">
              <h3 className="text-sm font-medium text-terracotta mb-2 flex items-center gap-2">
                <AlertTriangle className="w-4 h-4" /> En exceso ({excess.length})
              </h3>
              <div className="space-y-2">
                {excess.map((n) => (
                  <div key={n.name} className="grid grid-cols-2 gap-3 p-3 bg-terracotta/5 rounded-xl">
                    <div className="flex items-center gap-3 min-w-0">
                      {getStatusIcon(n.status)}
                      <div className="min-w-0">
                        <div className="text-sm font-medium text-espresso truncate">{n.name}</div>
                        <div className="text-xs text-warm-gray truncate">{n.description}</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-medium text-espresso">{n.dryMatter}{n.unit} MS</div>
                      <div className="text-xs text-warm-gray">máx. AAFCO: {n.aafcoMax}{n.unit}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          <div>
            <h3 className="text-sm font-medium text-olive mb-2 flex items-center gap-2">
              <Check className="w-4 h-4" /> Óptimo ({adequate.length})
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
              {adequate.slice(0, 9).map((n) => (
                <div key={n.name} className="flex items-center gap-2 p-2 bg-olive/5 rounded-lg">
                  <Check className="w-3 h-3 text-olive flex-shrink-0" />
                  <span className="text-xs text-espresso truncate">{n.name}</span>
                </div>
              ))}
              {adequate.length > 9 && (
                <div className="flex items-center gap-2 p-2 bg-olive/5 rounded-lg">
                  <span className="text-xs text-warm-gray">+{adequate.length - 9} más</span>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Education & Literature Link */}
        <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
          <div className="flex items-start gap-4">
            <div className="w-10 h-10 rounded-xl bg-olive/10 flex items-center justify-center flex-shrink-0">
              <BookOpen className="w-5 h-5 text-olive" />
            </div>
            <div className="flex-1">
              <h3 className="text-sm font-semibold text-espresso mb-1">Base Científica y Metodología</h3>
              <p className="text-xs text-taupe leading-relaxed mb-3">
                Conoce cómo convertimos los valores de la etiqueta a materia seca, qué es AAFCO, y por qué el calcio es crítico para cachorros de razas grandes.
              </p>
              <button onClick={() => navigate('/education?s=sources')}
                className="text-sm text-terracotta font-medium hover:underline flex items-center gap-1">
                <ExternalLink className="w-3.5 h-3.5" /> Leer literatura consultada
              </button>
            </div>
          </div>
          <p className="text-[10px] text-warm-gray mt-4 pt-3 border-t border-border-subtle">
            <sup className="text-terracotta">*</sup> Los valores estimados por ingredientes pueden variar respecto al contenido real. Consulta la sección de literatura para mayor detalle sobre nuestra metodología.
          </p>
        </div>

        {/* Disclaimer */}
        <div className="bg-cream rounded-2xl border border-border-subtle p-5 mb-6">
          <p className="text-xs text-warm-gray leading-relaxed text-center">
            <strong className="text-taupe">Importante:</strong> Estas recomendaciones son orientativas basadas en los estándares AAFCO y el estudio PROFECO 2023. No sustituyen el consejo veterinario. Consulta a tu médico veterinario antes de cambiar la dieta o iniciar suplementos.
          </p>
        </div>
      </div>
    </div>
  );
}
