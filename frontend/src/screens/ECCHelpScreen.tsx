export default function ECCHelpScreen() {
  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12">
      <div className="max-w-[900px] mx-auto px-4">
        <h1 className="font-display text-3xl md:text-4xl text-espresso mb-4">
          Escala de Condición Corporal (ECC)
        </h1>
        <p className="text-base text-taupe mb-8 max-w-[600px]">
          Una herramienta simple para evaluar la salud de tu perro. Ideal: mantener a tu perro en un ECC de 4 a 5 para una mejor salud y bienestar.
        </p>

        <div className="bg-white rounded-3xl border border-border-subtle p-6 md:p-8 mb-8">
          <img
            src="/ecc-perros.png"
            alt="Escala de Condición Corporal para Perros 1-9"
            className="w-full rounded-2xl"
          />
        </div>

        <div className="grid md:grid-cols-3 gap-4 mb-8">
          <div className="bg-white rounded-xl border border-border-subtle p-5">
            <h3 className="text-sm font-semibold text-espresso mb-2">Vista desde arriba</h3>
            <p className="text-sm text-taupe">
              Debe verse una cintura detrás de las costillas. Si no se ve, tu perro puede tener sobrepeso.
            </p>
          </div>
          <div className="bg-white rounded-xl border border-border-subtle p-5">
            <h3 className="text-sm font-semibold text-espresso mb-2">Vista de lado</h3>
            <p className="text-sm text-taupe">
              El abdomen debe estar recogido, no colgante. Un abdomen redondeado indica sobrepeso.
            </p>
          </div>
          <div className="bg-white rounded-xl border border-border-subtle p-5">
            <h3 className="text-sm font-semibold text-espresso mb-2">Palpación</h3>
            <p className="text-sm text-taupe">
              Deberías poder palpar las costillas con facilidad, pero sin que se vean. Costillas visibles = muy delgado.
            </p>
          </div>
        </div>

        <div className="bg-olive/10 rounded-2xl border border-olive/20 p-6">
          <h3 className="text-sm font-semibold text-olive mb-3">Recomendaciones por ECC</h3>
          <div className="space-y-3 text-sm">
            <div className="flex gap-3">
              <span className="font-medium text-terracotta w-24 flex-shrink-0">ECC 1-3:</span>
              <span className="text-taupe">Consulta a tu veterinario. Tu perro necesita aumentar peso de forma controlada.</span>
            </div>
            <div className="flex gap-3">
              <span className="font-medium text-olive w-24 flex-shrink-0">ECC 4-5:</span>
              <span className="text-taupe">¡Peso ideal! Mantén la dieta actual y ejercicio regular.</span>
            </div>
            <div className="flex gap-3">
              <span className="font-medium text-sage w-24 flex-shrink-0">ECC 6:</span>
              <span className="text-taupe">Sobrepeso leve. Reduce porciones un 10% y aumenta paseos.</span>
            </div>
            <div className="flex gap-3">
              <span className="font-medium text-terracotta w-24 flex-shrink-0">ECC 7-9:</span>
              <span className="text-taupe">Consulta a tu veterinario. Plan de pérdida de peso supervisado necesario.</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
