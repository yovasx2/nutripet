// AAFCO 2024 Nutrient Profiles with Dry Matter methodology
// Sources:
// - Association of American Feed Control Officials. (2024). 2024 Official Publication. AAFCO.
// - https://www.aafco.org/document/pflm-resources/pet-food-and-specialty-pet-food-nutrition-facts-calculator-march-11-2024/
// - Sanderson, S. L. (2024). Nutritional requirements of small animals. Merck Veterinary Manual.
// - https://www.merckvetmanual.com/management-and-nutrition/nutrition-small-animals/nutritional-requirements-of-small-animals

export interface Nutrient {
  name: string;
  unit: string;
  aafcoKey: string; // key used in aafco profiles
  aafcoAdultMin: number;
  aafcoAdultMax: number | null;
  aafcoGrowthMin: number;
  aafcoGrowthMax: number | null;
  optimal: number;
  onLabel: boolean; // appears on guaranteed analysis panel?
  description: string;
}

export interface Kibble {
  id: string;
  brand: string;
  name: string;
  origin: string;
  category: 'Super Premium' | 'Premium' | 'Comercial';
  nutrients: Record<string, number>;
  ingredients: string[];
  moisture: number; // %
  energy: number; // kcal/100g
  source: string;
}

export interface AafcoAnalysis {
  name: string;
  unit: string;
  asFed: number;
  dryMatter: number; // converted
  aafcoMin: number;
  aafcoMax: number | null;
  ratio: number; // vs min
  status: 'adequate' | 'borderline' | 'deficient' | 'excess';
  onLabel: boolean;
  description: string;
}

// AAFCO 2024 profiles for DRY dog food (DM basis)
// Calcium has min AND max per AAFCO (0.5% min, 2.5% max for adults)
// Vitamin D has max 3000 IU/kg
const AAFCO_ADULT = {
  'Proteína cruda': { min: 18.0, max: null },
  'Grasa cruda': { min: 5.5, max: null },
  'Fibra cruda': { min: 0, max: null }, // no AAFCO requirement, we use optimal
  'Humedad': { min: 0, max: null },
  'Cenizas': { min: 0, max: null },
  'Calcio': { min: 0.5, max: 2.5 },
  'Fósforo': { min: 0.4, max: 1.6 },
  'Vitamina D': { min: 500, max: 3000 },
};

const AAFCO_GROWTH = {
  'Proteína cruda': { min: 22.5, max: null },
  'Grasa cruda': { min: 8.5, max: null },
  'Fibra cruda': { min: 0, max: null },
  'Humedad': { min: 0, max: null },
  'Cenizas': { min: 0, max: null },
  'Calcio': { min: 1.2, max: 2.5 }, // standard; large breed puppy max 1.8%
  'Fósforo': { min: 1.0, max: 1.6 },
  'Vitamina D': { min: 500, max: 3000 },
};

// Nutrients we can meaningfully analyze from a Mexican kibble label
export const nutrients: Nutrient[] = [
  { name: 'Proteína cruda', unit: '%', aafcoKey: 'Proteína cruda', aafcoAdultMin: 18.0, aafcoAdultMax: null, aafcoGrowthMin: 22.5, aafcoGrowthMax: null, optimal: 26, onLabel: true, description: 'Esencial para mantenimiento muscular y tejidos' },
  { name: 'Grasa cruda', unit: '%', aafcoKey: 'Grasa cruda', aafcoAdultMin: 5.5, aafcoAdultMax: null, aafcoGrowthMin: 8.5, aafcoGrowthMax: null, optimal: 14, onLabel: true, description: 'Fuente de energía y transporte de vitaminas liposolubles' },
  { name: 'Fibra cruda', unit: '%', aafcoKey: 'Fibra cruda', aafcoAdultMin: 0, aafcoAdultMax: null, aafcoGrowthMin: 0, aafcoGrowthMax: null, optimal: 3, onLabel: true, description: 'Regulación digestiva y saciedad (no requerida por AAFCO, recomendada)' },
  { name: 'Humedad', unit: '%', aafcoKey: 'Humedad', aafcoAdultMin: 0, aafcoAdultMax: null, aafcoGrowthMin: 0, aafcoGrowthMax: null, optimal: 10, onLabel: true, description: 'Contenido de agua del alimento (usada para conversión a materia seca)' },
  { name: 'Cenizas', unit: '%', aafcoKey: 'Cenizas', aafcoAdultMin: 0, aafcoAdultMax: null, aafcoGrowthMin: 0, aafcoGrowthMax: null, optimal: 7, onLabel: true, description: 'Contenido mineral total; valores muy altos (>10%) indican mucho relleno' },
  { name: 'Calcio', unit: '%', aafcoKey: 'Calcio', aafcoAdultMin: 0.5, aafcoAdultMax: 2.5, aafcoGrowthMin: 1.2, aafcoGrowthMax: 2.5, optimal: 1.2, onLabel: false, description: 'Huesos, dientes y función nerviosa (ESTIMADO por ingredientes)' },
  { name: 'Fósforo', unit: '%', aafcoKey: 'Fósforo', aafcoAdultMin: 0.4, aafcoAdultMax: 1.6, aafcoGrowthMin: 1.0, aafcoGrowthMax: 1.6, optimal: 1.0, onLabel: false, description: 'Huesos, metabolismo energético (ESTIMADO por ingredientes)' },
];

