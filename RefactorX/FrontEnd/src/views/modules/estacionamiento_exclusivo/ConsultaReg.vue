<template>
  <div class="module-view module-layout">
    <!-- ========== HEADER ========== -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="magnifying-glass" />
      </div>
      <div class="module-view-info">
        <h1>Consulta por Registro</h1>
        <p>Consulta detallada de apremios por registro</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar" v-if="filters.registro">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- ========== STATS CARDS CON LOADING SKELETON ========== -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
            <div class="skeleton-percentage"></div>
          </div>
        </div>
      </div>

      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.categoria" :class="`stat-${stat.clase}`">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="getStatIcon(stat.categoria)" />
            </div>
            <h3 class="stat-number">{{ getStatValue(stat) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage" v-if="stat.porcentaje > 0">{{ stat.porcentaje.toFixed(1) }}%</small>
          </div>
        </div>
      </div>

      <!-- ========== FILTROS COLAPSABLES ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Criterios de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Registro</label>
              <input
                class="municipal-form-control"
                v-model="filters.registro"
                @keyup.enter="buscar"
                placeholder="Ingrese el registro a consultar"
              />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar" :disabled="!filters.registro">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- ========== RESULTADO DE CONSULTA ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="file-alt" />
              Resultado de Consulta
            </h5>
            <span class="badge-purple" v-if="data && !Array.isArray(data)">
              1 registro encontrado
            </span>
            <span class="badge-purple" v-else-if="data && Array.isArray(data) && data.length > 0">
              {{ data.length }} registros encontrados
            </span>
          </div>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body" v-if="!loading">
          <!-- Estados vacíos diferenciados -->
          <div v-if="!data && !primeraBusqueda" class="empty-state">
            <font-awesome-icon icon="search" size="3x" class="empty-icon" />
            <p>Ingrese un registro para consultar</p>
          </div>

          <div v-else-if="!data || (Array.isArray(data) && data.length === 0)" class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" class="empty-icon" />
            <p>No se encontró información para el registro especificado</p>
          </div>

          <!-- Resultado estructurado -->
          <div v-else>
            <div class="result-tabs">
              <button
                class="tab-button"
                :class="{ active: activeTab === 'structured' }"
                @click="activeTab = 'structured'"
              >
                <font-awesome-icon icon="table" /> Vista Estructurada
              </button>
              <button
                class="tab-button"
                :class="{ active: activeTab === 'json' }"
                @click="activeTab = 'json'"
              >
                <font-awesome-icon icon="code" /> Vista JSON
              </button>
            </div>

            <div v-show="activeTab === 'structured'" class="structured-view">
              <div v-if="!Array.isArray(data)">
                <!-- Mostrar objeto único -->
                <div class="form-row" v-for="(value, key) in data" :key="key">
                  <div class="form-group">
                    <label class="municipal-form-label">{{ formatLabel(key) }}</label>
                    <p>{{ formatValue(value) }}</p>
                  </div>
                </div>
              </div>
              <div v-else>
                <!-- Mostrar array de objetos -->
                <div class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th v-for="col in getColumns(data)" :key="col">{{ formatLabel(col) }}</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="(row, idx) in data" :key="idx">
                        <td v-for="col in getColumns(data)" :key="col">
                          {{ formatValue(row[col]) }}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <div v-show="activeTab === 'json'" class="json-view">
              <pre class="pre-wrap">{{ JSON.stringify(data, null, 2) }}</pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// ========== CONSTANTES ==========
const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'sp_consultareg_mercados'
const OP_STATS = 'apremiossvn_apremios_estadisticas'

// ========== COMPOSABLES ==========
const { loading, execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// ========== ESTADO - FILTROS ==========
const showFilters = ref(true)
const filters = ref({
  registro: ''
})

// ========== ESTADO - DATOS ==========
const data = ref(null)
const primeraBusqueda = ref(false)

// ========== ESTADO - ESTADÍSTICAS ==========
const loadingEstadisticas = ref(true)
const estadisticas = ref([])

// ========== ESTADO - VISTA ==========
const activeTab = ref('structured')

// ========== FUNCIONES - ESTADÍSTICAS ==========
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const result = await execute(OP_STATS, BASE_DB, [])
    const arr = Array.isArray(result?.rows) ? result.rows : Array.isArray(result) ? result : []
    estadisticas.value = arr
  } catch (error) {
    console.error('Error al cargar estadísticas:', error)
    estadisticas.value = []
  } finally {
    loadingEstadisticas.value = false
  }
}

// ========== FUNCIONES - BÚSQUEDA ==========
const buscar = async () => {
  if (!filters.value.registro) {
    showToast('error', 'Debe ingresar un registro para consultar')
    return
  }

  showFilters.value = false
  primeraBusqueda.value = true
  const startTime = performance.now()

  try {
    const result = await execute(OP_QUERY, BASE_DB, [
      { name: 'registro', type: 'C', value: String(filters.value.registro || '') }
    ])

    data.value = result

    // Toast con timing
    const endTime = performance.now()
    const duration = endTime - startTime
    const durationText = duration < 1000
      ? `${Math.round(duration)}ms`
      : `${(duration / 1000).toFixed(2)}s`

    const count = !result ? 0 : Array.isArray(result) ? result.length : 1
    showToast('success', `Consulta completada en ${durationText} - ${count} registro(s)`)
  } catch (error) {
    data.value = null
    handleApiError(error)
  }
}

const limpiarFiltros = () => {
  filters.value = {
    registro: ''
  }
  data.value = null
  primeraBusqueda.value = false
}

// ========== FUNCIONES - FILTROS ==========
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// ========== HELPERS ==========
const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const formatMoney = (value) => {
  return Number(value || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('es-MX').format(date)
}

const formatLabel = (key) => {
  // Convertir snake_case o camelCase a Title Case
  return key
    .replace(/_/g, ' ')
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, str => str.toUpperCase())
    .trim()
}

const formatValue = (value) => {
  if (value === null || value === undefined) return '-'
  if (typeof value === 'boolean') return value ? 'Sí' : 'No'
  if (typeof value === 'object') return JSON.stringify(value)
  return String(value)
}

const getColumns = (arr) => {
  if (!arr || arr.length === 0) return []
  return Object.keys(arr[0])
}

const getStatIcon = (categoria) => {
  const icons = {
    'TOTAL': 'chart-bar',
    'VIGENTES': 'check-circle',
    'VENCIDOS': 'times-circle',
    'CON_EJECUTOR': 'user-check',
    'SIN_EJECUTOR': 'user-times',
    'IMPORTE_TOTAL': 'coins'
  }
  return icons[categoria] || 'info-circle'
}

const getStatValue = (stat) => {
  // Si es IMPORTE_TOTAL, mostrar como dinero
  if (stat.categoria === 'IMPORTE_TOTAL') {
    return formatMoney(stat.total)
  }
  // Si no, mostrar como número
  return formatNumber(stat.total)
}

// ========== LIFECYCLE ==========
onMounted(() => {
  cargarEstadisticas() // SOLO stats, NO datos
  // El usuario debe ingresar un registro y hacer clic en "Buscar"
})
</script>

<style scoped>
.result-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
  border-bottom: 2px solid #dee2e6;
}

.tab-button {
  padding: 0.5rem 1rem;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  color: #6c757d;
  transition: all 0.2s;
}

.tab-button:hover {
  color: #495057;
  border-bottom-color: #dee2e6;
}

.tab-button.active {
  color: #7a5dc7;
  border-bottom-color: #7a5dc7;
  font-weight: 600;
}

.structured-view {
  padding: 1rem 0;
}

.json-view {
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 0.25rem;
}
</style>

<!-- Resto de estilos desde municipal-theme.css -->
