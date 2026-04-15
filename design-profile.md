# Perfil de Diseño - NutriPet

## Sistema de Colores

Basado en el esquema de colores de Material Design 3, adaptado para la aplicación veterinaria.

### Colores Primarios
- **Primary**: #005d90 (Azul oscuro para confianza y profesionalismo)
- **On Primary**: #ffffff (Texto blanco sobre primary)
- **Primary Container**: #0077b6 (Variante más clara para fondos)
- **On Primary Container**: #f3f7ff (Texto sobre primary container)

### Colores Secundarios
- **Secondary**: #00677d (Azul verdoso para elementos complementarios)
- **On Secondary**: #ffffff
- **Secondary Container**: #50d9fe (Azul claro para acentos)
- **On Secondary Container**: #005c70

### Colores Terciarios
- **Tertiary**: #00626f (Verde azulado para elementos terciarios)
- **On Tertiary**: #ffffff
- **Tertiary Container**: #227c8a
- **On Tertiary Container**: #e7fbff

### Colores de Superficie
- **Background**: #eefcff (Fondo principal claro)
- **On Background**: #001f24 (Texto sobre fondo)
- **Surface**: #eefcff (Superficies elevadas)
- **On Surface**: #001f24
- **Surface Variant**: #c3e9f1 (Variantes de superficie)
- **On Surface Variant**: #404850

### Contenedores de Superficie
- **Surface Container Lowest**: #ffffff
- **Surface Container Low**: #dcf9ff
- **Surface Container**: #cef5fd
- **Surface Container High**: #c9eff7
- **Surface Container Highest**: #c3e9f1

### Colores de Error
- **Error**: #ba1a1a
- **On Error**: #ffffff
- **Error Container**: #ffdad6
- **On Error Container**: #93000a

### Colores de Outline
- **Outline**: #707881
- **Outline Variant**: #bfc7d1

## Tipografía

### Fuentes
- **Headline**: Plus Jakarta Sans (Peso: 400, 500, 600, 700, 800)
- **Body**: Plus Jakarta Sans
- **Label**: Plus Jakarta Sans
- **Display**: Plus Jakarta Sans

### Google Fonts
- Plus Jakarta Sans: https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800
- Inter: https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600 (como respaldo)

## Iconografía

### Material Symbols
- Fuente: https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1
- Uso: Iconos de Material Design 3 para consistencia

## Estilos Visuales

### Bordes Redondeados
- DEFAULT: 0.25rem
- lg: 0.5rem
- xl: 0.75rem
- full: 9999px

### Efectos Especiales
- **Glass Nav**: background: rgba(248, 250, 253, 0.6); backdrop-filter: blur(12px);
- **Restorative Mesh**: Gradiente radial para texturas sutiles

### Animaciones
- Transiciones suaves con cubic-bezier
- Hover effects con scale y opacity
- Backdrop blur para elementos flotantes

## Componentes Clave

### Navbar
- Fixed top, backdrop blur
- Logo: NutriPet Vet
- Navegación: Guía Nutricional, Calculadoras, Consultas
- Botón CTA: "Comenzar"

### Footer
- Copyright y cumplimiento normativo
- Enlaces: Política de Privacidad, Términos, Guías SAGARPA, Contacto

## Responsive Design

- Mobile-first approach
- Breakpoints: sm, md, lg, xl
- Grid system con Tailwind CSS
- Flexbox para layouts flexibles

## Accesibilidad

- Contraste de colores según WCAG
- Soporte para modo oscuro (darkMode: "class")
- Navegación por teclado
- ARIA labels donde sea necesario

## Implementación Técnica

### Tailwind Config
```javascript
tailwind.config = {
  darkMode: "class",
  theme: {
    extend: {
      colors: { /* colores definidos arriba */ },
      borderRadius: { /* definidos arriba */ },
      fontFamily: { /* definidos arriba */ }
    }
  }
}
```

### CDN
- Tailwind: https://cdn.tailwindcss.com?plugins=forms,container-queries
- Plugins: forms, container-queries

Este perfil asegura consistencia visual y una experiencia de usuario profesional en toda la aplicación NutriPet.
