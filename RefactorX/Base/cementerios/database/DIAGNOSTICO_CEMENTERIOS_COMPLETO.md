# 🚨 DIAGNÓSTICO COMPLETO - MÓDULO CEMENTERIOS

**Fecha**: 2025-11-09
**Status**: ❌ MÓDULO NO FUNCIONAL - REQUIERE CORRECCIÓN URGENTE

---

## 📋 RESUMEN EJECUTIVO

### Problemas Identificados

1. **❌ Formato de Llamadas API INCORRECTO**
   - Los componentes Vue usan formato ANTIGUO de llamadas
   - No son compatibles con el sistema actual
   - NO TRAEN DATOS porque las llamadas fallan

2. **❌ Estructura HTML/CSS INCORRECTA**
   - No sigue el estándar de Padrón de Licencias
   - Usa clases incorrectas que no existen en municipal-theme.css
   - Usa `<i class="fas">` en lugar de `<font-awesome-icon>`

3. **⚠️ SPs Posiblemente NO INSTALADOS**
   - Existen scripts en `/ok/` pero no están instalados en PostgreSQL
   - Necesitan instalarse en esquema `public`
   - Pueden requerir tablas en `padron_licencias.comun`

---

## 🔍 ANÁLISIS DETALLADO

### 1. FORMATO DE LLAMADAS API

#### ❌ FORMATO ACTUAL (INCORRECTO)

```javascript
// Componentes de Cementerios usan:
const api = useApi()

const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
  p_control_rcm: folioABuscar.value
})
```

**Problemas**:
- `api.callStoredProcedure()` es un método antiguo/deprecado
- Los parámetros se envían como objeto simple `{p_param: valor}`
- No especifica tipo de datos
- No especifica módulo/schema
- **RESULTADO**: Las llamadas fallan y no traen datos

#### ✅ FORMATO CORRECTO (Padrón de Licencias)

```javascript
import { useApi } from '@/composables/useApi'

const { execute } = useApi()

const params = [
  {
    nombre: 'p_control_rcm',
    valor: folioABuscar.value,
    tipo: 'integer'
  }
]

const response = await execute(
  'sp_cem_consultar_folio',     // Nombre del SP (lowercase)
  'cementerios',                 // Módulo
  params,                        // Array de parámetros con estructura
  'cementerios',                 // Conexión
  null,                          // Parámetro adicional
  'public'                       // Schema de PostgreSQL
)
```

**Ventajas**:
- Define tipo de datos explícitamente
- Especifica módulo y schema
- Compatible con GenericController
- **RESULTADO**: Las llamadas funcionan correctamente

---

### 2. ESTRUCTURA HTML/CSS

#### ❌ ESTRUCTURA ACTUAL (INCORRECTA)

```vue
<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-icon"></i>
        Título
      </h1>
    </div>

    <div class="card">
      <div class="card-header">...</div>
      <div class="card-body">
        <div class="form-group">
          <label class="form-label">Campo</label>
          <input type="text" class="form-control">
        </div>
        <button class="btn-municipal-primary">
          <i class="fas fa-check"></i>
          Botón
        </button>
      </div>
    </div>

    <table class="data-table">
      <thead>...</thead>
    </table>
  </div>
</template>
```

**Problemas**:
- Usa `<i class="fas fa-icon">` (FontAwesome directo)
- Clases inconsistentes: `module-container`, `card`, `form-control`
- No sigue estructura estándar

#### ✅ ESTRUCTURA CORRECTA (Padrón de Licencias)

```vue
<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="icon-name" />
      </div>
      <div class="module-view-info">
        <h1>Título</h1>
        <p>Descripción</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="accion">
          <font-awesome-icon icon="check" />
          Botón
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Título
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Campo</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.campo"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados
          </h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Columna</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in items" :key="item.id">
                  <td>{{ item.dato }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal
    :show="showDocumentation"
    :componentName="'NombreComponente'"
    :moduleName="'cementerios'"
    @close="closeDocumentation"
  />
</template>
```

**Clases correctas**:
- `module-view` → Contenedor principal
- `module-view-header` → Header con iconos y botones
- `module-view-content` → Contenido principal
- `municipal-card` → Tarjetas/cards
- `municipal-card-header` → Header de card
- `municipal-card-body` → Cuerpo de card
- `municipal-form-control` → Inputs de formulario
- `municipal-form-label` → Labels de formulario
- `municipal-table` → Tablas de datos
- `municipal-table-header` → Header de tabla
- `button-group` → Grupo de botones
- `form-row` → Fila de formulario
- `form-group` → Grupo de campo de formulario

---

### 3. STORED PROCEDURES

#### Archivos Disponibles

