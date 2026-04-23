# NutriPet — Technical Specification

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| react | ^18.3 | UI framework |
| react-dom | ^18.3 | React DOM renderer |
| react-router-dom | ^6.26 | Multi-screen routing (landing + 5 app screens) |
| three | ^0.168 | Nutritional Data Globe + Nutrient Cascade (raw Three.js) |
| gsap | ^3.12 | ScrollTrigger animations, timelines, nav transitions |
| lenis | ^1.1 | Smooth scroll with lerp: 0.08 |
| tailwindcss | ^3.4 | Utility-first CSS |
| @tailwindcss/typography | ^0.5 | Prose styling if needed |
| typescript | ^5.6 | Type safety |
| vite | ^5.4 | Build tool |
| @vitejs/plugin-react | ^4.3 | Vite React integration |
| lucide-react | ^0.460 | Icons (Camera, BarChart3, HeartPlus, Check) |

**Fonts** (loaded via Google Fonts link in index.html):
- Instrument Serif (400, 400 italic)
- Plus Jakarta Sans (400, 500, 600)

---

## Component Inventory

### Layout (shared across screens)

| Component | Source | Notes |
|-----------|--------|-------|
| NavigationBar | Custom | Fixed top, glassmorphic, scroll-aware shadow/blur. Contains logo, nav links, CTA. Scroll past 100px → adds shadow-sm + intensifies blur. |
| Footer | Custom | 4-column grid, responsive stack. |

### Landing Page Sections

| Component | Source | Notes |
|-----------|--------|-------|
| HeroSection | Custom | Two-column (55/45), display headline with GSAP color pulse on "missing", CTA row, trust bar. Contains NutritionalDataGlobe. |
| NutritionalDataGlobe | Custom (Three.js) | Raw Three.js in useEffect. Icosahedron + 3 concentric text rings + mouse-following sphere. See Core Effects. |
| HowItWorksSection | Custom | 3-step cards with connecting dashed lines (GSAP DrawSVG). |
| NutritionDeepDiveSection | Custom | Two-column reversed. Left: nutrient list. Right: NutrientCascade. |
| NutrientCascade | Custom (Three.js) | Class-based wrapper. InstancedMesh with custom ShaderMaterial. See Core Effects. |
| ProofSection | Custom | Stats row with animated counters. |
| PricingSection | Custom | 2 pricing cards with "Most Popular" ribbon on Pro. |

### App Screens (routing)

| Component | Source | Notes |
|-----------|--------|-------|
| AddPetScreen | Custom | Pet profile form (name, breed, age, weight, activity). Mobile-first. |
| KibbleSelectorScreen | Custom | Search + filter grid of dog food products. Mobile + desktop layouts. |
| MealPlanScreen | Custom | Weekly plan with coverage bars, topping suggestions, nutrient analysis. |
| SupplementsScreen | Custom | Supplement cards showing gap-closing recommendations. |
| DashboardScreen | Custom | "Hola, María" greeting, pet cards, quick actions. Mobile + desktop. |

### Reusable Components

| Component | Source | Used By |
|-----------|--------|---------|
| PillButton | Custom | Nav, Hero, Pricing, CTAs. Two variants: filled (terracotta) + outlined. |
| SectionEyebrow | Custom | All landing sections. Uppercase caption with accent color. |
| StepCard | Custom | HowItWorksSection. Icon circle + title + body. |
| PricingCard | Custom | PricingSection. Badge + price + feature list + CTA. |
| FeatureRow | Custom | Pricing cards. Check icon + text. |
| NutrientListItem | Custom | NutritionDeepDive. Colored dot + name + status badge. |

---

## Animation Implementation

