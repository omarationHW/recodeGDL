# PATRÓN ESTÁNDAR - PADRÓN_LICENCIAS

**Fecha:** 2025-11-09
**Componente de referencia:** certificacionesfrm.vue
**Módulo:** padron_licencias
**Cumplimiento:** 100% (Gold Standard)

---

## 📋 RESUMEN EJECUTIVO

Este documento define el patrón estándar que TODOS los componentes Vue deben seguir, basado en el análisis de 5 componentes "gold" del módulo padrón_licencias que cumplen el 100% de los estándares municipales:

1. **certificacionesfrm.vue** - Consulta con stats
2. **constanciafrm.vue** - Consulta con stats
3. **ConsultaTramitefrm.vue** - Consulta principal
4. **consultaLicenciafrm.vue** - Consulta principal
5. **consultaAnunciofrm.vue** - Consulta principal

---

## 🎯 ESTRUCTURA HTML OBLIGATORIA

### 1. Wrapper Principal (OBLIGATORIO - 3 pts)

```vue
<template>
  <div class="module-view">
    <!-- Todo el contenido -->
  </div>
</template>
```

**Criterios:**
- ✅ Clase `module-view` exacta
- ❌ NO usar otras clases como `page-container`, `empresas-page`, etc.

---

### 2. Header del Módulo (OBLIGATORIO - 2 pts)

```vue
<div class="module-view-header">
  <div class="module-view-icon">
    <font-awesome-icon icon="icono-apropiado" />
  </div>
  <div class="module-view-info">
    <h1>Título del Módulo</h1>
    <p>Descripción breve del propósito</p>
  </div>
  <div class="button-group ms-auto">
    <button class="btn-municipal-success" @click="accionPrincipal">
      <font-awesome-icon icon="plus" />
      Nueva Acción
    </button>
    <button class="btn-municipal-primary" @click="actualizar">
      <font-awesome-icon icon="sync-alt" />
      Actualizar
    </button>
    <button class="btn-municipal-purple" @click="openDocumentation">
      <font-awesome-icon icon="question-circle" />
      Ayuda
    </button>
  </div>
</div>
```

**Criterios:**
- ✅ Tres secciones: icon, info, buttons
- ✅ Botones con clases `btn-municipal-*`
- ✅ Iconos con FontAwesome

---

### 3. Module View Content (OBLIGATORIO - 1 pt)

```vue
<div class="module-view-content">
  <!-- Stats, filtros, tabla, paginación -->
</div>
```

---

### 4. Stats Grid (ALTAMENTE RECOMENDADO - 3 pts)

```vue
<!-- Loading skeleton para estadísticas -->
<div class="stats-grid" v-if="loadingEstadisticas">
  <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
    <div class="stat-content">
      <div class="skeleton-icon"></div>
      <div class="skeleton-number"></div>
      <div class="skeleton-label"></div>
      <div class="skeleton-percentage"></div>
    </div>
  </div>
</div>

<!-- Cards de estadísticas con datos -->
<div class="stats-grid" v-else-if="estadisticas.length > 0">
  <div class="stat-card" v-for="stat in estadisticas" :key="stat.id" :class="`stat-${stat.clase}`">
    <div class="stat-content">
      <div class="stat-icon">
        <font-awesome-icon :icon="getStatIcon(stat)" />
      </div>
      <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
      <p class="stat-label">{{ stat.descripcion }}</p>
      <small class="stat-percentage">{{ stat.porcentaje }}%</small>
    </div>
  </div>
</div>
```

**Criterios:**
- ✅ Skeleton loaders durante carga (2 pts)
- ✅ Cards con stats reales (1 pt)
- ✅ Usa clases `stat-card`, `stat-V`, `stat-C`, etc.

---

### 5. Filtros Colapsables (OBLIGATORIO - 2 pts)

```vue
<div class="municipal-card">
  <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
    <h5>
      <font-awesome-icon icon="filter" />
      Filtros de Búsqueda
      <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
    </h5>
  </div>

  <div v-show="showFilters" class="municipal-card-body">
    <!-- Campos de filtros -->
    <div class="button-group">
      <button class="btn-municipal-primary" @click="buscar">
        <font-awesome-icon icon="search" />
        Buscar
      </button>
      <button class="btn-municipal-secondary" @click="limpiarFiltros">
        <font-awesome-icon icon="times" />
        Limpiar Filtros
      </button>
    </div>
  </div>
</div>
```