**Ubicación**: `RefactorX/Base/cementerios/database/ok/`

Archivos numerados con todos los SPs agrupados:
```
01_SP_CEMENTERIOS_CORE_all_procedures.sql
02_SP_CEMENTERIOS_GESTION_all_procedures.sql
03_SP_CEMENTERIOS_ABC_all_procedures.sql
04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql
05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql
07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql
08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql
09_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql
10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql
11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql
12_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql
... (más archivos)
```

#### Estado de Instalación

⚠️ **DESCONOCIDO** - Necesita verificación en PostgreSQL:

```sql
-- Verificar SPs instalados
SELECT
    routine_name,
    routine_schema
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
    AND routine_schema = 'public'
    AND routine_name LIKE 'sp_cem%'
ORDER BY routine_name;

-- Contar SPs de Cementerios
SELECT COUNT(*) as total_sps_cementerios
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
    AND routine_schema = 'public'
    AND routine_name LIKE 'sp_cem%';
```

---

## 🎯 PLAN DE CORRECCIÓN

### Fase 1: Verificar/Instalar SPs en PostgreSQL

**Prioridad**: 🔴 CRÍTICA

**Acciones**:
1. Conectar a PostgreSQL
2. Ejecutar script de verificación (ver arriba)
3. Si faltan SPs, instalar en orden:
   ```bash
   psql -U usuario -d nombre_bd -f 01_SP_CEMENTERIOS_CORE_all_procedures.sql
   psql -U usuario -d nombre_bd -f 02_SP_CEMENTERIOS_GESTION_all_procedures.sql
   psql -U usuario -d nombre_bd -f 03_SP_CEMENTERIOS_ABC_all_procedures.sql
   # ... continuar con todos los archivos en orden
   ```

**Verificación**:
- Ejecutar script de verificación nuevamente
- Debe mostrar todos los SPs instalados

---

### Fase 2: Migrar Componentes Vue al Formato Correcto

**Prioridad**: 🔴 CRÍTICA

**Componentes a Corregir** (37 total):

#### Componentes de CONSULTA (Alta Prioridad):
1. **ConIndividual.vue** ⭐ CRÍTICO
2. **ConsultaGuad.vue**
3. **ConsultaJar.vue**
4. **ConsultaSAnd.vue**
5. **Duplicados.vue**
6. **List_Mov.vue**

#### Componentes ABC (Alta Prioridad):
7. **ABCFolio.vue** ⭐ CRÍTICO
8. **ABCPagosxfol.vue**
9. **ABCRecargos.vue**
10. **Bonificacion1.vue**
11. **Bonificaciones.vue**
12. **Descuentos.vue**

#### Componentes de REPORTES (Media Prioridad):
13. **Rep_a_Cobrar.vue**
14. **Rep_Bon.vue**
15. **RptTitulos.vue**
16. **Estad_adeudo.vue**

#### Componentes de GESTIÓN (Media Prioridad):
17. **TrasladoFol.vue**
18. **TrasladoFolSin.vue**
19. **Traslados.vue**
20. **Liquidaciones.vue**
21. **Multiplefecha.vue**
22. **MultipleNombre.vue**
23. **MultipleRCM.vue**
24. **Titulos.vue**
25. **TitulosSin.vue**

#### Componentes ESPECIALES (Baja Prioridad):
26. **Acceso.vue** (Login - estructura única)
27. **sfrm_chgpass.vue** (Cambio contraseña - estructura única)
28-37. Otros componentes

**Cambios Requeridos para CADA Componente**:

```vue
<script setup>
// ❌ QUITAR:
import { useApi } from '@/composables/useApi'
const api = useApi()

// ✅ AGREGAR:
import { useApi } from '@/composables/useApi'
const { execute } = useApi()

// ❌ QUITAR llamadas como:
const response = await api.callStoredProcedure('SP_CEM_XXX', {
  p_param1: valor1,
  p_param2: valor2
})

// ✅ REEMPLAZAR por:
const params = [
  {
    nombre: 'p_param1',
    valor: valor1,
    tipo: 'integer' // o 'string', 'date', 'boolean', etc.
  },
  {
    nombre: 'p_param2',
    valor: valor2,
    tipo: 'string'
  }
]

const response = await execute(
  'sp_cem_xxx',      // Nombre SP en lowercase
  'cementerios',     // Módulo
  params,            // Array de parámetros
  'cementerios',     // Conexión
  null,              // Parámetro adicional
  'public'           // Schema
)

// ✅ Procesar respuesta:
if (response && response.result) {
  // Los datos están en response.result (no response.data)
  datos.value = response.result
}
</script>
```

