<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="right-to-bracket" /></div>
      <div class="module-view-info">
        <h1>Acceso — Estacionamientos Públicos</h1>
        <p>Consulta de estacionamientos registrados en el padrón</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="cargarDatos" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync-alt'" :spin="loading" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input type="text" class="municipal-form-control" v-model="filtro" placeholder="Nombre, calle, licencia..." @input="currentPage = 1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Categoría</label>
              <select class="municipal-form-control" v-model="filtroCat" @change="currentPage = 1">
                <option value="">Todas</option>
                <option v-for="cat in categorias" :key="cat" :value="cat">{{ cat }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sector</label>
              <select class="municipal-form-control" v-model="filtroSector" @change="currentPage = 1">
                <option value="">Todos</option>
                <option v-for="sec in sectores" :key="sec" :value="sec">{{ sec }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Estacionamientos</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="estacionamientos.length > 0">
              {{ formatNumber(totalRecords) }} de {{ formatNumber(estacionamientos.length) }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-2">Cargando estacionamientos...</p>
          </div>

          <div v-else-if="estacionamientos.length === 0" class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3 empty-icon" />
            <p>No hay estacionamientos registrados</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Licencia</th>
                  <th>Categoría</th>
                  <th>Nombre</th>
                  <th>Dirección</th>
                  <th>Sector</th>
                  <th>Zona</th>
                  <th>Cupo</th>
                  <th>F. Vencimiento</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="e in paginatedData" :key="e.id" class="row-hover">
                  <td>{{ e.id }}</td>
                  <td><strong class="text-primary">{{ e.numlicencia }}</strong></td>
                  <td><span class="badge badge-secondary">{{ e.categoria }}</span></td>
                  <td>{{ e.nombre }}</td>
                  <td><small>{{ e.calle }} {{ e.numext }}</small></td>
                  <td><small>{{ e.sector }} - {{ e.nomsector }}</small></td>
                  <td>{{ e.zona }}-{{ e.subzona }}</td>
                  <td class="text-center">{{ e.cupo }}</td>
                  <td>
                    <span class="badge" :class="estaVencido(e.fecha_vencimiento) ? 'badge-danger' : 'badge-success'">
                      {{ formatFecha(e.fecha_vencimiento) }}
                    </span>
                  </td>
                  <td>
                    <button class="btn-municipal-primary btn-sm" @click="verDetalle(e)" title="Ver detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="estacionamientos.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
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
    </div>

    <!-- Modal Detalle -->
    <div v-if="showDetalle" class="modal-overlay" @click.self="showDetalle = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-header">
          <h5 class="modal-title">
            <font-awesome-icon icon="parking" class="me-2" />
            Detalle del Estacionamiento
          </h5>
          <button type="button" class="modal-close" @click="showDetalle = false">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body" v-if="detalle">
          <div class="details-grid">
            <!-- Sección 1: Información General -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Información General
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">ID:</td>
                  <td><strong class="text-primary">{{ detalle.id }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Licencia:</td>
                  <td><strong>{{ detalle.numlicencia }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Categoría:</td>
                  <td><span class="badge badge-purple">{{ detalle.categoria }}</span> {{ detalle.descripcion }}</td>
                </tr>
                <tr>
                  <td class="label">Nombre:</td>
                  <td>{{ detalle.nombre }}</td>
                </tr>
                <tr>
                  <td class="label">Teléfono:</td>
                  <td>{{ detalle.telefono || '—' }}</td>
                </tr>
              </table>
            </div>

            <!-- Sección 2: Ubicación -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Dirección:</td>
                  <td>{{ detalle.calle }} {{ detalle.numext }}</td>
                </tr>
                <tr>
                  <td class="label">Sector:</td>
                  <td><span class="badge badge-secondary">{{ detalle.sector }}</span> {{ detalle.nomsector }}</td>
                </tr>
                <tr>
                  <td class="label">Zona/Subzona:</td>
                  <td>{{ detalle.zona }}-{{ detalle.subzona }}</td>
                </tr>
                <tr>
                  <td class="label">Cupo:</td>
                  <td><strong>{{ detalle.cupo }}</strong> vehículos</td>
                </tr>
              </table>
            </div>

            <!-- Sección 3: Fechas -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="calendar-alt" />
                Fechas y Vigencia
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Fecha Alta:</td>
                  <td>
                    <font-awesome-icon icon="calendar-plus" class="text-success me-1" />
                    {{ formatFecha(detalle.fecha_at) }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Fecha Inicio:</td>
                  <td>
                    <font-awesome-icon icon="calendar" class="text-info me-1" />
                    {{ formatFecha(detalle.fecha_inicial) }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Vencimiento:</td>
                  <td>
                    <font-awesome-icon icon="calendar-times" :class="estaVencido(detalle.fecha_vencimiento) ? 'text-danger' : 'text-success'" class="me-1" />
                    <span :class="estaVencido(detalle.fecha_vencimiento) ? 'text-danger fw-bold' : 'text-success'">
                      {{ formatFecha(detalle.fecha_vencimiento) }}
                    </span>
                    <span v-if="estaVencido(detalle.fecha_vencimiento)" class="badge badge-danger ms-2">VENCIDO</span>
                    <span v-else class="badge badge-success ms-2">VIGENTE</span>
                  </td>
                </tr>
              </table>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="showDetalle = false">
            <font-awesome-icon icon="times" class="me-1" />
            Cerrar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'

const { loading, execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const estacionamientos = ref([])
const filtro = ref('')
const filtroCat = ref('')
const filtroSector = ref('')
const showDetalle = ref(false)
const detalle = ref(null)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed
const categorias = computed(() => {
  const cats = [...new Set(estacionamientos.value.map(e => e.categoria).filter(Boolean))]
  return cats.sort()
})

const sectores = computed(() => {
  const secs = [...new Set(estacionamientos.value.map(e => e.nomsector).filter(Boolean))]
  return secs.sort()
})

const estacionamientosFiltrados = computed(() => {
  let result = estacionamientos.value

  if (filtro.value.trim()) {
    const buscar = filtro.value.toLowerCase()
    result = result.filter(e =>
      (e.nombre || '').toLowerCase().includes(buscar) ||
      (e.calle || '').toLowerCase().includes(buscar) ||
      String(e.numlicencia || '').includes(buscar) ||
      String(e.id || '').includes(buscar)
    )
  }

  if (filtroCat.value) {
    result = result.filter(e => e.categoria === filtroCat.value)
  }

  if (filtroSector.value) {
    result = result.filter(e => e.nomsector === filtroSector.value)
  }

  return result
})

// Paginación - Computed
const totalRecords = computed(() => estacionamientosFiltrados.value.length)

const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return estacionamientosFiltrados.value.slice(start, end)
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

// Métodos
function formatFecha(fecha) {
  if (!fecha) return '—'
  const d = new Date(fecha)
  return d.toLocaleDateString('es-MX')
}

function estaVencido(fecha) {
  if (!fecha) return false
  return new Date(fecha) < new Date()
}

async function cargarDatos() {
  showLoading('Cargando...', 'Obteniendo listado de estacionamientos')
  currentPage.value = 1
  try {
    // SP en estacionamiento_publico.public
    const resp = await execute('sp_get_public_parking_list', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    estacionamientos.value = Array.isArray(data) ? data : []

    if (estacionamientos.value.length > 0) {
      showToast('success', `Se cargaron ${estacionamientos.value.length} estacionamiento(s)`)
    } else {
      showToast('info', 'No hay estacionamientos registrados en el sistema')
    }
  } catch (e) {
    handleApiError(e, 'Error al cargar estacionamientos')
    estacionamientos.value = []
  } finally {
    hideLoading()
  }
}

function verDetalle(e) {
  detalle.value = e
  showDetalle.value = true
}

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

onMounted(() => {
  cargarDatos()
})
</script>