// 24 real brands from PROFECO 2023 study
export const kibbles: Kibble[] = [
  // === CATEGORÍA A (9) — Fórmulas con estudios científicos ===
  { id: 'k1', brand: 'Tiër Holistic', name: 'Adulto Raza Mediana/Grande Receta Pollo', origin: 'México', category: 'Super Premium', nutrients: { 'Proteína cruda': 24.3, 'Grasa cruda': 14.5, 'Fibra cruda': 3.9, 'Humedad': 10.2, 'Cenizas': 7.7, 'Calcio': 1.1, 'Fósforo': 0.9 }, ingredients: ['Pollo deshidratado','arroz','avena','grasa de pollo','pulpa de remolacha','huevo','aceite de pescado','levadura','minerales chelados','extracto de yuca'], moisture: 10.2, energy: 385, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k2', brand: "Hill's Science Diet", name: 'Adulto Optimal Weight', origin: 'EUA', category: 'Super Premium', nutrients: { 'Proteína cruda': 21.7, 'Grasa cruda': 12.3, 'Fibra cruda': 2.3, 'Humedad': 7.8, 'Cenizas': 4.8, 'Calcio': 0.9, 'Fósforo': 0.75 }, ingredients: ['Pollo','cebada perlada','trigo integral','arroz','gluten de maíz','harina de pollo','grasa animal','hígado de pollo','aceite de soya','minerales'], moisture: 7.8, energy: 419, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k3', brand: 'Royal Canin', name: 'Medium Adult', origin: 'Canadá', category: 'Super Premium', nutrients: { 'Proteína cruda': 25.5, 'Grasa cruda': 15.2, 'Fibra cruda': 1.8, 'Humedad': 8.2, 'Cenizas': 6.6, 'Calcio': 1.0, 'Fósforo': 0.8 }, ingredients: ['Proteína de ave deshidratada','maíz','trigo','grasas animales','aislado de proteína vegetal','pulpa de remolacha','arroz','gluten de maíz','proteínas animales hidrolizadas','aceite de pescado','levadura'], moisture: 8.2, energy: 410, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k4', brand: 'Whole Hearted', name: 'Grain Free Salmon Recipe', origin: 'EUA', category: 'Super Premium', nutrients: { 'Proteína cruda': 24.0, 'Grasa cruda': 13.0, 'Fibra cruda': 5.0, 'Humedad': 6.6, 'Cenizas': 5.3, 'Calcio': 1.2, 'Fósforo': 1.0 }, ingredients: ['Salmón','harina de pescado','guisantes','patatas','lentejas','garbanzos','aceite de salmón','aceite de coco','algas marinas','extracto de romero'], moisture: 6.6, energy: 390, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k5', brand: 'Pro Plan Purina', name: 'Adulto OptiHealth', origin: 'México', category: 'Super Premium', nutrients: { 'Proteína cruda': 18.4, 'Grasa cruda': 16.6, 'Fibra cruda': 3.1, 'Humedad': 6.4, 'Cenizas': 5.6, 'Calcio': 1.0, 'Fósforo': 0.8 }, ingredients: ['Pollo','gluten de maíz','arroz','maíz integral','harina de subproductos avícolas','grasa animal','cebada','harina de pescado','huevo deshidratado','aceite de pescado'], moisture: 6.4, energy: 422, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k6', brand: 'Grand Pet', name: 'Natural Gourmet', origin: 'México', category: 'Super Premium', nutrients: { 'Proteína cruda': 33.7, 'Grasa cruda': 20.3, 'Fibra cruda': 3.1, 'Humedad': 4.6, 'Cenizas': 11.2, 'Calcio': 1.8, 'Fósforo': 1.4 }, ingredients: ['Carne de res deshidratada','harina de cordero','guisantes','lentejas','garbanzos','grasa de pollo','aceite de pescado','huevo','zanahoria deshidratada','espinaca'], moisture: 4.6, energy: 419, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k7', brand: 'Canidae', name: 'Pure Goodness Real Duck', origin: 'EUA', category: 'Super Premium', nutrients: { 'Proteína cruda': 32.0, 'Grasa cruda': 17.4, 'Fibra cruda': 1.7, 'Humedad': 7.3, 'Cenizas': 7.9, 'Calcio': 1.4, 'Fósforo': 1.1 }, ingredients: ['Pato fresco','harina de pato','guisantes','patatas','aceite de canola','harina de pescado','levadura','minerales chelados','tomate','zanahoria'], moisture: 7.3, energy: 419, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k8', brand: 'Pro Plan Purina', name: 'Active Mind OptiAge 7+', origin: 'México', category: 'Super Premium', nutrients: { 'Proteína cruda': 28.5, 'Grasa cruda': 13.9, 'Fibra cruda': 3.2, 'Humedad': 8.3, 'Cenizas': 6.1, 'Calcio': 1.1, 'Fósforo': 0.9 }, ingredients: ['Pollo','gluten de maíz','arroz','harina de subproductos avícolas','grasa animal','gluten de trigo','harina de pescado','huevo deshidratado','aceite de pescado','L-carnitina'], moisture: 8.3, energy: 399, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k9', brand: 'Nupec', name: 'Senior', origin: 'México', category: 'Super Premium', nutrients: { 'Proteína cruda': 29.6, 'Grasa cruda': 14.5, 'Fibra cruda': 2.8, 'Humedad': 8.6, 'Cenizas': 6.9, 'Calcio': 1.2, 'Fósforo': 1.0 }, ingredients: ['Harina de pollo','maíz','trigo','grasa de pollo','gluten de maíz','pulpa de remolacha','levadura','aceite de pescado','minerales','L-carnitina'], moisture: 8.6, energy: 399, source: 'PROFECO 2023 / paraperro.space' },
  // === CATEGORÍA B (8) — Nutrimentos indispensables ===
  { id: 'k10', brand: 'Pedigree', name: 'Balance Natural', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 21.0, 'Grasa cruda': 10.0, 'Fibra cruda': 3.5, 'Humedad': 10.0, 'Cenizas': 7.5, 'Calcio': 0.8, 'Fósforo': 0.6 }, ingredients: ['Harina de pollo','maíz','gluten de maíz','grasa animal','trigo','soya','pulpa de remolacha','minerales','arroz','levadura'], moisture: 10.0, energy: 380, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k11', brand: 'Dog Chow', name: 'Adultos Razas Medianas y Grandes', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 20.0, 'Grasa cruda': 9.0, 'Fibra cruda': 4.0, 'Humedad': 12.0, 'Cenizas': 8.0, 'Calcio': 0.7, 'Fósforo': 0.55 }, ingredients: ['Harina de pollo','maíz','gluten de maíz','grasa animal','trigo','soya','pulpa de remolacha','minerales','arroz','saborizante'], moisture: 12.0, energy: 370, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k12', brand: 'Grand Pet', name: 'Carne Fresca', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 25.6, 'Grasa cruda': 14.1, 'Fibra cruda': 2.5, 'Humedad': 8.1, 'Cenizas': 9.3, 'Calcio': 1.3, 'Fósforo': 1.0 }, ingredients: ['Carne de res fresca','maíz','trigo','grasa de pollo','gluten de maíz','levadura','pulpa de remolacha','minerales','aceite de pescado'], moisture: 8.1, energy: 391, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k13', brand: 'Beneful', name: 'Original', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 26.2, 'Grasa cruda': 12.8, 'Fibra cruda': 2.8, 'Humedad': 10.1, 'Cenizas': 7.4, 'Calcio': 1.0, 'Fósforo': 0.8 }, ingredients: ['Pollo','gluten de maíz','harina de subproductos avícolas','arroz','trigo','soya','grasa animal','pulpa de remolacha','levadura','minerales'], moisture: 10.1, energy: 383, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k14', brand: 'Nupec', name: 'Adulto Con Amor Mexicano', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 26.3, 'Grasa cruda': 14.1, 'Fibra cruda': 4.0, 'Humedad': 7.0, 'Cenizas': 7.8, 'Calcio': 1.2, 'Fósforo': 0.9 }, ingredients: ['Harina de pollo','maíz','trigo','grasa de pollo','gluten de maíz','pulpa de remolacha','huevo','levadura','minerales','aceite de pescado'], moisture: 7.0, energy: 395, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k15', brand: 'Respet', name: 'Republic of Pets', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 27.2, 'Grasa cruda': 11.0, 'Fibra cruda': 2.1, 'Humedad': 8.6, 'Cenizas': 8.4, 'Calcio': 1.3, 'Fósforo': 1.0 }, ingredients: ['Pollo','maíz','trigo','gluten de maíz','grasa animal','pulpa de remolacha','levadura','minerales','aceite de pescado','extracto de yuca'], moisture: 8.6, energy: 397, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k16', brand: 'One', name: 'Adulto', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 27.3, 'Grasa cruda': 13.9, 'Fibra cruda': 2.0, 'Humedad': 9.3, 'Cenizas': 6.3, 'Calcio': 1.1, 'Fósforo': 0.85 }, ingredients: ['Pollo','arroz','harina de subproductos avícolas','gluten de maíz','grasa animal','trigo','levadura','minerales','aceite de pescado'], moisture: 9.3, energy: 399, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k17', brand: 'Bark', name: 'Adulto', origin: 'México', category: 'Premium', nutrients: { 'Proteína cruda': 27.8, 'Grasa cruda': 14.8, 'Fibra cruda': 3.6, 'Humedad': 7.8, 'Cenizas': 10.0, 'Calcio': 1.4, 'Fósforo': 1.1 }, ingredients: ['Pollo','maíz','gluten de maíz','grasa animal','trigo','pulpa de remolacha','levadura','minerales','aceite de pescado'], moisture: 7.8, energy: 389, source: 'PROFECO 2023 / paraperro.space' },
  // === CATEGORÍA C (7) — Cumplen mínimos ===
  { id: 'k18', brand: 'Pedigree', name: 'High Protein', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 28.0, 'Grasa cruda': 14.0, 'Fibra cruda': 2.0, 'Humedad': 12.0, 'Cenizas': 8.2, 'Calcio': 1.0, 'Fósforo': 0.8 }, ingredients: ['Harina de pollo','maíz','gluten de maíz','grasa animal','trigo','soya','pulpa de remolacha','minerales','levadura'], moisture: 12.0, energy: 385, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k19', brand: 'Champ', name: 'Adulto', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 20.0, 'Grasa cruda': 9.1, 'Fibra cruda': 3.4, 'Humedad': 10.4, 'Cenizas': 8.2, 'Calcio': 0.7, 'Fósforo': 0.55 }, ingredients: ['Harina de pollo','maíz','grasa animal','trigo','gluten de maíz','soya','pulpa de remolacha','minerales'], moisture: 10.4, energy: 358, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k20', brand: 'The Top Choice', name: 'Adulto', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 20.7, 'Grasa cruda': 11.7, 'Fibra cruda': 3.5, 'Humedad': 6.9, 'Cenizas': 9.8, 'Calcio': 0.8, 'Fósforo': 0.6 }, ingredients: ['Harina de pollo','maíz','gluten de maíz','grasa animal','trigo','soya','pulpa de remolacha','minerales'], moisture: 6.9, energy: 378, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k21', brand: 'Campeón', name: 'Purina Adulto', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 20.9, 'Grasa cruda': 9.6, 'Fibra cruda': 4.3, 'Humedad': 7.6, 'Cenizas': 7.8, 'Calcio': 0.75, 'Fósforo': 0.6 }, ingredients: ['Harina de pollo','maíz','grasa animal','trigo','gluten de maíz','soya','pulpa de remolacha','minerales'], moisture: 7.6, energy: 369, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k22', brand: "Member's Mark", name: 'Adulto', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 22.2, 'Grasa cruda': 10.8, 'Fibra cruda': 4.4, 'Humedad': 8.6, 'Cenizas': 10.5, 'Calcio': 0.9, 'Fósforo': 0.7 }, ingredients: ['Harina de pollo','maíz','trigo','grasa animal','gluten de maíz','soya','pulpa de remolacha','minerales'], moisture: 8.6, energy: 360, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k23', brand: 'Nucan by Nupec', name: 'Adulto', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 23.1, 'Grasa cruda': 10.8, 'Fibra cruda': 4.4, 'Humedad': 8.8, 'Cenizas': 8.8, 'Calcio': 0.85, 'Fósforo': 0.65 }, ingredients: ['Harina de pollo','maíz','trigo','grasa animal','gluten de maíz','soya','pulpa de remolacha','minerales'], moisture: 8.8, energy: 366, source: 'PROFECO 2023 / paraperro.space' },
  { id: 'k24', brand: 'Optimo Selecto', name: 'by Nupec Adulto', origin: 'México', category: 'Comercial', nutrients: { 'Proteína cruda': 23.6, 'Grasa cruda': 10.1, 'Fibra cruda': 3.0, 'Humedad': 7.4, 'Cenizas': 8.0, 'Calcio': 0.9, 'Fósforo': 0.7 }, ingredients: ['Harina de pollo','maíz','trigo','grasa animal','gluten de maíz','soya','pulpa de remolacha','minerales'], moisture: 7.4, energy: 371, source: 'PROFECO 2023 / paraperro.space' },
];