**Criterios:**
- ✅ Chevron up/down dinámico (1 pt)
- ✅ Botones de buscar y limpiar (1 pt)

---

### 6. Tabla Municipal (OBLIGATORIO - 2 pts)

```vue
<div class="municipal-card">
  <div class="municipal-card-header">
    <div class="header-with-badge">
      <h5>
        <font-awesome-icon icon="list" />
        Resultados de Búsqueda
      </h5>
      <span class="badge-purple" v-if="totalResultados > 0">
        {{ formatNumber(totalResultados) }} registros totales
      </span>
    </div>
  </div>

  <div class="municipal-card-body table-container">
    <div class="table-responsive">
      <table class="municipal-table">
        <thead class="municipal-table-header">
          <tr>
            <th>Columna 1</th>
            <th>Columna 2</th>
            <!-- ... -->
          </tr>
        </thead>
        <tbody>
          <!-- Estados vacíos diferenciados -->
          <tr v-if="datos.length === 0 && !primeraBusqueda">
            <td colspan="X" class="text-center text-muted">
              <font-awesome-icon icon="search" size="2x" class="empty-icon" />
              <p>Utiliza los filtros para buscar</p>
            </td>
          </tr>
          <tr v-else-if="datos.length === 0">
            <td colspan="X" class="text-center text-muted">
              <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
              <p>No se encontraron resultados</p>
            </td>
          </tr>

          <!-- Datos reales -->
          <tr v-else v-for="item in datos" :key="item.id">
            <td>{{ item.campo }}</td>
            <!-- ... -->
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
```

**Criterios:**
- ✅ Clases `table-responsive` y `municipal-table` (1 pt)
- ✅ Estados vacíos diferenciados (1 pt)

---

### 7. Paginación Completa (OBLIGATORIO - 3 pts)

```vue
<div class="pagination-controls" v-if="totalResultados > itemsPerPage">
  <div class="pagination-info">
    <span class="text-muted">
      Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
      a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
      de {{ totalResultados }} registros
    </span>
  </div>

  <div class="pagination-size">
    <label class="municipal-form-label me-2">Registros por página:</label>
    <select
      class="municipal-form-control form-control-sm"
      v-model="itemsPerPage"
      @change="changePageSize"
      style="width: auto; display: inline-block;"
    >
      <option :value="10">10</option>
      <option :value="20">20</option>
      <option :value="50">50</option>
      <option :value="100">100</option>
    </select>
  </div>

  <div class="pagination-buttons">
    <button
      class="btn-municipal-secondary btn-sm"
      @click="cambiarPagina(1)"
      :disabled="currentPage === 1"
      title="Primera página"
    >
      <font-awesome-icon icon="angle-double-left" />
    </button>

    <button
      class="btn-municipal-secondary btn-sm"
      @click="cambiarPagina(currentPage - 1)"
      :disabled="currentPage === 1"
      title="Página anterior"
    >
      <font-awesome-icon icon="angle-left" />
    </button>

    <button
      v-for="page in visiblePages"
      :key="page"
      class="btn-sm"
      :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
      @click="cambiarPagina(page)"
    >
      {{ page }}
    </button>

    <button
      class="btn-municipal-secondary btn-sm"
      @click="cambiarPagina(currentPage + 1)"
      :disabled="currentPage === totalPages"
      title="Página siguiente"
    >
      <font-awesome-icon icon="angle-right" />
    </button>

    <button
      class="btn-municipal-secondary btn-sm"
      @click="cambiarPagina(totalPages)"
      :disabled="currentPage === totalPages"
      title="Última página"
    >
      <font-awesome-icon icon="angle-double-right" />
    </button>
  </div>
</div>
```

**Criterios:**
- ✅ 3 secciones: info, size, buttons (3 pts)
- ✅ Botones de primera, anterior, páginas, siguiente, última

---

## 💻 SCRIPT SETUP OBLIGATORIO

### 1. Imports Estándar (1 pt)

