# NutriPet - App de Nutrición para Mascotas

Este es el diseño definitivo para tu MVP de 3 a 5 días. He integrado el registro clásico, la lógica de estándares globales (WSAVA/AAFCO) y el uso eficiente de un Motor LLM para ajustes quirúrgicos, minimizando el consumo de tokens y costos.

## 1. Arquitectura del Sistema: El "Cerebro Hybrid"

Para cumplir con los estándares internacionales y minimizar costos de IA, el sistema no permite que la IA "invente" la dieta. La estructura es:

- **Lógica Determinística (Código)**: Calcula Calorías ($RER/MER$) según la WSAVA.
- **Base de Datos de Plantillas (Vet-Approved)**: Recetas base que cumplen con AAFCO/FEDIAF.
- **Motor de Ajuste (LLM)**: Solo se activa para "traducir" el texto de alergias/condiciones del usuario y aplicarlo a la plantilla elegida.

## 2. Historias de Usuario (Backbone del MVP)

### Épica 1: Acceso e Identidad (Auth Clásico)
- **H1 - Registro**: Como usuario, quiero registrarme con correo y contraseña para tener un perfil persistente de mi mascota.
- **H2 - Login**: Como usuario, quiero iniciar sesión para acceder a mis planes guardados desde cualquier dispositivo.
- **H3 - Recuperación**: Como usuario, quiero una opción de "Olvidé mi contraseña" para restablecer el acceso vía email.

### Épica 2: Biometría y Estándares Globales
- **H4 - Perfil Biológico**: Como dueño, quiero ingresar especie (perro/gato), peso y edad para que el sistema calcule el $RER$ ($70 \times \text{kg}^{0.75}$) y el $MER$ (multiplicador por estado metabólico) según la WSAVA.
- **H5 - Selección de Estilo**: Como usuario, quiero elegir entre Dieta Cocida, Cruda o Comercial para que el plan se adapte a mi capacidad de preparación.

### Épica 3: Ajuste Inteligente (LLM con Costo Mínimo)
- **H6 - Consideraciones Especiales (Texto)**: Como dueño, quiero escribir en un campo de texto abierto las alergias o enfermedades de mi mascota (ej. "alergia al pollo y tiene cristales en la orina").
- **H7 - Receta Ajustada**: Como usuario, quiero que el sistema tome una "Plantilla Maestra" de la veterinaria y use IA para sustituir ingredientes o ajustar suplementos basándose en mis notas de texto.

## 3. Flujo de UX y Copywriting (Screen-by-Screen)

### Pantalla 1: Registro/Login
**Copy**: "Crea la cuenta de [Mascota]. Salud validada por expertos, personalizada para su biología".
**Acción**: Campos de Email, Password + Botón "Crear Cuenta".

### Pantalla 2: Biometría (Calculadora WSAVA)
**Input**: Peso (kg), Edad, Especie, ¿Esterilizado? (Sí/No).
**Lógica**: El sistema calcula internamente: Gato castrado necesita $1.2 \times RER$; Perro castrado $1.6 \times RER$.

### Pantalla 3: Preferencias y Salud (Input de Texto)
**Selector**: "¿Cómo prefieres alimentar a tu mascota?" (Iconos: 🍳 Cocido, 🥩 Crudo, 📦 Comercial/Kibble).
**Campo de Texto**: "Cuéntanos sobre sus alergias o enfermedades (ej. Alérgico al arroz, problemas renales)".
**Copy**: "Nuestra IA ajustará las guías veterinarias basándose en tu descripción".

### Pantalla 4: El Resultado (La Prescripción)
**Header**: "Plan Nutricional: kcal/día".
**Card Receta**: Nombre del ingrediente y gramos exactos.
**Nota del Motor LLM**: "He sustituido el Arroz por Camote debido a la sensibilidad mencionada y he reducido el Fósforo por su condición renal".
**Badge Obligatorio**: "Cumple con el perfil de nutrientes de AAFCO 2024 para mantenimiento de adultos".

## 4. Estrategia para Minimizar Costos de LLM

No envíes la biometría al LLM. El LLM solo debe procesar el campo de texto de salud.

**Prompt de Bajo Costo**: "Eres un asistente veterinario. Toma esta plantilla de 'Dieta Cocida de Pavo' (1000 kcal) y este texto de usuario:. Devuelve la lista de ingredientes ajustada para mantener las calorías y cumplir con AAFCO, explicando brevemente el cambio".

**Caching**: Si un usuario vuelve a consultar la misma mascota sin cambiar el texto, no se hace una nueva llamada al LLM.

## 5. Riesgos y Mitigación Médica (UX Trust)

**Validación de Gatos**: El sistema debe insertar una "regla dura" de código (no IA): si es gato, la receta debe incluir una fuente de Taurina y Vitamina A preformada (ej. Hígado).

**Aviso Legal**: Un banner persistente: "Esta herramienta es informativa. Las dietas caseras requieren supervisión clínica para evitar deficiencias a largo plazo".

Este MVP es escalable porque el veterinario solo gestiona 5-10 archivos JSON de plantillas, y la tecnología se encarga de personalizarlas individualmente mediante IA solo cuando es necesario.
# nutripet
