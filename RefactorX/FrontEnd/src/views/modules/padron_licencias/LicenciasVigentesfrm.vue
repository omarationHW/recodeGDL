<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-check" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Licencias Vigentes</h1>
        <p>Padrón de Licencias - Consulta y reporte de licencias vigentes</p></div>
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
          class="btn-municipal-secondary"
          @click="exportarExcel"
          :disabled="loading || licencias.length === 0"
        >
          <font-awesome-icon icon="file-excel" />
          Exportar a Excel
        </button>
        <button
          class="btn-municipal-primary"
          @click="generarPDF"
          :disabled="loading || licencias.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          Generar PDF
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Giro:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.giro"
              placeholder="Nombre del giro"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Zona:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.zona"
              placeholder="Zona geográfica"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado:</label>
            <select class="municipal-form-control" v-model="filters.estado">
              <option value="">Todos</option>
              <option value="VIGENTE">Vigente</option>
              <option value="SUSPENDIDA">Suspendida</option>
              <option value="TEMPORAL">Temporal</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Fecha Otorgamiento Desde:</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaDesde"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Otorgamiento Hasta:</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaHasta"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Propietario:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarLicencias"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadLicencias"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Licencias Vigentes
          <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
        </h5>
        <div v-if="loading" class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Número</th>
                <th>Propietario</th>
                <th>Giro</th>
                <th>Ubicación</th>
                <th>Zona</th>
                <th>Fecha Otorgamiento</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="licencia in licencias" :key="licencia.numero" class="row-hover">
                <td><strong class="text-primary">{{ licencia.numero || 'N/A' }}</strong></td>
                <td>{{ licencia.propietario || 'N/A' }}</td>
                <td>
                  <span class="badge-info">
                    {{ licencia.giro || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ licencia.ubicacion || 'N/A' }}
                  </small>
                </td>
                <td>
                  <span class="badge-secondary">
                    {{ licencia.zona || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(licencia.fecha_otorgamiento) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getStatusBadge(licencia.estado)">
                    <font-awesome-icon :icon="getStatusIcon(licencia.estado)" />
                    {{ licencia.estado || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="verDetalle(licencia)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="licencias.length === 0 && !loading">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron licencias vigentes con los criterios especificados</p>
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

    <!-- Loading overlay -->
    <div v-if="loading && licencias.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    </div>
    <!-- /module-view-content -->

    <!-- Modal de detalle -->
    <Modal
      :show="showDetailModal"
      :title="`Detalle de Licencia: ${selectedLicencia?.numero}`"
      size="xl"
      @close="showDetailModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedLicencia" class="license-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información General
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número de Licencia:</td>
                <td><strong>{{ selectedLicencia.numero }}</strong></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ selectedLicencia.propietario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>
                  <span class="badge-info">
                    {{ selectedLicencia.giro || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getStatusBadge(selectedLicencia.estado)">
                    <font-awesome-icon :icon="getStatusIcon(selectedLicencia.estado)" />
                    {{ selectedLicencia.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Dirección:</td>
                <td>{{ selectedLicencia.ubicacion || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>
                  <span class="badge-secondary">
                    {{ selectedLicencia.zona || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedLicencia.colonia || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td>{{ selectedLicencia.codigo_postal || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Fechas
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Otorgamiento:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedLicencia.fecha_otorgamiento) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Vencimiento:</td>
                <td>
                  <font-awesome-icon icon="calendar-times" class="text-danger" />
                  {{ formatDate(selectedLicencia.fecha_vencimiento) }}
                </td>
              </tr>
              <tr>
                <td class="label">Vigencia:</td>
                <td>{{ selectedLicencia.vigencia || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información Adicional
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Superficie:</td>
                <td>{{ selectedLicencia.superficie || 'N/A' }} m²</td>
              </tr>
              <tr>
                <td class="label">Empleados:</td>
                <td>{{ selectedLicencia.empleados || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Horario:</td>
                <td>{{ selectedLicencia.horario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Observaciones:</td>
                <td>{{ selectedLicencia.observaciones || 'Sin observaciones' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showDetailModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </Modal>

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
      :componentName="'LicenciasVigentesfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()

// Estado
const licencias = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(25)
const totalRecords = ref(0)
const selectedLicencia = ref(null)
const showDetailModal = ref(false)

// Filtros
const filters = ref({
  giro: '',
  zona: '',
  estado: '',
  fechaDesde: '',
  fechaHasta: '',
  propietario: ''
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
const loadLicencias = async () => {
  setLoading(true, 'Cargando licencias vigentes...')

  try {
    const response = await execute(
      'LicenciasVigentesfrm_sp_licencias_vigentes',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_giro', valor: filters.value.giro || null, tipo: 'string' },
        { nombre: 'p_zona', valor: filters.value.zona || null, tipo: 'string' },
        { nombre: 'p_estado', valor: filters.value.estado || null, tipo: 'string' },
        { nombre: 'p_fecha_desde', valor: filters.value.fechaDesde || null, tipo: 'string' },
        { nombre: 'p_fecha_hasta', valor: filters.value.fechaHasta || null, tipo: 'string' },
        { nombre: 'p_propietario', valor: filters.value.propietario || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      licencias.value = response.result
      if (licencias.value.length > 0) {
        totalRecords.value = parseInt(licencias.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Licencias cargadas correctamente')
    } else {
      licencias.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar licencias')
    }
  } catch (error) {
    handleApiError(error)
    licencias.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const buscarLicencias = () => {
  currentPage.value = 1
  loadLicencias()
}

const limpiarFiltros = () => {
  filters.value = {
    giro: '',
    zona: '',
    estado: '',
    fechaDesde: '',
    fechaHasta: '',
    propietario: ''
  }
  currentPage.value = 1
  loadLicencias()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadLicencias()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadLicencias()
}

const verDetalle = (licencia) => {
  selectedLicencia.value = licencia
  showDetailModal.value = true
}

const exportarExcel = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Exportar a Excel',
    text: 'Esta funcionalidad está en desarrollo',
    confirmButtonColor: '#ea8215'
  })
  showToast('info', 'Funcionalidad de exportación a Excel en desarrollo')
}

const generarPDF = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Generar PDF',
    text: 'Esta funcionalidad está en desarrollo',
    confirmButtonColor: '#ea8215'
  })
  showToast('info', 'Funcionalidad de generación de PDF en desarrollo')
}

const getStatusBadge = (estado) => {
  const estados = {
    'VIGENTE': 'badge-success',
    'SUSPENDIDA': 'badge-warning',
    'TEMPORAL': 'badge-info',
    'CANCELADA': 'badge-danger'
  }
  return estados[estado?.toUpperCase()] || 'badge-secondary'
}

const getStatusIcon = (estado) => {
  const iconos = {
    'VIGENTE': 'check-circle',
    'SUSPENDIDA': 'pause-circle',
    'TEMPORAL': 'clock',
    'CANCELADA': 'times-circle'
  }
  return iconos[estado?.toUpperCase()] || 'question-circle'
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

// Lifecycle
onMounted(() => {
  loadLicencias()
})
</script>

<style scoped>
.license-details {
  padding: 8px 0;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.detail-section {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.section-title {
  color: #495057;
  font-weight: 600;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 2px solid #dee2e6;
}

.detail-table {
  width: 100%;
  border-collapse: collapse;
}

.detail-table tr {
  border-bottom: 1px solid #e9ecef;
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 8px 0;
}

.detail-table td.label {
  font-weight: 500;
  color: #6c757d;
  width: 45%;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid #dee2e6;
}

.empty-icon {
  color: #dee2e6;
  margin-bottom: 12px;
}
</style>
