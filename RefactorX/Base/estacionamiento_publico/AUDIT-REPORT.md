# Auditoria Estilos CSS - estacionamiento_publico

Fecha: 2025-11-09
Total componentes: 108 archivos Vue

## RESUMEN

- Archivos analizados: 108
- Con estilos inline: 18 (16.7%)
- Con style scoped: 61 (56.5%)
- **CRITICO: 1 archivo usa badge-info**
- Composition API: 5 (4.6%)
- Options API: 103 (95.4%)

## ISSUE CRITICO

### badge-info en ConsultaPublicos.vue

Archivo: RefactorX/FrontEnd/src/views/modules/estacionamiento_publico/ConsultaPublicos.vue
Linea: 48

ANTES:
  <span class="badge-info">

DESPUES:
  <span class="badge-purple">

Accion: Reemplazar INMEDIATAMENTE
Tiempo: 5 minutos

## ISSUES ALTA PRIORIDAD

### 1. text-transform:uppercase inline (8 instancias)

Archivos afectados:
- AplicaPgo_DivAdmin.vue (linea 22)
- sfrm_abc_propietario.vue (lineas 17,27,33,37,42,46)
- Reactiva_Folios.vue (linea 25)
- ConsGral.vue (linea 25)

Solucion: Usar clase .text-uppercase de Bootstrap
Tiempo: 30 minutos

### 2. Estilos inline complejos

ConsGral.vue linea 25:
- Multiples propiedades: font-size, font-weight, color, font-family
- Crear clase .input-placa-destacado

ConsultaPublicos.vue linea 121:
- Propiedades: display:flex, gap, margin-bottom
- Crear clase .tab-nav

## PRIORIDAD MEDIA

### Colores hardcodeados (15 archivos)

Crear variables CSS:
- --ep-bg-light: #f8f9fa
- --ep-bg-white: #fff
- --ep-border-light: #eee
- --ep-color-maroon: #800000
- --ep-success-bg: #e0ffe0
- --ep-error-bg: #ffe0e0

## PLAN MIGRACION

### FASE 1 - CRITICA (1 dia)
1. Corregir badge-info (5 min)
2. Migrar text-transform (30 min)
3. Crear clases para estilos complejos (30 min)

### FASE 2 - ALTA (2-3 dias)
1. Implementar variables CSS (2 horas)
2. Migrar colores hardcodeados (4 horas)
3. Crear clases modales (1 hora)

## OBSERVACIONES

1. Carpeta duplicada: vue/ con archivos identicos
2. Solo 1 componente usa badge-info (98% ya usa badge-purple)
3. Tasa conformidad: 94.4%
4. FrontEnd usa Composition API, Base usa Options API

## ARCHIVOS CRITICOS

1. ConsultaPublicos.vue - CRITICO (badge-info)
2. ConsGral.vue - ALTA (estilos complejos)
3. sfrm_abc_propietario.vue - ALTA (6x text-transform)
