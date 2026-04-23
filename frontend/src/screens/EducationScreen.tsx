import { BookOpen, Beaker, Bone, FileText, ExternalLink, AlertTriangle } from 'lucide-react';
import { sources } from '../data/nutrients';

export default function EducationScreen() {

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12">
      <div className="max-w-[800px] mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-display text-2xl md:text-3xl text-espresso">Guía de Nutrición Canina</h1>
          <p className="text-sm text-taupe">Estándares AAFCO, conversión a materia seca, alimentos tóxicos y más</p>
        </div>

        {/* What is AAFCO */}
        <div id="what-is-aafco" className="bg-white rounded-2xl border border-border-subtle p-6 mb-6 scroll-mt-24">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-olive/10 flex items-center justify-center">
              <FileText className="w-5 h-5 text-olive" />
            </div>
            <h2 className="text-lg font-semibold text-espresso">¿Qué es AAFCO?</h2>
          </div>
          <div className="space-y-3 text-sm text-taupe leading-relaxed">
            <p>
              <strong className="text-espresso">AAFCO</strong> (Association of American Feed Control Officials) define dos perfiles nutricionales para perros: <strong>Adult Maintenance</strong> y <strong>Growth and Reproduction</strong>. El segundo cubre cachorros, gestación y lactancia bajo un mismo perfil.
            </p>
            <p>
              Un alimento <strong className="text-espresso">"Complete and Balanced"</strong> debe cumplir vía formulación o prueba de alimentación de 6 meses en perros reales.
            </p>
          </div>
        </div>

        {/* Dry Matter Conversion */}
        <div id="dry-matter" className="bg-white rounded-2xl border border-border-subtle p-6 mb-6 scroll-mt-24">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-sage/15 flex items-center justify-center">
              <Beaker className="w-5 h-5 text-olive" />
            </div>
            <h2 className="text-lg font-semibold text-espresso">Conversión a Materia Seca (MS)</h2>
          </div>
          <div className="space-y-3 text-sm text-taupe leading-relaxed">
            <p>
              Las etiquetas de croquetas reportan nutrientes en <strong className="text-espresso">base húmeda</strong> ("como están"), que incluye el agua del alimento. Para comparar entre marcas con diferente humedad, AAFCO requiere convertir a <strong className="text-espresso">materia seca</strong>.
            </p>
            <div className="bg-cream rounded-xl p-4 border border-border-subtle">
              <p className="text-xs text-warm-gray mb-2 font-medium uppercase tracking-wider">Fórmula</p>
              <div className="font-mono text-sm text-espresso">
                MS% = (Base húmeda% / (100 - Humedad%)) × 100
              </div>
            </div>
            <div className="bg-cream rounded-xl p-4 border border-border-subtle">
              <p className="text-xs text-warm-gray mb-2 font-medium uppercase tracking-wider">Ejemplo práctico</p>
              <p className="text-sm text-espresso">
                Si una croqueta tiene <strong>25% proteína</strong> y <strong>10% humedad</strong>:
              </p>
              <div className="font-mono text-sm text-espresso mt-2">
                MS = 25 / (100 - 10) × 100 = <strong className="text-terracotta">27.8% proteína en base seca</strong>
              </div>
            </div>
            <p>
              <strong className="text-espresso">¿Por qué importa?</strong> Una croqueta con 28% proteína y 8% humedad puede parecer mejor que una con 26% proteína y 12% humedad. Pero en base seca, la segunda (29.5%) supera a la primera (30.4%). La conversión elimina ese sesgo.
            </p>
          </div>
        </div>

        {/* Calcium for large breed puppies */}
        <div id="calcium" className="bg-white rounded-2xl border border-border-subtle p-6 mb-6 scroll-mt-24">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-terracotta/10 flex items-center justify-center">
              <Bone className="w-5 h-5 text-terracotta" />
            </div>
            <h2 className="text-lg font-semibold text-espresso">Calcio para Cachorros de Razas Grandes</h2>
          </div>
          <div className="space-y-3 text-sm text-taupe leading-relaxed">
            <p>
              Los cachorros de razas grandes (adulto {'>'} 25kg) son vulnerables a <strong className="text-terracotta">osteodistrofia hipertrófica</strong> y displasia de cadera cuando reciben calcio en exceso durante el crecimiento.
            </p>
            <div className="bg-terracotta/5 rounded-xl p-4 border border-terracotta/15">
              <p className="text-xs text-terracotta font-semibold mb-2 uppercase tracking-wider">Límites AAFCO para cachorros grandes</p>
              <ul className="space-y-1 text-sm text-espresso">
                <li>• Calcio: <strong>1.0% - 1.8%</strong> en base seca</li>
                <li>• Relación Ca:P: <strong>1:1 a 2:1</strong></li>
                <li>• Vitamina D: <strong>125 - 750 UI/kg</strong></li>
              </ul>
            </div>
            <p>
              El exceso de calcio acelera el crecimiento óseo antes de que los músculos y ligamentos puedan adaptarse, aumentando el riesgo de deformidades esqueléticas. <strong className="text-espresso">Nunca supplemantes calcio adicional</strong> a un cachorro de raza grande sin indicación veterinaria.
            </p>
            <p className="text-xs text-warm-gray">
              Razas afectadas: Pastor Alemán, Labrador, Golden Retriever, Gran Danés, Rottweiler, Doberman, San Bernardo, Mastín, y cualquier raza cuyo peso adulto estimado supere 25kg.
            </p>
          </div>
        </div>

        {/* MER Explanation */}
        <div id="mer" className="bg-white rounded-2xl border border-border-subtle p-6 mb-6 scroll-mt-24">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-sage/15 flex items-center justify-center">
              <BookOpen className="w-5 h-5 text-olive" />
            </div>
            <h2 className="text-lg font-semibold text-espresso">Cálculo de Energía (MER)</h2>
          </div>
          <div className="space-y-3 text-sm text-taupe leading-relaxed">
            <p>
              El <strong className="text-espresso">MER</strong> (Metabolizable Energy Requirement) es la cantidad diaria de kilocalorías que un perro necesita.
            </p>
            <div className="bg-cream rounded-xl p-4 border border-border-subtle">
              <p className="text-xs text-warm-gray mb-2 font-medium uppercase tracking-wider">RER (energía en reposo)</p>
              <div className="font-mono text-sm text-espresso mb-3">RER = 70 × (peso en kg)^0.75</div>
              <p className="text-xs text-warm-gray mb-2 font-medium uppercase tracking-wider">MER = RER × factor</p>
            </div>
            <div className="bg-terracotta/5 rounded-xl p-4 border border-terracotta/15">
              <p className="text-xs text-terracotta font-semibold mb-2 uppercase tracking-wider">Factores AAFCO/NRC</p>
              <div className="grid grid-cols-2 gap-2 text-xs text-espresso">
                <div>Cachorro: <strong>2.0 - 3.0</strong></div>
                <div>Adulto sedentario: <strong>1.2</strong></div>
                <div>Adulto activo: <strong>1.4 - 1.8</strong></div>
                <div>Gestación (1-4 sem): <strong>1.8× RER</strong></div>
                <div>Gestación (5-9 sem): <strong>2.0 - 3.0× RER</strong></div>
                <div>Lactancia pico: <strong>4.0 - 8.0× RER</strong></div>
              </div>
              <p className="text-[10px] text-warm-gray mt-2">La lactancia es la etapa más exigente. Una perra de 20kg en pico de lactancia con 6 cachorros puede necesitar ~3,500 kcal/día.</p>
            </div>
          </div>
        </div>

        {/* Dangerous Foods */}
        <div id="dangerous-foods" className="bg-white rounded-2xl border border-border-subtle p-6 mb-6 scroll-mt-24">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-terracotta/10 flex items-center justify-center">
              <AlertTriangle className="w-5 h-5 text-terracotta" />
            </div>
            <h2 className="text-lg font-semibold text-espresso">Alimentos Peligrosos y Tóxicos</h2>
          </div>
          <div className="space-y-4 text-sm text-taupe leading-relaxed">
            <p>
              Algunos alimentos que consumimos diariamente son <strong className="text-terracotta">tóxicos para perros</strong>. Incluso pequeñas cantidades pueden causar daño hepático, renal, convulsiones o la muerte. Otros pueden provocar alergias, malestar gastrointestinal o pancreatitis.
            </p>

            <div className="bg-terracotta/5 rounded-xl p-4 border border-terracotta/15">
              <p className="text-xs text-terracotta font-semibold mb-3 uppercase tracking-wider">Nunca dar — Tóxicos confirmados</p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3 text-xs text-espresso">
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Chocolate</strong> — Teobromina. Convulsiones, arritmias.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Uvas y pasas</strong> — Insuficiencia renal aguda.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Cebolla y ajo</strong> — Anemia hemolítica.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Xilitol (E-967)</strong> — Hipoglucemia severa, falla hepática. También aparece como <em>edulcorante</em>, <em>alcohol de azúcar</em>, <em>maltitol</em>, <em>sorbitol</em>, <em>eritritol</em>. Revisa gomas de mascar, pastas dentales, productos "sin azúcar" y postres light.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Alcohol</strong> — Depresión del SNC, coma.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Café/té</strong> — Cafeína. Taquicardia, convulsiones.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Palta (aguacate)</strong> — Persina. Vómito, diarrea.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Nuez de macadamia</strong> — Temblores, hipertermia.</div></div>
                <div className="flex items-start gap-2"><span className="text-terracotta font-bold">✕</span><div><strong>Huesos cocidos</strong> — Astillas. Perforación intestinal.</div></div>
              </div>
            </div>

            <div className="bg-sage/10 rounded-xl p-4 border border-sage/20">
              <p className="text-xs text-olive font-semibold mb-3 uppercase tracking-wider">Precaución — Alergias y malestar frecuente</p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3 text-xs text-espresso">
                <div className="flex items-start gap-2"><span className="text-sage font-bold">!</span><div><strong>Lácteos</strong> — Intolerancia a la lactosa. Diarrea, gases.</div></div>
                <div className="flex items-start gap-2"><span className="text-sage font-bold">!</span><div><strong>Trigo/gluten</strong> — Alergia cutánea, prurito.</div></div>
                <div className="flex items-start gap-2"><span className="text-sage font-bold">!</span><div><strong>Soja</strong> — Flatulencia, malabsorción.</div></div>
                <div className="flex items-start gap-2"><span className="text-sage font-bold">!</span><div><strong>Maíz en exceso</strong> — Alergia, bajo valor biológico.</div></div>
                <div className="flex items-start gap-2"><span className="text-sage font-bold">!</span><div><strong>Sal en exceso</strong> — Deshidratación, toxicidad.</div></div>
                <div className="flex items-start gap-2"><span className="text-sage font-bold">!</span><div><strong>Grasa frita</strong> — Pancreatitis aguda.</div></div>
              </div>
            </div>

            <div className="bg-cream rounded-xl p-4 border border-border-subtle">
              <p className="text-xs text-warm-gray font-semibold mb-2 uppercase tracking-wider">Síntomas de intoxicación — Actuar de inmediato</p>
              <div className="grid grid-cols-2 gap-2 text-xs text-espresso">
                <div>• Vómitos repetidos</div>
                <div>• Diarrea con sangre</div>
                <div>• Temblores o convulsiones</div>
                <div>• Letargo o debilidad</div>
                <div>• Dificultad para respirar</div>
                <div>• Pulso acelerado o débil</div>
              </div>
            </div>

            <div className="bg-terracotta/5 rounded-xl p-4 border border-terracotta/15 text-center">
              <p className="text-sm text-espresso font-medium mb-2">¿Tu perro ingirió algo de esta lista?</p>
              <p className="text-xs text-taupe mb-3">No esperes a ver síntomas. Contacta a tu veterinario o a una clínica de emergencia de inmediato.</p>
              <a href="https://www.google.com/maps/search/veterinarios+24+horas/"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-block bg-terracotta text-white text-sm font-medium px-6 py-2.5 rounded-full hover:bg-terracotta-dark transition-all">
                Buscar veterinarios 24h
              </a>
            </div>
          </div>
        </div>

        {/* Sources */}
        <div id="sources" className="bg-white rounded-2xl border border-border-subtle p-6 mb-6 scroll-mt-24">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-clay/30 flex items-center justify-center">
              <BookOpen className="w-5 h-5 text-taupe" />
            </div>
            <h2 className="text-lg font-semibold text-espresso">Literatura Consultada</h2>
          </div>
          <ul className="space-y-3">
            {sources.map((source, i) => (
              <li key={i} className="text-sm text-taupe leading-relaxed">
                <span className="text-warm-gray font-medium">[{i + 1}]</span>{' '}
                {source.citation}
                {source.url && (
                  <a href={source.url} target="_blank" rel="noopener noreferrer" className="text-olive hover:underline ml-1 inline-flex items-center gap-0.5">
                    <ExternalLink className="w-3 h-3" /> ver
                  </a>
                )}
              </li>
            ))}
          </ul>
        </div>

        <p className="text-xs text-warm-gray text-center leading-relaxed">
          NutriPet es una herramienta informativa. No está revisada por veterinarios y no sustituye el consejo profesional. Siempre consulta a tu médico veterinario antes de cambiar la dieta de tu perro.
        </p>
      </div>
    </div>
  );
}
