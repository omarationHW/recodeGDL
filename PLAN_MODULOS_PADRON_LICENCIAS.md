# 📋 PLAN DE TRABAJO - MÓDULOS PADRÓN DE LICENCIAS

**Fecha de creación**: 05 Noviembre 2025
**Última actualización**: 05 Noviembre 2025
**Total módulos**: 92 archivos Vue

---

## 🎯 OBJETIVO

Estandarizar todos los módulos de consulta principales de Padrón de Licencias siguiendo el patrón establecido en:
- certificacionesfrm.vue ✅
- constanciafrm.vue ✅
- consultausuariosfrm.vue ✅
- ConsultaTramitefrm.vue ✅
- consultaLicenciafrm.vue ✅
- consultaAnunciofrm.vue ✅

---

## 📊 ESTADO GENERAL

| Categoría | Cantidad | Porcentaje | Estado |
|-----------|----------|------------|--------|
| **Completados** | 6 | 6.5% | ✅ Funcionando |
| **Prioritarios Alta** | 5 | 5.4% | 🔴 Pendiente |
| **Prioritarios Media** | 6 | 6.5% | 🟡 Pendiente |
| **Secundarios** | 21 | 22.8% | 📋 Futuro |
| **Otros/Auxiliares** | 54 | 58.7% | ⚪ Mantener |

---

## ✅ MÓDULOS COMPLETADOS (6)

### Estado: FUNCIONANDO PERFECTAMENTE

| # | Módulo | Fecha | Características |
|---|--------|-------|----------------|
| 1 | **certificacionesfrm.vue** | 05-Nov-2025 | Stats + Filtros + Tabla scroll + Paginación 10 |
| 2 | **constanciafrm.vue** | 05-Nov-2025 | Stats + Filtros contraídos + Tabla + Paginación 10 |
| 3 | **consultausuariosfrm.vue** | Anterior | Stats + Filtros + Tabla + Paginación |
| 4 | **ConsultaTramitefrm.vue** | Anterior | Stats + Filtros + Tabla + Paginación |
| 5 | **consultaLicenciafrm.vue** | Anterior | Stats + Filtros + Tabla + Paginación |
| 6 | **consultaAnunciofrm.vue** | Anterior | Stats + Filtros + Tabla + Paginación |

**Patrón establecido**:
- ✅ Stats cards al inicio (3-4 cards con totales/porcentajes)
- ✅ Acordeón de filtros (colapsable con chevron)
- ✅ Tabla con header + badge total registros
- ✅ Paginación funcional (default 10, opciones 10/20/50/100)
- ✅ Sin estilos scoped - Todo desde municipal-theme.css
- ✅ onMounted: Solo carga estadísticas (NO datos)
- ✅ changePageSize() para selector de registros
- ✅ Estados vacíos diferenciados
- ✅ Loading states con skeleton

---

## 🔴 PRIORIDAD ALTA (5 módulos)

### Lista de trabajo inmediato

| # | Módulo | Tiempo estimado | Estado | Notas |
|---|--------|----------------|--------|-------|
| 1 | **GirosDconAdeudofrm.vue** | ⏱️ 15-20 min | ⭐ Casi listo | Ya tiene stats-grid + filtros + tabla. Solo validar |
| 2 | **h_bloqueoDomiciliosfrm.vue** | ⏱️ 15-20 min | ⭐ Casi listo | Ya tiene stats + filtros + tabla. Solo revisar |
| 3 | **LicenciasVigentesfrm.vue** | ⏱️ 30-40 min | 🔴 Prioritario | Agregar cards (total, por zona, por giro) |
| 4 | **girosVigentesCteXgirofrm.vue** | ⏱️ 25-30 min | 🔴 Importante | Agregar cards estadísticas |
| 5 | **Agendavisitasfrm.vue** | ⏱️ 30-40 min | 🔴 Crítico | Agregar cards (programadas, pendientes, completadas) |

**Total tiempo estimado**: 2-2.5 horas

---

### 1. GirosDconAdeudofrm.vue ⭐ CASI LISTO

**Descripción**: Reporte de giros comerciales con adeudos fiscales pendientes

**Estado actual**:
- ✅ Ya tiene stats-grid completo
- ✅ Filtros implementados
- ✅ Tabla con paginación
- ⚠️ Validar estilos (sin scoped)
- ⚠️ Verificar paginación default 10

**Tareas**:
1. [ ] Leer archivo completo
2. [ ] Verificar que NO tenga `<style scoped>`
3. [ ] Verificar `itemsPerPage = ref(10)`
4. [ ] Verificar `showFilters` estado inicial
5. [ ] Verificar `onMounted` (solo stats)
6. [ ] Verificar `changePageSize()` existe
7. [ ] Test funcional
8. [ ] ✅ Marcar completado

