<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-alt" />
      </div>
      <div class="module-view-info">
        <h1>Notificaciones por Mes</h1>
        <p>Consulta de notificaciones por mes y año</p>
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
        <button
          class="btn-municipal-primary"
          @click="reload"
          v-if="filters.anio && filters.anioPracticado && filters.fechaDesde && filters.fechaHasta"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año Emisión</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.anio"
                placeholder="2025"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año Practicado</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.anioPracticado"
                placeholder="2025"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="filters.fechaDesde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="filters.fechaHasta"
                @keyup.enter="reload"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="reload"
              :disabled="!filters.anio || !filters.anioPracticado || !filters.fechaDesde || !filters.fechaHasta"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados
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
              <font-awesome-icon icon="calendar-alt" size="3x" />
            </div>
            <h4>Notificaciones por Mes</h4>
            <p>Ingrese los filtros y presione Buscar para consultar las notificaciones</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="rows.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron notificaciones con los criterios especificados</p>
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
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
              >
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
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
              >
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
        :componentName="'NotificacionesMes'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Notificaciones por Mes'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref, computed } from 'vue'
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

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'spd_15_notif_mes'

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Variables de estado
const showFilters = ref(true)
const filters = ref({
  mes: '',
  anio: new Date().getFullYear(),
  anioPracticado: new Date().getFullYear(),
  fechaDesde: '',
  fechaHasta: ''
})
const rows = ref([])
const cols = ref([])
const hasSearched = ref(false)
const selectedRow = ref(null)
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed properties
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

// Métodos de paginación
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

// Método principal de búsqueda
const reload = async () => {
  if (!filters.value.anio || !filters.value.anioPracticado || !filters.value.fechaDesde || !filters.value.fechaHasta) {
    showToast('error', 'Debe completar todos los campos')
    return
  }

  showLoading('Consultando notificaciones...', 'Buscando por mes')
  hasSearched.value = true
  selectedRow.value = null
  showFilters.value = false
  currentPage.value = 1

  const t0 = performance.now()

  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_axo_pract', type: 'I', value: Number(filters.value.anioPracticado || new Date().getFullYear()) },
      { name: 'p_axo_emi', type: 'I', value: Number(filters.value.anio || new Date().getFullYear()) },
      { name: 'p_fecha_desde', type: 'D', value: String(filters.value.fechaDesde || '') },
      { name: 'p_fecha_hasta', type: 'D', value: String(filters.value.fechaHasta || '') }
    ])

    let arr = []
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result : []
    }

    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []

    const dur = performance.now() - t0
    const durationText = dur < 1000
      ? `${Math.round(dur)}ms`
      : `${(dur / 1000).toFixed(2)}s`

    toast.value.duration = durationText
    showToast('success', `${rows.value.length} registro(s) encontrados`)
  } catch (e) {
    rows.value = []
    cols.value = []
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Limpiar filtros
const limpiar = () => {
  filters.value = {
    mes: '',
    anio: new Date().getFullYear(),
    anioPracticado: new Date().getFullYear(),
    fechaDesde: '',
    fechaHasta: ''
  }
  rows.value = []
  cols.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

// Toggle filtros
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Utilidades
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n)

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
</script>
