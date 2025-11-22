<template>
  <div class="module-view module-layout">
    <!-- ========== HEADER ========== -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill-wave" />
      </div>
      <div class="module-view-info">
        <h1>Pagos SVN</h1>
        <p>Registro y control de pagos de cobranza coactiva</p>
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
            <h3 class="stat-number">{{ getStatValue(stat) }}</h3>
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
              <label class="municipal-form-label">Expediente</label>
              <input
                class="municipal-form-control"
                v-model="filters.expediente"
                @keyup.enter="buscar"
                placeholder="Número de expediente"
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
              <label class="municipal-form-label">Forma de Pago</label>
              <select class="municipal-form-control" v-model="filters.forma_pago">
                <option value="">Todas</option>
                <option value="EFECTIVO">Efectivo</option>
                <option value="CHEQUE">Cheque</option>
                <option value="TRANSFERENCIA">Transferencia</option>
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
            <p>Utiliza los filtros de búsqueda para encontrar pagos</p>
          </div>

          <div v-else-if="rows.length === 0" class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" class="empty-icon" />
            <p>No se encontraron pagos con los criterios especificados</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Expediente</th>
                  <th>Recibo</th>
                  <th>Fecha</th>
                  <th>Forma Pago</th>
                  <th class="text-end">Capital</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Gastos</th>
                  <th class="text-end">Total</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="clickable-row">
                  <td><strong>{{ r.numero_expediente }}</strong></td>
                  <td><code>{{ r.numero_recibo }}</code></td>
                  <td>{{ formatDate(r.fecha_pago) }}</td>
                  <td>
                    <span class="badge" :class="getFormaPagoBadgeClass(r.forma_pago)">
                      {{ r.forma_pago }}
                    </span>
                  </td>
                  <td class="text-end">{{ formatMoney(r.monto_capital) }}</td>
                  <td class="text-end">{{ formatMoney(r.monto_recargos) }}</td>
                  <td class="text-end">{{ formatMoney(r.monto_gastos) }}</td>
                  <td class="text-end"><strong>{{ formatMoney(r.monto_pago) }}</strong></td>
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
      <Modal :show="showDetail" title="Detalle de pago" @close="showDetail=false" :showDefaultFooter="true">
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
              <label class="municipal-form-label">Recibo</label>
              <p><code>{{ selected.numero_recibo }}</code></p>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha</label>
              <p>{{ formatDate(selected.fecha_pago) }}</p>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Forma de Pago</label>
              <p><span class="badge" :class="getFormaPagoBadgeClass(selected.forma_pago)">{{ selected.forma_pago }}</span></p>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Estado</label>
              <p><span class="badge badge-success">{{ selected.estado_pago }}</span></p>
            </div>
          </div>
          <hr />
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Capital</label>
              <p><strong>{{ formatMoney(selected.monto_capital) }}</strong></p>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recargos</label>
              <p><strong>{{ formatMoney(selected.monto_recargos) }}</strong></p>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Gastos</label>
              <p><strong>{{ formatMoney(selected.monto_gastos) }}</strong></p>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Total</label>
              <p class="text-success"><strong class="text-larger">{{ formatMoney(selected.monto_pago) }}</strong></p>
            </div>
          </div>
          <div class="form-row" v-if="selected.observaciones">
            <div class="form-group">
              <label class="municipal-form-label">Observaciones</label>
              <p>{{ selected.observaciones }}</p>
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
const OP_LIST = 'APREMIOSSVN_PAGOS_LIST'
const OP_STATS = 'APREMIOSSVN_PAGOS_ESTADISTICAS'

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
  expediente: '',
  desde: '',
  hasta: '',
  forma_pago: ''
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
    { name: 'expediente', type: 'C', value: String(filters.value.expediente || '') },
    { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
    { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') },
    { name: 'forma_pago', type: 'C', value: String(filters.value.forma_pago || '') },
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

    showToast('success', `Se encontraron ${totalResultados.value} pago(s) en ${durationText}`)
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
    expediente: '',
    desde: '',
    hasta: '',
    forma_pago: ''
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

const formatMoney = (value) => {
  return Number(value || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('es-MX').format(date)
}

const getStatIcon = (categoria) => {
  const icons = {
    'TOTAL': 'chart-bar',
    'EFECTIVO': 'money-bill',
    'CHEQUE': 'money-check',
    'TRANSFERENCIA': 'exchange-alt',
    'CAPITAL': 'coins',
    'RECARGOS': 'percentage'
  }
  return icons[categoria] || 'info-circle'
}

const getStatValue = (stat) => {
  // Si es CAPITAL o RECARGOS, mostrar como dinero
  if (stat.categoria === 'CAPITAL' || stat.categoria === 'RECARGOS') {
    return formatMoney(stat.total)
  }
  // Si no, mostrar como número
  return formatNumber(stat.total)
}

const getFormaPagoBadgeClass = (forma) => {
  const classes = {
    'EFECTIVO': 'badge-success',
    'CHEQUE': 'badge-info',
    'TRANSFERENCIA': 'badge-primary'
  }
  return classes[forma] || 'badge-secondary'
}

// ========== LIFECYCLE ==========
onMounted(() => {
  cargarEstadisticas() // SOLO stats, NO datos
  // El usuario debe hacer clic en "Buscar" para cargar datos
})
</script>

<!-- Sin estilos scoped - Todo desde municipal-theme.css -->