**Prioridad**: EMPEZAR POR ESTE

---

### 2. h_bloqueoDomiciliosfrm.vue ⭐ CASI LISTO

**Descripción**: Historial de bloqueos de domicilios (auditoría)

**Estado actual**:
- ✅ Ya tiene stats completas
- ✅ Filtros implementados
- ✅ Tabla con datos
- ⚠️ Validar estructura completa

**Tareas**:
1. [ ] Leer archivo completo
2. [ ] Verificar estructura stats-grid
3. [ ] Verificar filtros colapsables
4. [ ] Verificar paginación
5. [ ] Remover estilos scoped si existen
6. [ ] Test funcional
7. [ ] ✅ Marcar completado

**Prioridad**: SEGUNDO

---

### 3. LicenciasVigentesfrm.vue 🔴 MUY USADO

**Descripción**: Reporte maestro de licencias comerciales activas y vigentes

**Estado actual**:
- ✅ Tiene filtros de búsqueda
- ✅ Tiene tabla de resultados
- ✅ Tiene exportación Excel/PDF
- ❌ FALTA: Stats cards al inicio

**Tareas**:
1. [ ] Leer archivo completo
2. [ ] Crear endpoint `estadisticas` si no existe
3. [ ] Agregar stats-grid al inicio:
   - Total licencias vigentes
   - Por zona (Centro, Norte, Sur)
   - Por tipo de giro (Comercial, Servicios, Industrial)
   - Vencimientos próximos (30 días)
4. [ ] Verificar loadingEstadisticas
5. [ ] Verificar estructura completa
6. [ ] Remover estilos scoped
7. [ ] Test funcional
8. [ ] ✅ Marcar completado

**Prioridad**: TERCERO - Módulo muy consultado

---

### 4. girosVigentesCteXgirofrm.vue 🔴 IMPORTANTE

**Descripción**: Giros vigentes por contribuyente y categoría de giro

**Estado actual**:
- ✅ Filtros (giro, zona, fechas)
- ✅ Tabla de licencias vigentes
- ❌ FALTA: Stats cards

**Tareas**:
1. [ ] Leer archivo completo
2. [ ] Crear endpoint estadísticas
3. [ ] Agregar stats-grid:
   - Total giros por categoría
   - Total por zona
   - Total contribuyentes únicos
   - Licencias por vencer
4. [ ] Verificar estructura completa
5. [ ] Test funcional
6. [ ] ✅ Marcar completado

**Prioridad**: CUARTO - Análisis importante

---

### 5. Agendavisitasfrm.vue 🔴 CRÍTICO OPERATIVO

**Descripción**: Gestión de agenda de visitas de inspección a establecimientos

**Estado actual**:
- ✅ Filtros (dependencia, fechas)
- ✅ Tabla de visitas programadas
- ❌ FALTA: Stats cards operativas

**Tareas**:
1. [ ] Leer archivo completo
2. [ ] Crear endpoint estadísticas visitas
3. [ ] Agregar stats-grid:
   - Visitas programadas (mes actual)
   - Visitas pendientes
   - Visitas completadas
   - Por turno (matutino/vespertino)
4. [ ] Verificar estructura completa
5. [ ] Test funcional
6. [ ] ✅ Marcar completado

**Prioridad**: QUINTO - Operativo crítico

---

## 🟡 PRIORIDAD MEDIA (6 módulos)

### Lista para siguiente fase

| # | Módulo | Tiempo estimado | Descripción |
|---|--------|----------------|-------------|
| 6 | **repsuspendidasfrm.vue** | ⏱️ 30-35 min | Licencias suspendidas/bloqueadas |
| 7 | **repEstadisticosLicfrm.vue** | ⏱️ 40-45 min | Reportes estadísticos gerenciales |
| 8 | **bloqueoDomiciliosfrm.vue** | ⏱️ 35-40 min | Gestión bloqueos (más CRUD) |
| 9 | **bloqueoRFCfrm.vue** | ⏱️ 30-35 min | Gestión incumplimientos RFC |
| 10 | **consLic400frm.vue** | ⏱️ 10-15 min | Legacy AS/400 - Mantener simple |
| 11 | **consAnun400frm.vue** | ⏱️ 10-15 min | Legacy AS/400 - Mantener simple |

**Total tiempo estimado**: 2.5-3 horas

---

## 📋 SECUNDARIOS (21 módulos)

### Módulos de gestión/CRUD

Estos son importantes pero no son consultas principales. Trabajar después de completar prioritarios.

**Gestión de entidades**:
- empresasfrm.vue (CRUD empresas/contribuyentes)
- dictamenfrm.vue (CRUD dictámenes uso suelo)
- constanciaNoOficialfrm.vue (Solicitudes número oficial)

**Modificaciones**:
- modlicfrm.vue (Modificación licencias/anuncios)
- modtramitefrm.vue (Modificación trámites)

