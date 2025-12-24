<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-pie" />
      </div>
      <div class="module-view-info">
        <h1>Reportes y Estadísticas SVN</h1>
        <p>Estacionamiento Exclusivo - Consulta de estadísticas generales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-primary" @click="toggleFilters">
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" />
          Filtros
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas generales -->
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
            <small class="stat-percentage" v-if="Number(stat.porcentaje) > 0">
              {{ Number(stat.porcentaje).toFixed(1) }}%
            </small>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card" v-if="showFilters">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Desde</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="filters.desde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Hasta</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="filters.hasta"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="consultar">
              <font-awesome-icon icon="chart-line" />
              Consultar
            </button>
            <button class="btn-municipal-secondary" @click="clearFilters">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resumen Estadístico
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="rows.length > 0">
              {{ formatNumber(totalResultados) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="rows.length === 0 && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="chart-pie" size="3x" />
            </div>
            <h4>Reportes y Estadísticas SVN</h4>
            <p>Use los filtros para consultar estadísticas del sistema</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="rows.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron registros con los criterios especificados</p>
          </div>

          <!-- Tabla con datos -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ formatLabel(c) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(r, i) in paginatedRows"
                  :key="i"
                  @click="selectedRow = r"
                  :class="{ 'table-row-selected': selectedRow === r }"
                  class="row-hover"
                >
                  <td v-for="c in cols" :key="c">{{ formatValue(r[c]) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
                de {{ formatNumber(totalResultados) }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ApremiosSvnReportes'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Reportes y Estadísticas SVN'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Composables
const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Constantes
const BASE_DB = 'estacionamiento_exclusivo'
const OP_STATS_GENERAL = 'sp_estadisticas_generales'
const OP_STATS = 'apremiossvn_apremios_estadisticas'

// Estado
const filters = ref({
  desde: '',
  hasta: ''
})
const rows = ref([])
const cols = ref([])
const showFilters = ref(true)
const hasSearched = ref(false)
const selectedRow = ref(null)
const loadingEstadisticas = ref(true)
const estadisticas = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(25)

const totalResultados = computed(() => rows.value.length)
const totalPages = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rows.value.slice(start, end)
})

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

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedRow.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Métodos
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(OP_STATS, BASE_DB, [])
    if (response && response.data) {
      estadisticas.value = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      estadisticas.value = Array.isArray(response.result) ? response.result : []
    } else {
      estadisticas.value = []
    }
  } catch (error) {
    handleApiError(error)
    estadisticas.value = []
  } finally {
    loadingEstadisticas.value = false
  }
}

const consultar = async () => {
  showLoading('Consultando estadísticas...', 'Generando reporte')
  hasSearched.value = true
  selectedRow.value = null
  currentPage.value = 1
  const startTime = performance.now()

  try {
    const response = await execute(OP_STATS_GENERAL, BASE_DB, [
      { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
      { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') }
    ])

    let arr = []
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result : []
    }

    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    toast.value.duration = durationText
    showToast('success', `${rows.value.length} registro(s) encontrados`)
  } catch (error) {
    rows.value = []
    cols.value = []
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    desde: '',
    hasta: ''
  }
  rows.value = []
  cols.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

// Utilidades
const formatNumber = (n) => {
  return new Intl.NumberFormat('es-MX').format(n)
}

const formatMoney = (v) => {
  return Number(v || 0).toLocaleString('es-MX', {
    style: 'currency',
    currency: 'MXN'
  })
}

const formatLabel = (k) => {
  return k
    .replace(/_/g, ' ')
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, s => s.toUpperCase())
    .trim()
}

const formatValue = (v) => {
  if (v === null || v === undefined) return '-'
  if (typeof v === 'boolean') return v ? 'Sí' : 'No'
  return String(v)
}

const getStatIcon = (c) => {
  const iconMap = {
    'TOTAL': 'chart-bar',
    'VIGENTES': 'check-circle',
    'VENCIDOS': 'times-circle',
    'CON_EJECUTOR': 'user-check',
    'SIN_EJECUTOR': 'user-times',
    'IMPORTE_TOTAL': 'coins'
  }
  return iconMap[c] || 'info-circle'
}

const getStatValue = (s) => {
  return s.categoria === 'IMPORTE_TOTAL'
    ? formatMoney(s.total)
    : formatNumber(s.total)
}

// Lifecycle
onMounted(() => {
  cargarEstadisticas()
  consultar()
})
</script>


