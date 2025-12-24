<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="timeline" />
      </div>
      <div class="module-view-info">
        <h1>Control de Fases</h1>
        <p>Requerimiento → Embargo → Remate → Adjudicación</p>
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
        <button class="btn-municipal-primary" @click="reload">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas -->
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
            <small class="stat-percentage" v-if="Number(stat.porcentaje) > 0">{{ Number(stat.porcentaje).toFixed(1) }}%</small>
          </div>
        </div>
      </div>

      <!-- Formulario de cambio de fase -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="shuffle" />
            Cambiar Fase del Expediente
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Expediente</label>
              <input
                class="municipal-form-control"
                v-model="form.expediente"
                @keyup.enter="cambiarFase"
                placeholder="Ingrese número de expediente"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Fase</label>
              <select class="municipal-form-control" v-model="form.fase">
                <option value="REQUERIMIENTO">REQUERIMIENTO</option>
                <option value="EMBARGO">EMBARGO</option>
                <option value="REMATE">REMATE</option>
                <option value="ADJUDICACION">ADJUDICACIÓN</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!form.expediente || !form.fase"
              @click="cambiarFase"
            >
              <font-awesome-icon icon="shuffle" />
              Cambiar Fase
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de control de fases -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Control de Fases
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
              <font-awesome-icon icon="timeline" size="3x" />
            </div>
            <h4>Control de Fases</h4>
            <p>Haga clic en "Actualizar" para cargar el control de fases de los expedientes</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="rows.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron expedientes con fases registradas</p>
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
        :componentName="'ApremiosSvnFases'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Control de Fases'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed, onMounted } from 'vue'
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
const OP_CAMBIAR_FASE = 'sp_cambiar_fase'
const OP_QUERY = 'sp_fases_list'
const OP_STATS = 'apremiossvn_apremios_estadisticas'

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
const form = ref({ expediente: '', fase: 'REQUERIMIENTO' })
const rows = ref([])
const cols = ref([])
const loadingEstadisticas = ref(true)
const estadisticas = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(25)
const selectedRow = ref(null)
const hasSearched = ref(false)

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
  } catch (e) {
    estadisticas.value = []
  } finally {
    loadingEstadisticas.value = false
  }
}

const reload = async () => {
  showLoading('Cargando control de fases...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null
  currentPage.value = 1
  const t0 = performance.now()
  try {
    const response = await execute(OP_QUERY, BASE_DB, [])
    let arr = []
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result : []
    }
    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    toast.value.duration = txt
    showToast('success', `${rows.value.length} registro(s) encontrados`)
  } catch (e) {
    rows.value = []
    cols.value = []
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

const cambiarFase = async () => {
  if (!form.value.expediente || !form.value.fase) {
    showToast('error', 'Debe ingresar expediente y fase')
    return
  }
  showLoading('Cambiando fase...', 'Actualizando expediente')
  const t0 = performance.now()
  try {
    await execute(OP_CAMBIAR_FASE, BASE_DB, [
      { name: 'expediente', type: 'C', value: String(form.value.expediente || '') },
      { name: 'fase', type: 'C', value: String(form.value.fase || '') }
    ])
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    toast.value.duration = txt
    showToast('success', 'Fase actualizada correctamente')
    form.value.expediente = ''
    reload()
  } catch (e) {
    handleApiError(e)
    hideLoading()
  }
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
  const icons = {
    'TOTAL': 'chart-bar',
    'VIGENTES': 'check-circle',
    'VENCIDOS': 'times-circle',
    'CON_EJECUTOR': 'user-check',
    'SIN_EJECUTOR': 'user-times',
    'IMPORTE_TOTAL': 'coins'
  }
  return icons[c] || 'info-circle'
}

const getStatValue = (s) => {
  return s.categoria === 'IMPORTE_TOTAL'
    ? formatMoney(s.total)
    : formatNumber(s.total)
}

onMounted(() => {
  cargarEstadisticas()
  reload()
})
</script>