// Suplementos: naturales + comerciales
export const supplementCategories = [
  {
    id: 'skin-coat', name: 'Piel y Pelaje', when: 'Omega-3 deficiente o piel seca/pelaje opaco',
    supplements: [
      { name: 'Aceite de pescado (EPA/DHA)', dosage: '100 mg por kg de peso', notes: 'Mejora brillo del pelaje y reduce inflamación' },
    ],
    commercial: [
      { name: 'Premix de ácidos grasos omega 3-6-9', dosage: 'Según instrucciones del fabricante', notes: 'Suplemento comercial balanceado' },
      { name: 'Multivitamínico con biotina y zinc', dosage: 'Según peso del perro', notes: 'Refuerza piel y pelaje desde adentro' },
    ],
  },
  {
    id: 'joints', name: 'Articulaciones y Movilidad', when: 'Perros senior, razas grandes, o articulares',
    supplements: [
      { name: 'Glucosamina + Condroitina', dosage: '20 mg/kg de glucosamina diaria', notes: 'Mejor movilidad y protección de cartílagos' },
    ],
    commercial: [
      { name: 'Suplemento articular con MSM + glucosamina + condroitina', dosage: '1 tableta por 10 kg', notes: 'Fórmula combinada para articulaciones' },
    ],
  },
  {
    id: 'digestion', name: 'Salud Digestiva', when: 'Fibra alta (>6%) o digestión sensible',
    supplements: [
      { name: 'Calabaza cocida', dosage: '1-2 cucharadas al día', notes: 'Regula tránsito intestinal' },
      { name: 'Psyllium (cáscara de plantago)', dosage: '1/4 cucharadita por 10 kg en agua', notes: 'Fibra soluble; ayuda estreñimiento y diarrea' },
    ],
    commercial: [
      { name: 'Prebiótico comercial (FOS, MOS, inulina)', dosage: 'Según instrucciones', notes: 'Alimento para bacterias beneficiosas' },
      { name: 'Probiótico canino (Lactobacillus, Bifidobacterium)', dosage: '1-5 mil millones CFU', notes: 'Restauran flora intestinal' },
    ],
  },
  {
    id: 'immunity', name: 'Sistema Inmune', when: 'Defensas bajas o en recuperación',
    supplements: [
      { name: 'Vitamina E natural', dosage: '50 IU por 10 kg', notes: 'Potente antioxidante' },
    ],
    commercial: [
      { name: 'Multivitamínico canino completo (A, D, E, B-complex, zinc, selenio)', dosage: '1 tableta por 10 kg', notes: 'Cubre múltiples brechas en una dosis' },
    ],
  },
];

