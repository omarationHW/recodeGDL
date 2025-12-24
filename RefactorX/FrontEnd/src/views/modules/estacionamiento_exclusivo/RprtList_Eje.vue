<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Listado Ejecutores</h1>
        <p>Listado completo de ejecutores</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="showFilters = !showFilters">
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" />
          {{ showFilters ? 'Ocultar' : 'Mostrar' }} Filtros
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div v-if="showFilters" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Varios</label>
              <input
                class="municipal-form-control"
                type="text"
                v-model="varios"
                placeholder="Varios"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigencia</label>
              <input
                class="municipal-form-control"
                type="text"
                v-model="vvig"
                placeholder="Vigencia"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input
                class="municipal-form-control"
                type="text"
                v-model="vrec"
                placeholder="Recaudadora"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Opción</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model="vopc"
                placeholder="Opción"
              />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha 1</label>
              <input class="municipal-form-control" type="date" v-model="vfec1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha 2</label>
              <input class="municipal-form-control" type="date" v-model="vfec2" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora ID</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model="vrecaudadora"
                placeholder="ID Recaudadora"
              />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Pago 1</label>
              <input class="municipal-form-control" type="date" v-model="vfecP1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Pago 2</label>
              <input class="municipal-form-control" type="date" v-model="vfecP2" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nombre</label>
              <input
                class="municipal-form-control"
                type="text"
                v-model="vnombre"
                placeholder="Nombre"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar">
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
            Listado
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
              <font-awesome-icon icon="file-alt" size="3x" />
            </div>
            <h4>Reporte Listado Ejecutores</h4>
            <p>Use los filtros para buscar ejecutores</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="rows.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron resultados con los criterios especificados</p>
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
        :componentName="'RprtList_Eje'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Reporte Listado Ejecutores'"
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

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'rprtlist_eje_report'

// Estado
const rows = ref([])
const cols = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(25)
const showFilters = ref(true)
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros
const varios = ref('')
const vvig = ref('')
const vrec = ref('')
const vopc = ref('')
const vfec1 = ref('')
const vfec2 = ref('')
const vrecaudadora = ref('')
const vfecP1 = ref('')
const vfecP2 = ref('')
const vnombre = ref('')

// Computed
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

// Métodos de búsqueda
const buscar = async () => {
  showLoading('Generando reporte...', 'Listado de ejecutores')
  hasSearched.value = true
  selectedRow.value = null
  currentPage.value = 1
  const startTime = performance.now()

  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'varios', type: 'S', value: String(varios.value || '') },
      { name: 'vvig', type: 'S', value: String(vvig.value || '') },
      { name: 'vrec', type: 'S', value: String(vrec.value || '') },
      { name: 'vopc', type: 'I', value: String(vopc.value || '') },
      { name: 'vfec1', type: 'D', value: String(vfec1.value || '') },
      { name: 'vfec2', type: 'D', value: String(vfec2.value || '') },
      { name: 'vrecaudadora', type: 'I', value: String(vrecaudadora.value || '') },
      { name: 'vfecP1', type: 'D', value: String(vfecP1.value || '') },
      { name: 'vfecP2', type: 'D', value: String(vfecP2.value || '') },
      { name: 'vnombre', type: 'S', value: String(vnombre.value || '') }
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
    const duration = endTime - startTime
    const durationText = duration < 1000
      ? `${Math.round(duration)}ms`
      : `${(duration / 1000).toFixed(2)}s`

    toast.value.duration = durationText
    showToast('success', `${rows.value.length} ejecutor(es) encontrados`)
  } catch (error) {
    rows.value = []
    cols.value = []
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  varios.value = ''
  vvig.value = ''
  vrec.value = ''
  vopc.value = ''
  vfec1.value = ''
  vfec2.value = ''
  vrecaudadora.value = ''
  vfecP1.value = ''
  vfecP2.value = ''
  vnombre.value = ''
  rows.value = []
  cols.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

// Utilidades
const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const formatLabel = (key) => {
  return key
    .replace(/_/g, ' ')
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, s => s.toUpperCase())
    .trim()
}

const formatValue = (value) => {
  if (value === null || value === undefined) return '-'
  if (typeof value === 'boolean') return value ? 'Sí' : 'No'
  return String(value)
}
</script>

