import { useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import { Camera, BarChart3, HeartPlus, Check, ChevronRight } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import SectionEyebrow from '../components/SectionEyebrow';
import StepCard from '../components/StepCard';
import NutrientListItem from '../components/NutrientListItem';
import NutritionalDataGlobe from '../components/NutritionalDataGlobe';
import { kibbles } from '../data/nutrients';

gsap.registerPlugin(ScrollTrigger);

export default function LandingPage() {
  const howItWorksRef = useRef<HTMLDivElement>(null);
  const nutritionRef = useRef<HTMLDivElement>(null);
  const proofRef = useRef<HTMLDivElement>(null);
  const heroRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.from('.hero-eyebrow', { opacity: 0, y: 20, duration: 0.6, delay: 0.2, ease: 'power2.out' });
      gsap.from('.hero-headline', { opacity: 0, y: 30, duration: 0.8, delay: 0.4, ease: 'power2.out' });
      gsap.from('.hero-sub', { opacity: 0, y: 20, duration: 0.6, delay: 0.6, ease: 'power2.out' });
      gsap.from('.hero-cta', { opacity: 0, y: 20, duration: 0.6, delay: 0.8, ease: 'power2.out' });
      gsap.from('.hero-trust', { opacity: 0, y: 20, duration: 0.6, delay: 1.0, ease: 'power2.out' });
      gsap.from('.hero-globe-card', { opacity: 0, y: 20, duration: 0.6, delay: 0.8, ease: 'power2.out' });

      gsap.fromTo('.word-missing',
        { color: '#c25e44' },
        { color: '#3d352e', duration: 0.6, delay: 1.0, ease: 'power2.out' }
      );

      const sections = [howItWorksRef.current, nutritionRef.current, proofRef.current];
      sections.forEach((section) => {
        if (!section) return;
        gsap.from(section.querySelectorAll('.animate-in'), {
          scrollTrigger: { trigger: section, start: 'top 85%' },
          opacity: 0, y: 30, duration: 0.6, ease: 'power2.out', stagger: 0.1,
        });
      });

      if (proofRef.current) {
        const statEls = proofRef.current.querySelectorAll('.stat-number');
        statEls.forEach((el) => {
          const target = parseInt(el.getAttribute('data-target') || '0');
          const suffix = el.getAttribute('data-suffix') || '';
          gsap.fromTo(el, { textContent: '0' }, {
            textContent: target,
            scrollTrigger: { trigger: el, start: 'top 90%' },
            duration: 1.5, ease: 'power2.out', snap: { textContent: 1 },
            onUpdate: function () {
              (el as HTMLElement).textContent = Math.round(Number((el as HTMLElement).textContent?.replace(/[^0-9]/g, '') || 0)) + suffix;
            }
          });
        });
      }
    });
    return () => ctx.revert();
  }, []);

  return (
    <div className="bg-cream">
      {/* ===== HERO ===== */}
      <section ref={heroRef} className="min-h-[100dvh] flex items-center pt-16" style={{ background: 'linear-gradient(135deg, #f5f3ee 0%, #f5f3ee 70%, rgba(139, 154, 127, 0.08) 100%)' }}>
        <div className="max-w-[1200px] mx-auto px-6 md:px-12 w-full py-12 md:py-0">
          <div className="grid md:grid-cols-[55%_45%] gap-12 items-center">
            <div>
              <SectionEyebrow text="ANÁLISIS NUTRICIONAL PARA PERROS" className="hero-eyebrow" />
              <h1 className="hero-headline font-display text-5xl md:text-6xl lg:text-7xl text-espresso leading-[1.1] tracking-tight mt-4">
                Descubre que le <em className="word-missing not-italic" style={{ color: '#c25e44' }}>falta</em> a tu perro
              </h1>
              <p className="hero-sub text-base md:text-lg text-taupe max-w-[480px] mt-6 leading-relaxed">
                Comparamos la tabla de análisis garantizado de las croquetas con los estándares AAFCO y datos del estudio PROFECO 2023 para encontrar los vacíos nutricionales.
              </p>
              <div className="hero-cta flex flex-wrap gap-4 mt-8">
                <Link to="/add-pet" className="bg-terracotta text-white font-medium px-8 py-3 rounded-full hover:bg-terracotta-dark hover:shadow-glow hover:scale-[1.02] transition-all duration-300">
                  Analizar Croquetas
                </Link>
                <button onClick={() => document.getElementById('como-funciona')?.scrollIntoView({ behavior: 'smooth' })} className="bg-white border border-border-subtle text-espresso font-medium px-8 py-3 rounded-full hover:shadow-md transition-all duration-300">
                  Ver Cómo Funciona
                </button>
              </div>
              <div className="hero-trust flex flex-wrap gap-6 md:gap-10 mt-12 items-center">
                {['Datos PROFECO 2023', 'Estándares AAFCO', '100% Gratis'].map((item) => (
                  <div key={item} className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full bg-olive flex items-center justify-center">
                      <Check className="w-2 h-2 text-white" />
                    </div>
                    <span className="text-xs text-warm-gray font-medium">{item}</span>
                  </div>
                ))}
              </div>
              <p className="text-xs text-warm-gray mt-4">Esta herramienta es informativa y no sustituye el consejo veterinario profesional.</p>
            </div>

            <div className="relative flex justify-center">
              <div className="relative w-[340px] h-[340px] md:w-[460px] md:h-[460px] p-10">
                <div className="absolute inset-6 rounded-full" style={{ background: 'radial-gradient(circle at center, rgba(139, 154, 127, 0.08) 0%, transparent 70%)' }} />
                <NutritionalDataGlobe />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== HOW IT WORKS ===== */}
      <section id="como-funciona" ref={howItWorksRef} className="bg-white py-20 md:py-28 lg:py-32">
        <div className="max-w-[1000px] mx-auto px-6 md:px-12">
          <div className="text-center mb-16">
            <SectionEyebrow text="TRES PASOS SENCILLOS" className="animate-in" />
            <h2 className="animate-in font-display text-4xl md:text-5xl text-espresso mt-4">
              De la etiqueta a la claridad nutricional
            </h2>
          </div>
          <div className="grid md:grid-cols-3 gap-6 md:gap-8 items-stretch">
            <div className="animate-in h-full">
              <StepCard step={1} icon={<Camera className="w-5 h-5 text-terracotta" />} iconBg="bg-terracotta/10" title="Selecciona o Sube tu Marca" body="Elige tu croqueta de nuestra base de datos del estudio PROFECO, o sube 2 fotos de la etiqueta (tabla de análisis + ingredientes)." />
            </div>
            <div className="animate-in h-full">
              <StepCard step={2} icon={<BarChart3 className="w-5 h-5 text-olive" />} iconBg="bg-sage/20" title="Comparamos con AAFCO" body="Cruzamos proteína, grasa, fibra, cenizas y otros nutrientes contra los mínimos oficiales de AAFCO para perros adultos." />
            </div>
            <div className="animate-in h-full">
              <StepCard step={3} icon={<HeartPlus className="w-5 h-5 text-olive" />} iconBg="bg-olive/15" title="Obtén el Análisis Completo" body="Descubre qué nutrientes están cubiertos, cuáles están al límite y qué suplementos naturales pueden ayudar a cerrar las brechas." />
            </div>
          </div>
        </div>
      </section>

      {/* ===== NUTRITION DEEP-DIVE ===== */}
      <section id="ciencia" ref={nutritionRef} className="bg-cream py-20 md:py-28 lg:py-32">
        <div className="max-w-[1200px] mx-auto px-6 md:px-12">
          <div className="grid md:grid-cols-2 gap-12 md:gap-16 items-center">
            <div>
              <SectionEyebrow text="LA CIENCIA" className="animate-in" />
              <h2 className="animate-in font-display text-4xl md:text-5xl text-espresso mt-4">Más que un análisis garantizado</h2>
              <p className="animate-in text-base text-taupe max-w-[440px] mt-6 leading-relaxed">
                Las etiquetas de croquetas muestran solo mínimos, no contenidos reales. Decodificamos los ingredientes, estimamos niveles biodisponibles y señalamos donde la dieta puede estar por debajo de lo óptimo — no solo de lo adecuado.
              </p>
              <div className="animate-in mt-8 space-y-4">
                <NutrientListItem dotColor="bg-olive" name="Proteína cruda" badgeText="AAFCO + 15%" badgeBg="bg-olive/10" badgeTextColor="text-olive" />
                <NutrientListItem dotColor="bg-terracotta" name="Omega-3 (EPA/DHA)" badgeText="Suele faltar" badgeBg="bg-terracotta/10" badgeTextColor="text-terracotta" />
                <NutrientListItem dotColor="bg-clay" name="Cenizas totales" badgeText="&gt;8% = mucho relleno" badgeBg="bg-clay/20" badgeTextColor="text-taupe" />
                <NutrientListItem dotColor="bg-sage" name="Fibra cruda" badgeText="Checa digestión" badgeBg="bg-sage/20" badgeTextColor="text-olive" />
              </div>
              <Link to="/add-pet" className="animate-in inline-flex items-center gap-2 text-sm text-terracotta hover:underline underline-offset-4 mt-8 font-medium">Analizar Croquetas<ChevronRight className="w-4 h-4" /></Link>
            </div>
            <div className="animate-in">
              <div className="bg-white rounded-3xl shadow-lg p-8 border border-border-subtle">
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium text-espresso">Cobertura Nutricional</span>
                    <span className="text-xs text-warm-gray">Basado en AAFCO adulto</span>
                  </div>
                  {[
                    { name: 'Proteína', value: 92, color: 'bg-olive' },
                    { name: 'Omega-3', value: 35, color: 'bg-terracotta' },
                    { name: 'Vitamina E', value: 58, color: 'bg-clay' },
                    { name: 'Zinc', value: 72, color: 'bg-sage' },
                    { name: 'Hierro', value: 88, color: 'bg-olive' },
                    { name: 'Fibra', value: 65, color: 'bg-sage' },
                  ].map((n) => (
                    <div key={n.name}>
                      <div className="flex justify-between mb-1"><span className="text-xs text-taupe">{n.name}</span><span className="text-xs text-warm-gray">{n.value}%</span></div>
                      <div className="h-2 bg-border-subtle rounded-full overflow-hidden"><div className={`h-full ${n.color} rounded-full transition-all duration-1000`} style={{ width: `${n.value}%` }} /></div>
                    </div>
                  ))}
                </div>
                <div className="mt-6 pt-4 border-t border-border-subtle flex items-center justify-between">
                  <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-olive" /><span className="text-xs text-warm-gray">Óptimo</span></div>
                  <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-sage" /><span className="text-xs text-warm-gray">Al límite</span></div>
                  <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-terracotta" /><span className="text-xs text-warm-gray">Deficiente</span></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== PROOF SECTION ===== */}
      <section ref={proofRef} className="bg-olive py-20 md:py-28 lg:py-32">
        <div className="max-w-[800px] mx-auto px-6 md:px-12 text-center">
          <h2 className="animate-in font-display text-4xl md:text-5xl text-white">Basado en datos oficiales</h2>
          <p className="animate-in text-base text-white/80 max-w-[640px] mx-auto mt-6 leading-relaxed">
            Nuestra base de datos de croquetas proviene del estudio de la PROFECO publicado en julio 2023, que analizó alimentos secos para perro adulto en laboratorio. Los nutrientes se cruzan con los perfiles oficiales de AAFCO para perros en mantenimiento.
          </p>
          <div className="animate-in flex flex-wrap justify-center gap-12 md:gap-16 mt-16">
            <div className="text-center">
              <div className="stat-number font-display text-6xl md:text-7xl text-white" data-target="18" data-suffix="">0</div>
              <div className="text-xs text-white/70 uppercase tracking-wider mt-2">Nutrientes Analizados</div>
            </div>
            <div className="text-center">
              <div className="stat-number font-display text-6xl md:text-7xl text-white" data-target={kibbles.length} data-suffix="">0</div>
              <div className="text-xs text-white/70 uppercase tracking-wider mt-2">Marcas del Estudio</div>
            </div>
            <div className="text-center">
              <div className="font-display text-6xl md:text-7xl text-white">AAFCO 2024</div>
              <div className="text-xs text-white/70 uppercase tracking-wider mt-2">Estándar de Referencia</div>
            </div>
          </div>

          <a href="https://paraperro.space/" target="_blank" rel="noopener noreferrer" className="animate-in inline-block mt-12 border border-white/40 text-white font-medium px-8 py-3 rounded-full hover:bg-white/10 transition-all duration-300">
            Ver Fuente: paraperro.space
          </a>
          <p className="animate-in text-xs text-white/50 mt-6 max-w-[500px] mx-auto">
            NutriPet es una herramienta informativa. No está revisada por veterinarios y no sustituye el diagnóstico profesional. Siempre consulta a tu médico veterinario antes de cambiar la dieta o iniciar suplementos.
          </p>
        </div>
      </section>
    </div>
  );
}