| Animation | Library | Approach | Complexity |
|-----------|---------|----------|------------|
| Section entrance (fade + translateY) | GSAP + ScrollTrigger | Batch on all sections: start: "top 85%", stagger children 0.1s | Low |
| Nav underline hover | GSAP | 2px terracotta underline slides from left, 0.3s power2.out | Low |
| Nav scroll state change | GSAP ScrollTrigger | Toggle class after 100px scroll for shadow + blur | Low |
| Hero "missing" color pulse | GSAP | Terracotta flash → settle to espresso, 0.6s on load | Low |
| Floating label card entrance | GSAP | Slide up + fade, 0.8s delay after load | Low |
| How It Works connecting lines | GSAP DrawSVG | Stroke draws left→right on scroll into view, 1s power2.inOut | Medium |
| **Nutritional Data Globe** | **Three.js raw** | Icosahedron + 3 text rings with FontLoader + mouse raycasting + continuous rotation + per-label floating opacity | **High** |
| **Nutrient Cascade** | **Three.js raw + GSAP** | InstancedMesh with custom ShaderMaterial (dithered transparency), GSAP timeline for fade progress, scroll-reactive camera parallax, floating labels | **High** |
| Pricing card hover | CSS transition | translateY(-4px) + shadow-md, 0.3s ease | Low |
| Button hover states | CSS transition | scale + shadow + bg color, 0.25s cubic-bezier | Low |
| Proof stats counters | GSAP ScrollTrigger | Animate numbers on scroll into view | Low |

---

## State & Logic Plan

### Routing
Use `react-router-dom` with 6 routes:
- `/` — Landing page
- `/add-pet` — AddPetScreen
- `/kibble` — KibbleSelectorScreen
- `/plan` — MealPlanScreen
- `/supplements` — SupplementsScreen
- `/dashboard` — DashboardScreen

The NavigationBar shows different content on landing vs app screens. On app screens, show back navigation and simplified links. Use a layout route wrapper.

### Data Flow

**Pet Profile (global context):**
- petName, breed, age, weight, activityLevel, lifeStage
- Stored in React Context, populated via AddPetScreen
- Consumed by Dashboard, MealPlan, Supplements

**Selected Kibble (global context):**
- kibbleId, brand, proteinContent, nutritionalData
- Set in KibbleSelectorScreen
- Drives MealPlan analysis and Supplements recommendations

**Nutritional Analysis (computed):**
- Cross-reference selected kibble's nutrients against AAFCO minimums
- Flag deficiencies, borderlines, adequacies
- Drive supplement recommendations
- No backend — use a static nutrient database in JSON

### Nutrient Database (static JSON)
Structure:
```
{
  "aafcoMinimums": { "adult": { "protein": 18, "fat": 5.5, ... }, "puppy": { ... } },
  "nutrients": [
    { "name": "Protein", "unit": "%", "category": "macronutrient", "aafcoAdult": 18, "aafcoPuppy": 22, "optimal": 25 },
    ...
  ],
  "kibbles": [
    { "id": "k1", "brand": "Brand", "name": "Product", "nutrients": { "protein": 26, ... }, "ingredients": [...] }
  ]
}
```

### Three.js Lifecycle

Both Three.js effects need careful cleanup:
- **NutritionalDataGlobe**: React component with useEffect. Creates scene, camera, renderer. Cleanup: dispose renderer, remove listeners.
- **NutrientCascade**: Class-based, instantiated in a useEffect. Cleanup: call destroy(), dispose renderer.
- **IntersectionObserver**: Wrap each canvas. Pause animation loop when not in viewport (set animation flag). Resume when visible. Critical for performance with two simultaneous Three.js scenes.

### Lenis + GSAP ScrollTrigger Integration
- Initialize Lenis in App root
- Connect to GSAP ScrollTrigger via `lenis.on('scroll', ScrollTrigger.update)`
- Call `gsap.ticker.add((time) => lenis.raf(time * 1000))` and disable lag smoothing

---

## Other Key Decisions

### Raw Three.js vs React Three Fiber
Use **raw Three.js** (not R3F) for both effects. The Nutritional Data Globe uses FontLoader with TextGeometry which is cleaner imperatively. The Nutrient Cascade uses custom InstancedBufferAttributes and per-instance uniform management that maps more naturally to class-based Three.js patterns. Both effects are self-contained canvases, not integrated 3D scenes.

### Font Loading Strategy
Load Helvetiker font from Three.js examples CDN (`https://threejs.org/examples/fonts/helvetiker_regular.typeface.json`). Both effects share the same font — load once, cache reference. If font fails to load, render CanvasTexture text sprites as fallback.

### Mobile Responsive Strategy
- Globe: shrink to 300x300px, reduce to 3 labels per ring
- Cascade: full width, 350px height, reduce instance count to 30 per group
- All landing sections stack vertically
- App screens are mobile-first (390px artboard reference)
