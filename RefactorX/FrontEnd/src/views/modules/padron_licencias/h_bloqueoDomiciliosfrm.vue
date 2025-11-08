<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="history" />
      </div>
      <div class="module-view-info">
        <h1>Historial de Bloqueo de Domicilios</h1>
        <p>Padrón de Licencias - Historial de Domicilios Bloqueados</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="exportToExcel"
          :disabled="bloques.length === 0"
        >
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button
          class="btn-municipal-secondary"
          @click="printReport"
          :disabled="bloques.length === 0"
        >
          <font-awesome-icon icon="print" />
          Imprimir Reporte
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Tarjeta de estadísticas -->
    <div class="municipal-card" v-if="statistics.totalBloques > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="chart-bar" />
          Estadísticas de Bloqueos
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-icon stat-primary">
              <font-awesome-icon icon="ban" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.totalBloques }}</div>
              <div class="stat-label">Total Bloqueos</div>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon stat-info">
              <font-awesome-icon icon="layer-group" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.byType }}</div>
              <div class="stat-label">Tipos de Bloqueo</div>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon stat-success">
              <font-awesome-icon icon="map-marked-alt" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.byColony }}</div>
              <div class="stat-label">Colonias Afectadas</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Fecha Inicio</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaInicio"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Fin</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaFin"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Calle</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.calle"
              placeholder="Nombre de la calle"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Colonia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.colonia"
              placeholder="Nombre de la colonia"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Bloqueo</label>
            <select class="municipal-form-control" v-model="filters.tipoBloqueo">
              <option value="">Todos los tipos</option>
              <option value="PERMANENTE">Permanente</option>
              <option value="TEMPORAL">Temporal</option>
              <option value="PARCIAL">Parcial</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchBloques"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadBloques"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Historial de Bloqueos
        </h5>
        <span class="badge-purple" v-if="totalRecords > 0">{{ totalRecords.toLocaleString() }} registros</span>
      </div>

      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Calle</th>
                <th>Número</th>
                <th>Colonia</th>
                <th>Tipo Bloqueo</th>
                <th>Fecha Inicio</th>
                <th>Fecha Fin</th>
                <th>Usuario</th>
                <th>Motivo</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bloque in bloques" :key="bloque.id" class="row-hover">
                <td><strong class="text-primary">{{ bloque.calle?.trim() || 'N/A' }}</strong></td>
                <td>{{ bloque.numero || 'S/N' }}</td>
                <td>{{ bloque.colonia?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getTipoBloqueoClass(bloque.tipo_bloqueo)">
                    <font-awesome-icon icon="ban" />
                    {{ bloque.tipo_bloqueo?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(bloque.fecha_inicio) }}
                  </small>
                </td>
                <td>
                  <small class="text-muted">
                    {{ formatDate(bloque.fecha_fin) }}
                  </small>
                </td>
                <td>{{ bloque.usuario?.trim() || 'N/A' }}</td>
                <td>
                  <small>{{ truncateText(bloque.motivo, 30) }}</small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewDetalle(bloque)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="bloques.length === 0 && !loading">
                <td colspan="9" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron bloqueos con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div class="pagination-container" v-if="totalRecords > 0 && !loading">
        <div class="pagination-info">
          <font-awesome-icon icon="info-circle" />
          Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
          a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
          de {{ totalRecords }} registros
        </div>

        <div class="pagination-controls">
          <div class="page-size-selector">
            <label>Mostrar:</label>
            <select v-model="itemsPerPage" @change="changePageSize">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
            </select>
          </div>

          <div class="pagination-nav">
            <button
              class="pagination-button"
              @click="goToPage(currentPage - 1)"
              :disabled="currentPage === 1"
            >
              <font-awesome-icon icon="chevron-left" />
            </button>

            <button
              v-for="page in visiblePages"
              :key="page"
              class="pagination-button"
              :class="{ active: page === currentPage }"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>

            <button
              class="pagination-button"
              @click="goToPage(currentPage + 1)"
              :disabled="currentPage === totalPages"
            >
              <font-awesome-icon icon="chevron-right" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de detalle -->
    <Modal
      :show="showDetalleModal"
      :title="`Detalle de Bloqueo - ${selectedBloque?.calle || 'N/A'}`"
      size="lg"
      @close="showDetalleModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedBloque" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Información del Domicilio
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Calle:</td>
                <td><strong>{{ selectedBloque.calle?.trim() || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Número:</td>
                <td>{{ selectedBloque.numero || 'S/N' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedBloque.colonia?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CP:</td>
                <td>{{ selectedBloque.cp || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo de Bloqueo:</td>
                <td>
                  <span class="badge" :class="getTipoBloqueoClass(selectedBloque.tipo_bloqueo)">
                    {{ selectedBloque.tipo_bloqueo?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Información del Bloqueo
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Inicio:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-danger" />
                  {{ formatDate(selectedBloque.fecha_inicio) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Fin:</td>
                <td>
                  <font-awesome-icon icon="calendar-minus" class="text-success" />
                  {{ formatDate(selectedBloque.fecha_fin) }}
                </td>
              </tr>
              <tr>
                <td class="label">Usuario:</td>
                <td>{{ selectedBloque.usuario?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="clock" class="text-info" />
                  {{ formatDate(selectedBloque.fecha_captura) }}
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="comment" />
            Motivo del Bloqueo
          </h6>
          <p class="motivo-text">{{ selectedBloque.motivo?.trim() || 'Sin motivo especificado' }}</p>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showDetalleModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'h_bloqueoDomiciliosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const bloques = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedBloque = ref(null)
const showDetalleModal = ref(false)

// Estadísticas
const statistics = ref({
  totalBloques: 0,
  byType: 0,
  byColony: 0
})

// Filtros
const filters = ref({
  fechaInicio: '',
  fechaFin: '',
  calle: '',
  colonia: '',
  tipoBloqueo: ''
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
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

// Métodos
const loadBloques = async () => {
  showLoading('Cargando historial de bloqueos...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'h_bloqueoDomiciliosfrm_sp_list_h_bloqueo_dom',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      bloques.value = response.result
      if (bloques.value.length > 0) {
        totalRecords.value = parseInt(bloques.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      calculateStatistics()

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', `${totalRecords.value.toLocaleString()} registros encontrados`, `(${timeMessage})`)
    } else {
      bloques.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron bloqueos')
    }
  } catch (error) {
    handleApiError(error, 'No se pudo cargar el historial')
    bloques.value = []
    totalRecords.value = 0
  } finally {
    hideLoading()
  }
}

const searchBloques = async () => {
  showLoading('Buscando bloqueos...')
  currentPage.value = 1

  try {
    const response = await execute(
      'h_bloqueoDomiciliosfrm_sp_filter_h_bloqueo_dom',
      'padron_licencias',
      [
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' },
        { nombre: 'p_calle', valor: filters.value.calle || null, tipo: 'string' },
        { nombre: 'p_colonia', valor: filters.value.colonia || null, tipo: 'string' },
        { nombre: 'p_tipo_bloqueo', valor: filters.value.tipoBloqueo || null, tipo: 'string' },
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'public'
    )

    if (response && response.result) {
      bloques.value = response.result
      if (bloques.value.length > 0) {
        totalRecords.value = parseInt(bloques.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      calculateStatistics()
      showToast('success', 'Búsqueda completada')
    } else {
      bloques.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron resultados')
    }
  } catch (error) {
    handleApiError(error, 'Error en la búsqueda')
    bloques.value = []
    totalRecords.value = 0
  } finally {
    hideLoading()
  }
}

const viewDetalle = async (bloqueo) => {
  showLoading('Cargando detalle del bloqueo...')

  try {
    const response = await execute(
      'h_bloqueoDomiciliosfrm_sp_h_bloqueo_dom_detalle',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: bloqueo.id, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'public'
    )

    if (response && response.result && response.result[0]) {
      selectedBloque.value = response.result[0]
      showDetalleModal.value = true
    } else {
      showToast('error', 'No se pudo cargar el detalle')
    }
  } catch (error) {
    handleApiError(error, 'Error al cargar el detalle')
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    fechaInicio: '',
    fechaFin: '',
    calle: '',
    colonia: '',
    tipoBloqueo: ''
  }
  currentPage.value = 1
  loadBloques()
}

const exportToExcel = async () => {
  const result = await Swal.fire({
    title: 'Exportar a Excel',
    text: '¿Desea exportar el historial de bloqueos a Excel?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, exportar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    showLoading('Generando archivo Excel...')

    try {
      const response = await execute(
        'h_bloqueoDomiciliosfrm_sp_exportar_h_bloqueo_dom_excel',
        'padron_licencias',
        [
          { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
          { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' },
          { nombre: 'p_calle', valor: filters.value.calle || null, tipo: 'string' },
          { nombre: 'p_colonia', valor: filters.value.colonia || null, tipo: 'string' },
          { nombre: 'p_tipo_bloqueo', valor: filters.value.tipoBloqueo || null, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        await Swal.fire({
          icon: 'success',
          title: 'Excel generado',
          text: 'El archivo se ha generado correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
        showToast('success', 'Archivo Excel generado exitosamente')
      }
    } catch (error) {
      handleApiError(error)
    } finally {
      hideLoading()
    }
  }
}

const printReport = async () => {
  const result = await Swal.fire({
    title: 'Imprimir Reporte',
    text: '¿Desea imprimir el reporte de bloqueos?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    showLoading('Generando reporte...')

    try {
      const response = await execute(
        'h_bloqueoDomiciliosfrm_sp_imprimir_h_bloqueo_dom_report',
        'padron_licencias',
        [
          { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
          { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' },
          { nombre: 'p_calle', valor: filters.value.calle || null, tipo: 'string' },
          { nombre: 'p_colonia', valor: filters.value.colonia || null, tipo: 'string' },
          { nombre: 'p_tipo_bloqueo', valor: filters.value.tipoBloqueo || null, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        await Swal.fire({
          icon: 'success',
          title: 'Reporte generado',
          text: 'El reporte está listo para imprimir',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
        showToast('success', 'Reporte generado exitosamente')
      }
    } catch (error) {
      handleApiError(error)
    } finally {
      hideLoading()
    }
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadBloques()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadBloques()
}

const calculateStatistics = () => {
  if (bloques.value.length === 0) {
    statistics.value = {
      totalBloques: 0,
      byType: 0,
      byColony: 0
    }
    return
  }

  const types = new Set()
  const colonies = new Set()

  bloques.value.forEach(bloque => {
    if (bloque.tipo_bloqueo) types.add(bloque.tipo_bloqueo)
    if (bloque.colonia) colonies.add(bloque.colonia)
  })

  statistics.value = {
    totalBloques: totalRecords.value,
    byType: types.size,
    byColony: colonies.size
  }
}

// Utilidades
const getTipoBloqueoClass = (tipo) => {
  const classes = {
    'PERMANENTE': 'badge-danger',
    'TEMPORAL': 'badge-warning',
    'PARCIAL': 'badge-info'
  }
  return classes[tipo] || 'badge-secondary'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const truncateText = (text, length) => {
  if (!text) return 'N/A'
  return text.length > length ? text.substring(0, length) + '...' : text
}

// Lifecycle
onMounted(() => {
  loadBloques()
})

onBeforeUnmount(() => {
  showDetalleModal.value = false
})
</script>

<style scoped>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1rem;
}

.stat-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 0.5rem;
  border: 1px solid #e9ecef;
}

.stat-icon {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 0.5rem;
  margin-right: 1rem;
  font-size: 1.5rem;
  color: white;
}

.stat-icon.stat-primary {
  background: linear-gradient(135deg, #ea8215 0%, #c46e12 100%);
}

.stat-icon.stat-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.stat-icon.stat-success {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  color: #2c3e50;
  line-height: 1;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 500;
}

.motivo-text {
  padding: 1rem;
  background: #f8f9fa;
  border-left: 4px solid #ea8215;
  border-radius: 0.25rem;
  margin: 0;
  line-height: 1.6;
  color: #495057;
}

.full-width {
  grid-column: 1 / -1;
}
</style>