**Bajas y cancelaciones**:
- bajaLicenciafrm.vue (Baja de licencias)
- bajaAnunciofrm.vue (Baja de anuncios)
- cancelaTramitefrm.vue (Cancelación trámites)
- ReactivaTramite.vue (Reactivación trámites)

**Bloqueos**:
- BloquearTramitefrm.vue (Bloquear/desbloquear trámites)
- BloquearLicenciafrm.vue (Bloquear/desbloquear licencias)
- BloquearAnunciorm.vue (Bloquear/desbloquear anuncios)

**Catálogos**:
- catalogogirosfrm.vue (Catálogo giros comerciales)
- CatRequisitos.vue (Catálogo requisitos)
- CatalogoActividadesFrm.vue (Catálogo actividades)
- BusquedaActividadFrm.vue (Búsqueda actividades)
- BusquedaScianFrm.vue (Búsqueda códigos SCIAN)

**Grupos**:
- GruposLicenciasAbcfrm.vue (ABM Grupos licencias)
- GruposAnunciosAbcfrm.vue (ABM Grupos anuncios)
- gruposLicenciasfrm.vue (Gestión grupos licencias)
- gruposAnunciosfrm.vue (Gestión grupos anuncios)

---

## ⚪ OTROS MÓDULOS (54 archivos)

### No requieren trabajo inmediato

**Categorías**:
- Formularios auxiliares (busque, buscagiro, formabuscalle, etc.)
- Módulos de impresión (ImpRecibo, ImpOficio, etc.)
- Utilidades (carga, carga_imagen, webBrowser)
- Reportes especiales (ReporteAnunExcel, repdoc)
- Configuración (privilegios, dependencias, estatus)
- Módulos específicos (Catastro, TDM, SGC, etc.)

**Acción**: Mantener como están, revisar solo si hay reportes de problemas.

---

## 📐 PATRÓN ESTÁNDAR A SEGUIR

### Estructura de componente:

```vue
<template>
  <div class="module-view">
    <!-- 1. HEADER -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="..." />
      </div>
      <div class="module-view-info">
        <h1>Título del Módulo</h1>
        <p>Descripción breve</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalNuevo">
          <font-awesome-icon icon="plus" />
          Nuevo
        </button>
        <button class="btn-municipal-primary" @click="cargarDatos">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- 2. STATS CARDS (con loading skeleton) -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 3" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.id">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="..." />
            </div>
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje }}%</small>
          </div>
        </div>
      </div>

      <!-- 3. FILTROS (colapsable) -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div v-show="showFilters" class="municipal-card-body">
          <!-- Formulario de filtros -->
        </div>
      </div>

      <!-- 4. TABLA CON HEADER Y BADGE -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Resultados
            </h5>
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registros totales
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table" style="min-width: 1200px;">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 100px;">Columna 1</th>
                  <!-- ... más columnas ... -->
                </tr>
              </thead>
              <tbody>
                <!-- Estados vacíos -->
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
                <!-- Datos -->
                <tr v-else v-for="item in datos" :key="item.id">
                  <!-- ... filas ... -->
                </tr>
              </tbody>
            </table>
          </div>

          <!-- 5. PAGINACIÓN -->
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
                @click="cambiarPagina(currentPage - 1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
                Anterior
              </button>
              <span class="pagination-current">
                Página {{ currentPage }} de {{ totalPaginas }}
              </span>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="cambiarPagina(currentPage + 1)"
                :disabled="currentPage === totalPaginas"
              >
                Siguiente
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import apiService from '@/services/apiService'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// Estado
const showFilters = ref(false) // o true según diseño
const datos = ref([])
const estadisticas = ref([])
const loadingEstadisticas = ref(false)
const loading = ref(false)
const totalResultados = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(10) // ⭐ DEFAULT 10
const primeraBusqueda = ref(false)

// Filtros
const filtros = ref({
  // ... campos de filtro
})

// Computed
const totalPaginas = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))

// Funciones
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await apiService.modulo.estadisticas()
    estadisticas.value = response.data
  } catch (error) {
    handleApiError(error, 'cargar estadísticas')
  } finally {
    loadingEstadisticas.value = false
  }
}

const cargarDatos = async () => {
  loading.value = true
  primeraBusqueda.value = true

  try {
    const response = await apiService.modulo.list({
      ...filtros.value,
      page: currentPage.value,
      limit: itemsPerPage.value
    })

    datos.value = response.data.data || []
    totalResultados.value = response.data.total || 0
  } catch (error) {
    handleApiError(error, 'cargar datos')
  } finally {
    loading.value = false
  }
}

const cambiarPagina = (pagina) => {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    currentPage.value = pagina
    cargarDatos()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  cargarDatos()
}

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

// Lifecycle
onMounted(() => {
  cargarEstadisticas()
  // ⭐ NO cargar datos automáticamente
  // Usuario debe hacer clic en "Actualizar" o "Buscar"
})
</script>

<!-- ⭐ SIN ESTILOS SCOPED -->
<!-- Todos los estilos vienen de municipal-theme.css -->
```