---

### Fase 3: Actualizar Estructura HTML/CSS

**Prioridad**: 🟡 MEDIA (Después de Fase 2)

**Reemplazos globales necesarios**:

```vue
<!-- Estructura general -->
<div class="module-container">      → <div class="module-view">
<div class="module-header">         → <div class="module-view-header">
<h1 class="module-title">           → (Usar estructura completa con icon/info)

<!-- Cards -->
<div class="card">                  → <div class="municipal-card">
<div class="card-header">           → <div class="municipal-card-header">
<div class="card-body">             → <div class="municipal-card-body">

<!-- Formularios -->
<label class="form-label">          → <label class="municipal-form-label">
<input class="form-control">        → <input class="municipal-form-control">
<select class="form-control">       → <select class="municipal-form-control">

<!-- Tablas -->
<table class="data-table">          → <table class="municipal-table">
<thead>                             → <thead class="municipal-table-header">

<!-- Iconos -->
<i class="fas fa-search"></i>       → <font-awesome-icon icon="search" />
<i class="fas fa-check"></i>        → <font-awesome-icon icon="check" />
<i class="fas fa-times"></i>        → <font-awesome-icon icon="times" />

<!-- Badges -->
badge badge-success                 → badge-success
badge badge-warning                 → badge-warning
badge badge-danger                  → badge-danger
badge badge-info                    → badge-purple
```

---

## 📝 COMPONENTES POR PRIORIDAD DE CORRECCIÓN

### 🔴 PRIORIDAD CRÍTICA (Hacer Primero)

1. **ConIndividual.vue**
   - SP: `sp_cem_consultar_folio`, `sp_cem_consultar_pagos_folio`
   - Componente más usado para consultas

2. **ABCFolio.vue**
   - SP: `sp_abcf_get_folio`, `sp_abcf_update_folio`
   - Alta/Baja/Cambio de folios

3. **ConsultaGuad.vue** / **ConsultaJar.vue** / **ConsultaSAnd.vue**
   - SPs de consulta por cementerio
   - Usados frecuentemente

### 🟠 PRIORIDAD ALTA

4. **ABCPagosxfol.vue**
5. **ABCRecargos.vue**
6. **Bonificacion1.vue**
7. **Duplicados.vue**
8. **List_Mov.vue**

### 🟡 PRIORIDAD MEDIA

9-16. Reportes y estadísticas
17-25. Gestión y traslados

### 🟢 PRIORIDAD BAJA

26-37. Componentes especiales y secundarios

---

## ✅ CHECKLIST DE VERIFICACIÓN

### Para cada componente corregido:

- [ ] Importa `const { execute } = useApi()`
- [ ] Parámetros en formato array con `{nombre, valor, tipo}`
- [ ] Llamada con `execute(sp, modulo, params, conexion, null, schema)`
- [ ] Respuesta procesada desde `response.result` (no `.data`)
- [ ] Estructura HTML usa clases `module-view*`
- [ ] Estructura HTML usa clases `municipal-*`
- [ ] Iconos con `<font-awesome-icon icon="..." />`
- [ ] Incluye `DocumentationModal` al final del template
- [ ] Maneja errores correctamente
- [ ] Probado con datos reales

---

## 🎯 PRÓXIMOS PASOS INMEDIATOS

1. **Verificar SPs en PostgreSQL** (15 minutos)
   ```sql
   SELECT COUNT(*) FROM information_schema.routines
   WHERE routine_schema = 'public' AND routine_name LIKE 'sp_cem%';
   ```

2. **Si faltan SPs: Instalarlos** (30 minutos)
   - Ejecutar archivos de `/ok/` en orden

3. **Corregir ConIndividual.vue** (30 minutos)
   - Primer componente de prueba
   - Validar que funcione correctamente

4. **Corregir ABCFolio.vue** (30 minutos)
   - Segundo componente crítico

5. **Crear script automatizado** (1 hora)
   - Script para migrar resto de componentes

6. **Probar componentes corregidos** (2 horas)
   - Con datos reales en PostgreSQL

---

## 📚 ARCHIVOS DE REFERENCIA

### Componente de Padrón (Referencia Correcta)
`RefactorX/FrontEnd/src/views/modules/padron_licencias/ConsultaTramitefrm.vue`

### Componente de Cementerios (A Corregir)
`RefactorX/FrontEnd/src/views/modules/cementerios/ConIndividual.vue`

### Scripts SQL
`RefactorX/Base/cementerios/database/ok/*.sql`

---

**Generado**: 2025-11-09
**Autor**: Claude Code
**Estado**: DIAGNÓSTICO COMPLETO - LISTO PARA CORRECCIÓN
