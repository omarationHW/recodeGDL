<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-alt" />
      </div>
      <div class="module-view-info">
        <h1>Listado de Movimientos</h1>
        <p>Cementerios - Consulta de movimientos por rango de fechas</p>
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
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-three">
            <div class="form-group">
              <label class="form-label required">Fecha Inicio</label>
              <input v-model="filtros.fecha_inicio" type="date" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="form-label required">Fecha Fin</label>
              <input v-model="filtros.fecha_fin" type="date" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Cementerio</label>
              <select v-model="filtros.cementerio" class="municipal-form-control">
                <option value="">-- Todos --</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.nombre }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-actions">
            <button @click="buscarMovimientos" class="btn-municipal-primary">
              <font-awesome-icon icon="search" />
              Buscar Movimientos
            </button>
            <button @click="limpiar" class="btn-municipal-secondary">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="movimientos.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="list-alt" size="3x" />
        </div>
        <h4>Listado de Movimientos</h4>
        <p>Seleccione un rango de fechas y presione "Buscar Movimientos" para consultar los registros</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="movimientos.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron movimientos en el rango de fechas especificado</p>
      </div>

      <!-- Resultados -->
      <div v-if="movimientos.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Movimientos Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="movimientos.length > 0">
              {{ movimientos.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th>Folio</th>
                  <th>Cementerio</th>
                  <th>Ubicación</th>
                  <th>Titular</th>
                  <th>Usuario</th>
                  <th>Observaciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="mov in paginatedMovimientos"
                  :key="`${mov.control_rcm}-${mov.fecha_mov}`"
                  @click="selectedRow = mov"
                  :class="{ 'table-row-selected': selectedRow === mov }"
                  class="row-hover"
                >
                  <td>
                    <strong>{{ formatearFecha(mov.fecha_mov) }}</strong>
                  </td>
                  <td>
                    <span class="badge badge-primary">{{ mov.control_rcm }}</span>
                  </td>
                  <td>
                    <small>{{ mov.nombre_cementerio || mov.cementerio }}</small>
                  </td>
                  <td>
                    <small class="text-muted">{{ mov.ubicacion || '-' }}</small>
                  </td>
                  <td>{{ mov.nombre }}</td>
                  <td>
                    <small>{{ mov.nombre_usuario || mov.usuario }}</small>
                  </td>
                  <td>{{ mov.observaciones || '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="movimientos.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ formatNumber(totalRecords) }} registros
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
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'List_Mov'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Listado de Movimientos'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado de selección y búsqueda
const selectedRow = ref(null)
const hasSearched = ref(false)

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

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

const filtros = reactive({
  fecha_inicio: '',
  fecha_fin: '',
  cementerio: ''
})

const movimientos = ref([])
const cementerios = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => movimientos.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedMovimientos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return movimientos.value.slice(start, end)
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

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const buscarMovimientos = async () => {
  if (!filtros.fecha_inicio || !filtros.fecha_fin) {
    showToast('warning', 'Debe especificar el rango de fechas')
    return
  }

  if (new Date(filtros.fecha_inicio) > new Date(filtros.fecha_fin)) {
    showToast('warning', 'La fecha de inicio no puede ser mayor a la fecha fin')
    return
  }

  showLoading('Buscando movimientos...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const params = [
      { nombre: 'p_fecha_inicio', valor: filtros.fecha_inicio, tipo: 'date' },
      { nombre: 'p_fecha_fin', valor: filtros.fecha_fin, tipo: 'date' },
      { nombre: 'p_cementerio', valor: filtros.cementerio || null, tipo: 'string' }
    ]

    const response = await execute(
      'sp_listmov_buscar_movimientos',
      'cementerio',
      params,
      'cementerio',
      null,
      'public'
    )

    movimientos.value = response?.result || []

    if (movimientos.value.length > 0) {
      showToast('success', `Se encontraron ${movimientos.value.length} movimiento(s)`)
    } else {
      showToast('info', 'No se encontraron movimientos en el período especificado')
    }
  } catch (error) {
    console.error('Error al buscar movimientos:', error)
    showToast('error', 'Error al buscar movimientos')
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filtros.fecha_inicio = ''
  filtros.fecha_fin = ''
  filtros.cementerio = ''
  movimientos.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

const cargarCementerios = async () => {
  try {
    // Para evitar SP adicionales llamamos el SP que ya existe para listar cementerios
    const response = await execute(
      //'sp_listmov_listar_cementerios',
      'sp_get_cementerios_list',
      'cementerio',
      [],
      'cementerio',
      null,
      'public'
    )

    if (response?.result?.length > 0) {
      cementerios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  const date = new Date(fecha)
  return date.toLocaleDateString('es-MX')
}

onMounted(() => {
  cargarCementerios()

  // Establecer fechas por defecto (último mes)
  const hoy = new Date()
  const haceUnMes = new Date()
  haceUnMes.setMonth(haceUnMes.getMonth() - 1)

  filtros.fecha_fin = hoy.toISOString().split('T')[0]
  filtros.fecha_inicio = haceUnMes.toISOString().split('T')[0]
})
</script>