// AAFCO 2024 Dry Matter analysis
export function analyzeNutrients(kibbleId: string, lifeStage: 'adult' | 'puppy' | 'senior' = 'adult'): { kibble: Kibble; analysis: AafcoAnalysis[]; deficient: AafcoAnalysis[]; borderline: AafcoAnalysis[]; adequate: AafcoAnalysis[]; excess: AafcoAnalysis[]; caP_ratio: number | null; recommendedCategories: typeof supplementCategories } | null {
  const kibble = kibbles.find(k => k.id === kibbleId);
  if (!kibble) return null;

  const aafco = lifeStage === 'puppy' ? AAFCO_GROWTH : AAFCO_ADULT;
  const moisture = kibble.nutrients['Humedad'] || kibble.moisture || 10;
  const dmFactor = (100 - moisture) / 100; // factor for DM conversion

  const analysis: AafcoAnalysis[] = nutrients.map(n => {
    const asFed = kibble.nutrients[n.name] || 0;
    const dryMatter = dmFactor > 0 ? (asFed / dmFactor) : asFed;
    const aafcoRange = aafco[n.name as keyof typeof aafco];
    const aafcoMin = aafcoRange?.min ?? n.aafcoAdultMin;
    const aafcoMax = aafcoRange?.max ?? n.aafcoAdultMax ?? null;

    let status: 'adequate' | 'borderline' | 'deficient' | 'excess';
    if (aafcoMax !== null && dryMatter > aafcoMax) status = 'excess';
    else if (dryMatter < aafcoMin * 0.9) status = 'deficient';
    else if (dryMatter < aafcoMin) status = 'borderline';
    else if (aafcoMax !== null && dryMatter > aafcoMax * 0.85) status = 'borderline';
    else status = 'adequate';

    return {
      name: n.name,
      unit: n.unit,
      asFed,
      dryMatter: Math.round(dryMatter * 100) / 100,
      aafcoMin,
      aafcoMax,
      ratio: aafcoMin > 0 ? dryMatter / aafcoMin : 0,
      status,
      onLabel: n.onLabel,
      description: n.description,
    };
  });

  const deficient = analysis.filter(a => a.status === 'deficient');
  const borderline = analysis.filter(a => a.status === 'borderline');
  const adequate = analysis.filter(a => a.status === 'adequate');
  const excess = analysis.filter(a => a.status === 'excess');

  // Ca:P ratio
  const ca = analysis.find(a => a.name === 'Calcio');
  const p = analysis.find(a => a.name === 'Fósforo');
  const caP_ratio = ca && p && p.dryMatter > 0 ? Math.round((ca.dryMatter / p.dryMatter) * 100) / 100 : null;

  // Supplements only for actual deficiencies
  const recommendedCategories = supplementCategories.filter(cat => {
    if (cat.id === 'skin-coat') return deficient.some(n => n.name.includes('Omega'));
    if (cat.id === 'joints') return lifeStage === 'senior' || deficient.some(n => n.name.includes('Glucosamina')) || deficient.some(n => n.name.includes('condroitina'));
    if (cat.id === 'digestion') return deficient.some(n => n.name.includes('Fibra')) || (kibble.nutrients['Cenizas'] || 0) > 10;
    if (cat.id === 'immunity') return deficient.length >= 2 && deficient.some(n => n.name.includes('Vitamina') || n.name.includes('Zinc') || n.name.includes('Selenio'));
    return false;
  });

  return { kibble, analysis, deficient, borderline, adequate, excess, caP_ratio, recommendedCategories };
}

