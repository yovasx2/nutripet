import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import PetHeader from '../components/PetHeader';
import { kibbles } from '../data/nutrients';
import { Search, ChevronRight, SlidersHorizontal, Camera, RotateCcw, Info } from 'lucide-react';

const sortOptions = [
  { value: 'name', label: 'Alfabético' },
  { value: 'protein', label: 'Mayor Proteína' },
  { value: 'category', label: 'Segmento' },
];

export default function KibbleSelectorScreen() {
  const navigate = useNavigate();
  const { pet, setSelectedKibbleId } = usePet();
  const [search, setSearch] = useState('');
  const [sortBy, setSortBy] = useState('name');
  const [showFilters, setShowFilters] = useState(false);
  const [proteinMin, setProteinMin] = useState(0);
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [selectedBrands, setSelectedBrands] = useState<string[]>([]);
  const [showUpload, setShowUpload] = useState(false);
  const [showCatInfo, setShowCatInfo] = useState(false);

  const brands = useMemo(() => [...new Set(kibbles.map(k => k.brand))], []);
  const categories = ['Super Premium', 'Premium', 'Comercial'];

  const hasActiveFilters = search || selectedBrands.length > 0 || selectedCategories.length > 0 || proteinMin > 0;

  const filtered = useMemo(() => {
    let result = [...kibbles];
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(k =>
        k.name.toLowerCase().includes(q) ||
        k.brand.toLowerCase().includes(q) ||
        k.ingredients.some(i => i.toLowerCase().includes(q))
      );
    }
    if (selectedBrands.length > 0) result = result.filter(k => selectedBrands.includes(k.brand));
    if (selectedCategories.length > 0) result = result.filter(k => selectedCategories.includes(k.category));
    if (proteinMin > 0) result = result.filter(k => (k.nutrients['Proteína cruda'] || 0) >= proteinMin);
    switch (sortBy) {
      case 'name': result.sort((a, b) => a.brand.localeCompare(b.brand)); break;
      case 'protein': result.sort((a, b) => (b.nutrients['Proteína cruda'] || 0) - (a.nutrients['Proteína cruda'] || 0)); break;
      case 'category': result.sort((a, b) => a.category.localeCompare(b.category)); break;
    }
    return result;
  }, [search, sortBy, selectedBrands, selectedCategories, proteinMin]);

  const toggleBrand = (brand: string) => {
    setSelectedBrands(prev => prev.includes(brand) ? prev.filter(b => b !== brand) : [...prev, brand]);
  };
  const toggleCategory = (cat: string) => {
    setSelectedCategories(prev => prev.includes(cat) ? prev.filter(c => c !== cat) : [...prev, cat]);
  };
  const handleSelect = (id: string) => {
    setSelectedKibbleId(id);
    navigate('/plan');
  };

  const resetFilters = () => {
    setSearch('');
    setSelectedBrands([]);
    setSelectedCategories([]);
    setProteinMin(0);
    setSortBy('name');
  };

  const resetUpload = () => {
    setShowUpload(false);
  };

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12">
      <div className="max-w-[800px] mx-auto px-4 md:px-6">
        {/* Header */}
        <div className="mb-6">
          <PetHeader title={pet ? `Croquetas para ${pet.name}` : 'Selecciona tus Croquetas'} />
        </div>

        {/* Contact CTA for brands not in database */}
        {!showUpload && (
          <div className="bg-terracotta/5 rounded-xl border border-terracotta/20 p-4 mb-6 flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-terracotta/10 flex items-center justify-center flex-shrink-0">
              <Camera className="w-5 h-5 text-terracotta" />
            </div>
            <div className="flex-1">
              <p className="text-sm font-medium text-espresso">¿No encuentras tu marca?</p>
              <p className="text-xs text-taupe">Contáctanos para un análisis personalizado de tu croqueta</p>
            </div>
            <button onClick={() => setShowUpload(true)} className="text-sm text-terracotta font-medium hover:underline flex-shrink-0">
              Contáctanos
            </button>
          </div>
        )}

        {/* Contact panel */}
        {showUpload && (
          <div className="bg-white rounded-2xl border border-border-subtle p-6 mb-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-semibold text-espresso">Análisis personalizado</h3>
              <button onClick={resetUpload} className="text-xs text-warm-gray hover:text-espresso">Cerrar</button>
            </div>

            <div className="space-y-4">
              <p className="text-sm text-taupe">
                Si tu croqueta no está en nuestra base de datos, podemos ayudarte con un análisis completo. Nuestro proceso verifica leyendas AAFCO, certificaciones y cruza todos los nutrientes contra los estándares oficiales.
              </p>

              <div className="bg-cream rounded-xl p-4 border border-border-subtle">
                <h4 className="text-sm font-semibold text-espresso mb-2">¿Qué necesitamos?</h4>
                <ul className="space-y-1 text-xs text-taupe">
                  <li>• Foto de la tabla de análisis garantizado</li>
                  <li>• Foto de la lista de ingredientes</li>
                  <li>• Leyendas AAFCO o certificaciones en el empaque</li>
                  <li>• Marca y nombre exacto del producto</li>
                </ul>
              </div>

              <div className="bg-olive/5 rounded-xl p-4 border border-olive/15 text-center">
                <p className="text-sm text-espresso font-medium mb-1">Escríbenos por WhatsApp</p>
                <p className="text-xs text-taupe mb-3">Respuesta en menos de 12 horas</p>
                <a href="https://wa.me/+525510463075?text=Hola,%20quiero%20un%20análisis%20personalizado%20de%20mi%20croqueta."
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-block bg-[#25D366] text-white text-sm font-medium px-6 py-2.5 rounded-full hover:bg-[#128C7E] transition-all">
                  Abrir WhatsApp
                </a>
              </div>

              <p className="text-[10px] text-warm-gray text-center">
                También puedes usar este canal para dudas, sugerencias o reportar problemas con la app.
              </p>
            </div>
          </div>
        )}

        {/* Search & Sort */}
        <div className="flex gap-3 mb-6">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-warm-gray" />
            <input type="text" value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Buscar marcas, ingredientes..."
              className="w-full pl-10 pr-4 py-3 rounded-xl border border-border-subtle bg-white text-espresso placeholder:text-warm-gray focus:outline-none focus:border-terracotta transition-colors text-sm" />
          </div>
          <button onClick={() => setShowFilters(!showFilters)}
            className={`px-4 py-3 rounded-xl border transition-all duration-200 flex items-center gap-2 ${showFilters ? 'border-terracotta bg-terracotta/5' : 'border-border-subtle bg-white hover:border-sage'}`}>
            <SlidersHorizontal className="w-4 h-4 text-espresso" />
            <span className="text-sm text-espresso hidden sm:inline">Filtros</span>
          </button>
          <select value={sortBy} onChange={(e) => setSortBy(e.target.value)}
            className="px-4 py-3 rounded-xl border border-border-subtle bg-white text-espresso text-sm focus:outline-none focus:border-terracotta appearance-none cursor-pointer">
            {sortOptions.map(opt => <option key={opt.value} value={opt.value}>{opt.label}</option>)}
          </select>
        </div>

        {/* Filters panel */}
        {showFilters && (
          <div className="bg-white rounded-xl border border-border-subtle p-4 mb-6 space-y-4">
            <div className="flex items-center justify-between">
              <label className="text-sm font-medium text-espresso">Segmento</label>
              <button onClick={() => setShowCatInfo(!showCatInfo)} className="text-xs text-olive hover:underline flex items-center gap-1">
                <Info className="w-3 h-3" /> ¿Qué significa?
              </button>
            </div>

            {showCatInfo && (
              <div className="bg-cream rounded-lg border border-border-subtle p-3 text-xs text-taupe space-y-1">
                <p><strong className="text-olive">Super Premium</strong> — Fórmulas con estudios científicos de respaldo, ingredientes de alta calidad (ej. Hill&apos;s, Royal Canin, Pro Plan).</p>
                <p><strong className="text-sage">Premium</strong> — Buen balance calidad-precio, cumplen todos los nutrientes esenciales (ej. Pedigree, Nupec, Dog Chow).</p>
                <p><strong className="text-taupe">Comercial</strong> — Cumplen los mínimos legales, opción económica (ej. Champ, Campeón, Ricocan).</p>
              </div>
            )}

            <div className="flex flex-wrap gap-2">
              {categories.map(cat => (
                <button key={cat} onClick={() => toggleCategory(cat)}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${selectedCategories.includes(cat) ? 'bg-olive text-white' : 'bg-cream border border-border-subtle text-taupe hover:border-sage'}`}>
                  {cat}
                </button>
              ))}
            </div>
            <div>
              <label className="text-sm font-medium text-espresso mb-2 block">Marcas</label>
              <div className="flex flex-wrap gap-2">
                {brands.map(brand => (
                  <button key={brand} onClick={() => toggleBrand(brand)}
                    className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${selectedBrands.includes(brand) ? 'bg-terracotta text-white' : 'bg-cream border border-border-subtle text-taupe hover:border-sage'}`}>
                    {brand}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label className="text-sm font-medium text-espresso mb-2 block">
                Proteína mínima: {proteinMin > 0 ? `${proteinMin}%` : 'Cualquiera'}
              </label>
              <input type="range" min="0" max="40" step="5" value={proteinMin} onChange={(e) => setProteinMin(Number(e.target.value))} className="w-full accent-terracotta" />
            </div>
            {hasActiveFilters && (
              <button onClick={resetFilters} className="flex items-center gap-1.5 text-xs text-terracotta font-medium hover:underline">
                <RotateCcw className="w-3 h-3" /> Limpiar todos los filtros
              </button>
            )}
          </div>
        )}

        <p className="text-xs text-warm-gray mb-4">{filtered.length} alimento{filtered.length !== 1 ? 's' : ''} encontrado{filtered.length !== 1 ? 's' : ''}</p>

        {/* Kibble cards */}
        <div className="space-y-4">
          {filtered.map((kibble) => (
            <button key={kibble.id} onClick={() => handleSelect(kibble.id)}
              className="w-full text-left bg-white rounded-2xl border border-border-subtle p-4 md:p-5 hover:shadow-md hover:-translate-y-0.5 transition-all duration-300 group">
              <div className="flex gap-4">
                <div className="flex-shrink-0 flex flex-col items-center gap-1 w-12">
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center text-xs font-bold ${
                    kibble.category === 'Super Premium' ? 'bg-terracotta/10 text-terracotta' : kibble.category === 'Premium' ? 'bg-sage/15 text-olive' : 'bg-cream text-taupe border border-border-subtle'
                  }`}>
                    {kibble.category === 'Super Premium' ? 'SP' : kibble.category === 'Premium' ? 'PR' : 'CM'}
                  </div>
                  <span className="text-[8px] text-warm-gray font-medium uppercase text-center leading-tight w-full">
                    {kibble.category}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className="text-xs text-warm-gray font-medium">{kibble.brand} · {kibble.origin}</p>
                      <h3 className="text-base font-semibold text-espresso group-hover:text-terracotta transition-colors">{kibble.name}</h3>
                    </div>
                  </div>
                  <div className="flex flex-wrap gap-2 mt-2">
                    <span className="text-xs px-2 py-0.5 rounded-full bg-olive/10 text-olive font-medium">{(kibble.nutrients['Proteína cruda'] || 0).toFixed(1)}% proteína</span>
                    <span className="text-xs px-2 py-0.5 rounded-full bg-sage/10 text-sage font-medium">{(kibble.nutrients['Grasa cruda'] || 0).toFixed(1)}% grasa</span>
                    <span className="text-xs px-2 py-0.5 rounded-full bg-clay/20 text-taupe font-medium">{kibble.energy} kcal/100g</span>
                  </div>
                  <p className="text-xs text-warm-gray mt-2 truncate">{kibble.ingredients.slice(0, 3).join(', ')}...</p>
                  <div className="flex items-center justify-between mt-3">
                    <span className="text-xs text-warm-gray">Fuente: {kibble.source}</span>
                    <span className="text-xs text-terracotta font-medium flex items-center gap-1 group-hover:gap-2 transition-all">
                      Analizar <ChevronRight className="w-3 h-3" />
                    </span>
                  </div>
                </div>
              </div>
            </button>
          ))}
        </div>

        {filtered.length === 0 && (
          <div className="text-center py-16">
            <p className="text-taupe text-sm mb-4">No hay alimentos que coincidan con tus filtros.</p>
            <button onClick={resetFilters} className="text-sm text-terracotta font-medium hover:underline flex items-center gap-1 mx-auto">
              <RotateCcw className="w-3 h-3" /> Limpiar filtros
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
