# Historias de Usuario - NutriPet MVP

## Épica 1: Acceso e Identidad (Auth Clásico)

### H1 - Registro
**Como** usuario,
**Quiero** registrarme con correo y contraseña
**Para** tener un perfil persistente de mi mascota.

**Criterios de Aceptación:**
- Campo de email único
- Contraseña con mínimo 8 caracteres
- Confirmación de contraseña
- Validación de formato de email
- Mensaje de éxito y redirección al login

### H2 - Login
**Como** usuario,
**Quiero** iniciar sesión
**Para** acceder a mis planes guardados desde cualquier dispositivo.

**Criterios de Aceptación:**
- Campos de email y contraseña
- Validación de credenciales
- Mensaje de error para credenciales inválidas
- Redirección al dashboard después del login exitoso
- Opción de "Recordarme"

### H3 - Recuperación
**Como** usuario,
**Quiero** una opción de "Olvidé mi contraseña"
**Para** restablecer el acceso vía email.

**Criterios de Aceptación:**
- Enlace en pantalla de login
- Campo para ingresar email
- Envío de email con enlace de reset
- Enlace válido por 24 horas
- Nueva pantalla para cambiar contraseña

## Épica 2: Biometría y Estándares Globales

### H4 - Perfil Biológico
**Como** dueño,
**Quiero** ingresar especie (perro/gato), peso y edad
**Para** que el sistema calcule el RER (70 × kg^0.75) y el MER (multiplicador por estado metabólico) según la WSAVA.

**Criterios de Aceptación:**
- Selector para especie (perro/gato)
- Campo numérico para peso (kg)
- Campo numérico para edad (meses/años)
- Cálculo automático de RER
- Multiplicadores según estado: gestación, lactancia, etc.
- Validación de rangos razonables

### H5 - Selección de Estilo
**Como** usuario,
**Quiero** elegir entre Dieta Cocida, Cruda o Comercial
**Para** que el plan se adapte a mi capacidad de preparación.

**Criterios de Aceptación:**
- Tres opciones con iconos descriptivos
- Descripción breve de cada tipo
- Selección única requerida
- Almacenamiento de preferencia en perfil

## Épica 3: Ajuste Inteligente (LLM con Costo Mínimo)

### H6 - Consideraciones Especiales (Texto)
**Como** dueño,
**Quiero** escribir en un campo de texto abierto las alergias o enfermedades de mi mascota
**Para** que el sistema considere estas condiciones en el plan nutricional.

**Criterios de Aceptación:**
- Campo de texto libre (máximo 500 caracteres)
- Ejemplos sugeridos
- Validación de entrada no vacía si hay condiciones
- Almacenamiento del texto en base de datos

### H7 - Receta Ajustada
**Como** usuario,
**Quiero** que el sistema tome una "Plantilla Maestra" de la veterinaria y use IA para sustituir ingredientes o ajustar suplementos
**Para** basarse en mis notas de texto.

**Criterios de Aceptación:**
- Integración con LLM (ej. OpenAI GPT)
- Prompt optimizado para bajo costo
- Sustitución de ingredientes basada en alergias
- Ajuste de suplementos según condiciones médicas
- Explicación breve del cambio realizado
- Mantenimiento de cumplimiento con AAFCO

## Notas Adicionales

- Todas las historias deben incluir validaciones médicas y disclaimers
- El sistema debe cachear resultados de LLM para evitar costos innecesarios
- Implementar reglas duras de código para validaciones críticas (ej. taurina en gatos)