```javascript
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'
```

---

### 2. Variables de Estado Estándar (2 pts)

```javascript
// UI State
const showFilters = ref(false)  // DEBE iniciar en false
const primeraBusqueda = ref(false)  // OBLIGATORIO
const loadingEstadisticas = ref(true)

// Datos
const datos = ref([])
const estadisticas = ref([])
const totalResultados = ref(0)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)  // DEBE ser 10
```

**Criterios:**
- ✅ showFilters = ref(false) (1 pt)
- ✅ itemsPerPage = ref(10) (1 pt)
- ✅ primeraBusqueda = ref(false)

---

### 3. Funciones Requeridas (2 pts)

```javascript
// Toggle filtros
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Cargar datos
const cargarDatos = async () => {
  showLoading('Cargando...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false  // Cerrar filtros al buscar

  try {
    const params = [
      { nombre: 'p_param1', valor: filtros.value.param1 || null, tipo: 'string' },
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
    ]

    const response = await execute(
      'sp_nombre',
      'modulo',
      params,
      'esquema',
      null,
      'public'
    )

    hideLoading()

    if (response && response.result) {
      datos.value = response.result
      if (datos.value.length > 0) {
        totalResultados.value = parseInt(datos.value[0].total_records) || 0
      } else {
        totalResultados.value = 0
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

// Cargar estadísticas
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(
      'sp_estadisticas',
      'modulo',
      [],
      'esquema',
      null,
      'public'
    )

    if (response && response.result) {
      estadisticas.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar estadísticas:', error)
  } finally {
    loadingEstadisticas.value = false
  }
}

// Cambiar página
const cambiarPagina = (page) => {
  if (page >= 1 && page <= totalPages.value && page !== currentPage.value) {
    currentPage.value = page
    cargarDatos()
  }
}

// Cambiar tamaño de página (OBLIGATORIO)
const changePageSize = () => {
  currentPage.value = 1
  cargarDatos()
}

// Limpiar filtros
const limpiarFiltros = () => {
  // Resetear filtros
  datos.value = []
  primeraBusqueda.value = false
  totalResultados.value = 0
}
```

**Criterios:**
- ✅ changePageSize() existe (2 pts)
- ✅ Función principal de carga cierra filtros

---

### 4. Helper Functions (1 pt)

```javascript
const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch {
    return 'N/A'
  }
}
```

---

### 5. onMounted (CRÍTICO - 2 pts)

```javascript
onMounted(() => {
  cargarEstadisticas()  // SOLO carga estadísticas
  // NO cargar datos automáticamente
  // El usuario debe hacer clic en "Actualizar" o "Buscar"
})
```

**Criterios:**
- ✅ Solo carga estadísticas (2 pts)
- ❌ NO cargar datos completos en onMounted

---

### 6. Computed Properties (1 pt)

```javascript
const totalPages = computed(() =>
  Math.ceil(totalResultados.value / itemsPerPage.value)
)

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})
```

---

## 🎨 CLASES CSS PERMITIDAS

**CRÍTICO:** NO usar `<style scoped>` (3 pts)

### Clases Municipales Estándar

```css
/* Wrappers */
.module-view
.module-view-header
.module-view-content

/* Cards */
.municipal-card
.municipal-card-header
.municipal-card-body

/* Stats */
.stats-grid
.stat-card
.stat-card-loading
.stat-content
.stat-icon
.stat-number
.stat-label
.stat-percentage
.skeleton-icon
.skeleton-number
.skeleton-label
.skeleton-percentage

/* Tablas */
.table-responsive
.municipal-table
.municipal-table-header

/* Botones */
.btn-municipal-primary
.btn-municipal-secondary
.btn-municipal-success
.btn-municipal-danger
.btn-municipal-warning
.btn-municipal-info
.btn-municipal-purple

/* Forms */
.municipal-form-control
.municipal-form-label
.form-row
.form-group

/* Paginación */
.pagination-controls
.pagination-info
.pagination-size
.pagination-buttons

/* Badges */
.badge-purple
.badge-primary
.badge-success
.badge-danger
.badge-warning
.badge-info
.badge-secondary
```

---

## 📊 SISTEMA DE PUNTUACIÓN (30 PUNTOS MÁXIMOS)