// MER calculation (Metabolizable Energy Requirement)
export function calculateDailyGrams(weightKg: number, activityLevel: 'low' | 'moderate' | 'high', lifeStage: 'puppy' | 'adult' | 'senior', energyKcalPer100g: number, reproductiveStatus: 'none' | 'gestating' | 'lactating' = 'none'): number {
  const rer = 70 * Math.pow(weightKg, 0.75);
  const activityFactors = {
    low: { puppy: 2.0, adult: 1.2, senior: 1.1 },
    moderate: { puppy: 2.5, adult: 1.4, senior: 1.3 },
    high: { puppy: 3.0, adult: 1.8, senior: 1.5 },
  };
  let factor = activityFactors[activityLevel][lifeStage];
  // AAFCO/NRC factors: gestation ~1.8-3.0x RER, lactation ~4.0-8.0x RER at peak
  if (reproductiveStatus === 'gestating') factor *= 2.0;
  if (reproductiveStatus === 'lactating') factor *= 4.0;
  const mer = rer * factor;
  const kcalPerGram = energyKcalPer100g / 100;
  return Math.round(mer / kcalPerGram);
}

// Weight-based topping rations
export function getToppingsForWeight(weightKg: number) {
  const scale = Math.min(weightKg / 20, 1.5); // scale factor, capped at 1.5x for large dogs
  return [
    { name: 'Aceite de pescado', benefit: '+Omega-3', amount: `${Math.max(0.5, Math.round(scale * 10) / 10)} cdta` },
    { name: 'Calabaza cocida', benefit: '+Fibra', amount: `${Math.max(1, Math.round(scale * 20) / 10)} cdas` },
    { name: 'Yogur griego natural', benefit: '+Probióticos', amount: `${Math.max(0.5, Math.round(scale * 10) / 10)} cda` },
    { name: 'Arándanos', benefit: '+Antioxidantes', amount: `${Math.max(3, Math.round(5 * scale))} bayas` },
    { name: 'Huevo cocido', benefit: '+Proteína/B12', amount: weightKg < 8 ? '1/2 huevo' : weightKg < 20 ? '1 huevo' : '1-2 huevos' },
    { name: 'Camote cocido', benefit: '+Vit A/Fibra', amount: `${Math.max(1, Math.round(scale * 20) / 10)} cdas` },
  ];
}