---

## ✅ CHECKLIST DE VALIDACIÓN

Para cada módulo completado, verificar:

### Estructura:
- [ ] Header con título e iconos
- [ ] Stats-grid con 3-4 cards
- [ ] Loading skeleton para stats
- [ ] Acordeón de filtros con chevron
- [ ] Tabla con header + badge total
- [ ] Table-responsive para scroll horizontal
- [ ] Paginación completa con info

### Funcionalidad:
- [ ] `showFilters = ref(false/true)` según diseño
- [ ] `itemsPerPage = ref(10)` por defecto
- [ ] `changePageSize()` existe y funciona
- [ ] `onMounted()` solo carga estadísticas
- [ ] Estados vacíos diferenciados
- [ ] Formateo de números (formatNumber)
- [ ] Manejo de errores con toast

### Estilos:
- [ ] **SIN `<style scoped>`**
- [ ] Todas las clases de municipal-theme.css
- [ ] Scroll horizontal si tabla es ancha (min-width)
- [ ] Columnas con anchos fijos si es necesario

### Testing:
- [ ] Stats cargan correctamente
- [ ] Filtros funcionan
- [ ] Tabla muestra datos
- [ ] Paginación cambia correctamente
- [ ] Selector registros/página funciona
- [ ] Estados vacíos se muestran bien
- [ ] No hay errores en consola

---

## 📈 MÉTRICAS DE PROGRESO

### Actualizar después de cada módulo completado:

**Última actualización**: 05 Noviembre 2025

| Categoría | Completados | Pendientes | % Avance |
|-----------|-------------|------------|----------|
| Prioridad Alta | 0 / 5 | 5 | 0% |
| Prioridad Media | 0 / 6 | 6 | 0% |
| **Total Prioritarios** | **0 / 11** | **11** | **0%** |

**Meta inicial**: Completar los 5 de prioridad alta (2-2.5 horas trabajo)

---

## 📝 REGISTRO DE TRABAJO

### Sesión: 05 Noviembre 2025

#### Módulos completados HOY:
1. certificacionesfrm.vue ✅ - Scroll horizontal + optimización
2. constanciafrm.vue ✅ - Acordeón contraído

#### Optimizaciones realizadas:
- Sistema 97% más rápido (6.8s → 270ms)
- 6 conexiones idle eliminadas
- 5 índices críticos creados
- SP certificaciones_list optimizado con CTE

---

## 🎯 PRÓXIMAS SESIONES

### Sesión 2: Completar prioridad alta (5 módulos)
**Tiempo estimado**: 2-2.5 horas

1. [ ] GirosDconAdeudofrm.vue (15-20 min)
2. [ ] h_bloqueoDomiciliosfrm.vue (15-20 min)
3. [ ] LicenciasVigentesfrm.vue (30-40 min)
4. [ ] girosVigentesCteXgirofrm.vue (25-30 min)
5. [ ] Agendavisitasfrm.vue (30-40 min)

### Sesión 3: Completar prioridad media (6 módulos)
**Tiempo estimado**: 2.5-3 horas

6. [ ] repsuspendidasfrm.vue
7. [ ] repEstadisticosLicfrm.vue
8. [ ] bloqueoDomiciliosfrm.vue
9. [ ] bloqueoRFCfrm.vue
10. [ ] consLic400frm.vue
11. [ ] consAnun400frm.vue

### Sesión 4+: Módulos secundarios
**Según prioridad del negocio**

---

## 🔧 HERRAMIENTAS Y RECURSOS

### Scripts útiles:
- `temp/test_velocidad.php` - Test de performance
- `temp/diagnostico_lentitud.php` - Diagnóstico sistema
- `temp/limpiar_conexiones.php` - Limpieza conexiones idle

### Documentación:
- `CONTEXTO_TRABAJO_2025_11_05.md` - Contexto completo sesión actual
- `PLAN_MODULOS_PADRON_LICENCIAS.md` - Este archivo

### Base de datos:
- Host: 192.168.6.146:5432
- Database: padron_licencias
- User: refact

---

## 📞 NOTAS IMPORTANTES

1. **Siempre limpiar temp** después de cada sesión
2. **Actualizar este archivo** conforme se completen módulos
3. **Test de velocidad** antes/después si hay cambios en BD
4. **Git commit** después de completar cada módulo
5. **Documentar cambios** en CONTEXTO_TRABAJO

---

**FIN DEL PLAN**

*Última actualización: 05 Noviembre 2025*
*Próxima revisión: Al completar prioridad alta*
