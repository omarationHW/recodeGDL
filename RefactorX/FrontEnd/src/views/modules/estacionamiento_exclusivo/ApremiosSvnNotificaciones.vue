<template>
  <div class="module-view module-layout">
    <!-- ========== HEADER ========== -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bell" />
      </div>
      <div class="module-view-info">
        <h1>Notificaciones SVN</h1>
        <p>Gestión de notificaciones de cobranza coactiva</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="reload">
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
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje.toFixed(1) }}%</small>
          </div>
        </div>
      </div>

      <!-- ========== FILTROS COLAPSABLES ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="buscar"
                placeholder="Expediente, contribuyente, notificador"
              />
            </div>
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
            <div class="form-group">
              <label class="municipal-form-label">Estado</label>
              <select class="municipal-form-control" v-model="filters.estado">
                <option value="">Todos</option>
                <option value="PENDIENTE">Pendiente</option>
                <option value="REALIZADA">Realizada</option>
                <option value="CANCELADA">Cancelada</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar">
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

      <!-- ========== TABLA CON BADGE PÚRPURA ========== -->
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
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <!-- Estados vacíos diferenciados -->
          <div v-if="rows.length === 0 && !primeraBusqueda" class="empty-state">
            <font-awesome-icon icon="search" size="3x" class="empty-icon" />
            <p>Utiliza los filtros de búsqueda para encontrar notificaciones</p>
          </div>

          <div v-else-if="rows.length === 0" class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" class="empty-icon" />
            <p>No se encontraron notificaciones con los criterios especificados</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Expediente</th>
                  <th>Contribuyente</th>
                  <th>Tipo</th>
                  <th>Fecha Programada</th>
                  <th>Fecha Realizada</th>
                  <th>Estado</th>
                  <th>Notificador</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="clickable-row">
                  <td><strong>{{ r.numero_expediente }}</strong></td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.tipo_notificacion }}</td>
                  <td>{{ formatDate(r.fecha_programada) }}</td>
                  <td>{{ formatDate(r.fecha_realizada) }}</td>
                  <td>
                    <span class="badge" :class="getEstadoBadgeClass(r.estado)">
                      {{ r.estado }}
                    </span>
                  </td>
                  <td>{{ r.notificador || '-' }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="openDetail(r)" title="Ver detalle">
                        <font-awesome-icon icon="eye" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- ========== PAGINACIÓN COMPLETA ========== -->
          <div v-if="rows.length > 0" class="pagination-controls">
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
              >
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
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
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- ========== MODAL DE DETALLE ========== -->
      <Modal :show="showDetail" title="Detalle de notificación" @close="showDetail=false" :showDefaultFooter="true">
        <div v-if="selected">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Expediente</label>
              <p><strong>{{ selected.numero_expediente }}</strong></p>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Contribuyente</label>
              <p>{{ selected.contribuyente }}</p>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo</label>
              <p>{{ selected.tipo_notificacion }}</p>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Estado</label>
              <p><span class="badge" :class="getEstadoBadgeClass(selected.estado)">{{ selected.estado }}</span></p>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Descripción</label>
              <p>{{ selected.descripcion || '-' }}</p>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Dirección</label>
              <p>{{ selected.direccion_notificacion || '-' }}</p>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Observaciones</label>
              <p>{{ selected.observaciones || '-' }}</p>
            </div>
          </div>
        </div>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'

// ========== CONSTANTES ==========
const BASE_DB = 'estacionamiento_exclusivo'
const OP_LIST = 'APREMIOSSVN_NOTIFICACIONES_LIST'
const OP_STATS = 'APREMIOSSVN_NOTIFICACIONES_ESTADISTICAS'

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
const showFilters = ref(false)
const filters = ref({
  q: '',
  desde: '',
  hasta: '',
  estado: ''
})

// ========== ESTADO - DATOS ==========
const rows = ref([])
const totalResultados = ref(0)
const primeraBusqueda = ref(false)

// ========== ESTADO - ESTADÍSTICAS ==========
const loadingEstadisticas = ref(true)
const estadisticas = ref([])

// ========== ESTADO - PAGINACIÓN ==========
const currentPage = ref(1)
const itemsPerPage = ref(10)

// ========== ESTADO - MODAL ==========
const showDetail = ref(false)
const selected = ref(null)

// ========== COMPUTED ==========
const totalPages = computed(() => {
  return Math.ceil(totalResultados.value / itemsPerPage.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// ========== FUNCIONES - ESTADÍSTICAS ==========
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const data = await execute(OP_STATS, BASE_DB, [])
    const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    estadisticas.value = arr
  } catch (error) {
    console.error('Error al cargar estadísticas:', error)
    estadisticas.value = []
  } finally {
    loadingEstadisticas.value = false
  }
}

// ========== FUNCIONES - BÚSQUEDA ==========
const reload = async () => {
  const startTime = performance.now()
  const params = [
    { name: 'q', type: 'C', value: String(filters.value.q || '') },
    { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
    { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') },
    { name: 'estado', type: 'C', value: String(filters.value.estado || '') },
    { name: 'offset', type: 'I', value: (currentPage.value - 1) * itemsPerPage.value },
    { name: 'limit', type: 'I', value: itemsPerPage.value }
  ]

  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    rows.value = arr
    totalResultados.value = Number(data?.total ?? arr.length)

    // Toast con timing
    const endTime = performance.now()
    const duration = endTime - startTime
    const durationText = duration < 1000
      ? `${Math.round(duration)}ms`
      : `${(duration / 1000).toFixed(2)}s`

    showToast('success', `Se encontraron ${totalResultados.value} notificación(es) en ${durationText}`)
  } catch (error) {
    rows.value = []
    totalResultados.value = 0
    handleApiError(error)
  }
}

const buscar = async () => {
  showFilters.value = false // Contraer filtros al buscar
  primeraBusqueda.value = true
  currentPage.value = 1 // Reset a página 1
  await reload()
}

const limpiarFiltros = () => {
  filters.value = {
    q: '',
    desde: '',
    hasta: '',
    estado: ''
  }
  currentPage.value = 1
}

// ========== FUNCIONES - PAGINACIÓN ==========
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    reload()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  reload()
}

// ========== FUNCIONES - FILTROS ==========
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// ========== FUNCIONES - MODAL ==========
const openDetail = (r) => {
  selected.value = r
  showDetail.value = true
}

// ========== HELPERS ==========
const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('es-MX').format(date)
}

const getStatIcon = (categoria) => {
  const icons = {
    'TOTAL': 'chart-bar',
    'PENDIENTES': 'clock',
    'REALIZADAS': 'check-circle',
    'CANCELADAS': 'times-circle',
    'POSITIVAS': 'thumbs-up',
    'NEGATIVAS': 'thumbs-down'
  }
  return icons[categoria] || 'info-circle'
}

const getEstadoBadgeClass = (estado) => {
  const classes = {
    'PENDIENTE': 'badge-warning',
    'REALIZADA': 'badge-success',
    'CANCELADA': 'badge-danger'
  }
  return classes[estado] || 'badge-secondary'
}

// ========== LIFECYCLE ==========
onMounted(() => {
  cargarEstadisticas() // SOLO stats, NO datos
  // El usuario debe hacer clic en "Buscar" para cargar datos
})
</script>

<!-- Sin estilos scoped - Todo desde municipal-theme.css -->