// Academic sources
export const sources = [
  { citation: 'Association of American Feed Control Officials. (2024). 2024 Official Publication. AAFCO.', url: '' },
  { citation: 'AAFCO. (2024, March 11). Pet food and specialty pet food nutrition facts calculator.', url: 'https://www.aafco.org/document/pflm-resources/pet-food-and-specialty-pet-food-nutrition-facts-calculator-march-11-2024/' },
  { citation: 'Sanderson, S. L. (2024). Nutritional requirements of small animals. Merck Veterinary Manual.', url: 'https://www.merckvetmanual.com/management-and-nutrition/nutrition-small-animals/nutritional-requirements-of-small-animals' },
  { citation: 'Sanderson, S. L. (2024). Feeding practices in small animals. MSD Veterinary Manual.', url: 'https://www.msdvetmanual.com/management-and-nutrition/nutrition-small-animals/feeding-practices-in-small-animals' },
  { citation: 'MDPI. (2026, March 13). The nutritional quality of dog and cat foods. Animals, 16(6), 909.', url: 'https://doi.org/10.3390/ani16060909' },
  { citation: "Today's Veterinary Practice. (2024, April 5). Updates to pet food labels and the effect on nutritional evaluation.", url: 'https://todaysveterinarypractice.com/nutrition/aafco-pet-food-label-updates/' },
  { citation: 'VCA Animal Hospitals. (n.d.). Nutritional requirements of large and giant breed puppies.', url: 'https://vcahospitals.com/know-your-pet/nutritional-requirements-of-large-and-giant-breed-puppies' },
  { citation: 'U.S. Food and Drug Administration. (2023, September 14). "Complete and Balanced" pet food.', url: 'https://www.fda.gov/animal-veterinary/animal-health-literacy/complete-and-balanced-pet-food' },
];