### Estructura HTML (12 pts)
1. module-view wrapper (2 pts)
2. module-view-header (2 pts)
3. stats-grid presente (3 pts)
4. stats con skeleton loaders (2 pts)
5. filtros colapsables (2 pts)
6. chevron-up/down en filtros (1 pt)

### Tabla y Datos (5 pts)
7. tabla municipal-table (2 pts)
8. table-responsive (1 pt)
9. estados vacíos diferenciados (2 pts)

### Paginación (5 pts)
10. paginación completa (3 pts)
11. itemsPerPage = ref(10) (2 pts)

### Script Setup (5 pts)
12. showFilters = ref(false) (1 pt)
13. primeraBusqueda = ref(false) (1 pt)
14. cargarEstadisticas() (1 pt)
15. onMounted solo stats (2 pts)

### Funciones (2 pts)
16. changePageSize() (2 pts)

### Helpers y CSS (1 pt)
17. formatNumber() helper (1 pt)

### Sin Style Scoped (3 pts)
18. Sin <style scoped> (3 pts)

---

## 📈 NIVELES DE CUMPLIMIENTO

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 30 | 100% conforme | Gold Standard - Cumple TODOS los criterios |
| 27-29 | 90%+ conforme | Excellent - Solo detalles menores |
| 22-26 | 75%+ conforme | Good - Cumple básicos, mejoras importantes |
| 15-21 | 50%+ conforme | Fair - Estructura parcial, varias brechas |
| <15 | <50% conforme | Poor - No cumple el estándar |

---

## ❌ ANTIPATRONES COMUNES

### 1. NO Usar Wrappers Personalizados
```vue
❌ INCORRECTO:
<div class="page-container">
<div class="empresas-page">
<div class="cons-tipos-aseo-page">

✅ CORRECTO:
<div class="module-view">
```

### 2. NO Usar Style Scoped
```vue
❌ INCORRECTO:
<style scoped>
.custom-class { ... }
</style>

✅ CORRECTO:
(Sin sección <style>, usar clases globales municipales)
```

### 3. NO Cargar Datos en onMounted
```javascript
❌ INCORRECTO:
onMounted(() => {
  cargarDatos()  // NO!
})

✅ CORRECTO:
onMounted(() => {
  cargarEstadisticas()  // Solo stats
})
```

### 4. NO Usar itemsPerPage Diferente de 10
```javascript
❌ INCORRECTO:
const itemsPerPage = ref(20)

✅ CORRECTO:
const itemsPerPage = ref(10)
```

### 5. NO Iniciar Filtros Abiertos
```javascript
❌ INCORRECTO:
const showFilters = ref(true)

✅ CORRECTO:
const showFilters = ref(false)
```

---

## 🎯 CHECKLIST DE VALIDACIÓN

Usar este checklist para validar CADA componente:

- [ ] Wrapper `module-view`
- [ ] Header con `module-view-header`
- [ ] Stats-grid con skeleton loaders
- [ ] Stats-grid con datos reales
- [ ] Filtros en `municipal-card`
- [ ] Chevron up/down dinámico
- [ ] Tabla en `table-responsive` y `municipal-table`
- [ ] Estados vacíos diferenciados (sin búsqueda vs sin resultados)
- [ ] Paginación completa con 3 secciones
- [ ] `showFilters = ref(false)`
- [ ] `itemsPerPage = ref(10)`
- [ ] `primeraBusqueda = ref(false)`
- [ ] Función `cargarEstadisticas()`
- [ ] Función `changePageSize()`
- [ ] `onMounted()` solo carga stats
- [ ] Función `formatNumber()`
- [ ] NO tiene `<style scoped>`
- [ ] Todas las clases son municipales

**Puntuación Total: ___/30 puntos**

---

## 📝 EJEMPLO COMPLETO

Ver `certificacionesfrm.vue` en:
`RefactorX/FrontEnd/src/views/modules/padron_licencias/certificacionesfrm.vue`

Este componente implementa el 100% del patrón estándar y debe ser usado como referencia para TODOS los nuevos componentes.

---

**FIN DEL DOCUMENTO PATRÓN ESTÁNDAR**
