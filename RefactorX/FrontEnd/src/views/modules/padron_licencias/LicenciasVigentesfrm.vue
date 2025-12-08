<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-check" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Licencias Vigentes</h1>
        <p>Padrón de Licencias - Consulta y reporte de licencias vigentes</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-danger"
          @click="iniciarBajaMasiva"
          :disabled="selectedItems.length === 0"
          v-if="licencias.length > 0"
        >
          <font-awesome-icon icon="trash-alt" />
          Baja Masiva ({{ selectedItems.length }})
        </button>
        <button
          class="btn-municipal-success"
          @click="exportarExcel"
          :disabled="licencias.length === 0"
        >
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button
          class="btn-municipal-danger"
          @click="exportarPDF"
          :disabled="licencias.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          PDF
        </button>
        <button
          class="btn-municipal-primary"
          @click="loadLicencias"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

      <!-- Stats Cards -->
      <div class="stats-grid stats-grid-4" v-if="loadingStats">
        <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="stat-icon skeleton-icon"></div>
            <div class="skeleton-text skeleton-number"></div>
            <div class="skeleton-text skeleton-label"></div>
          </div>
        </div>
      </div>

      <div class="stats-grid stats-grid-4" v-else-if="stats.totalLicencias > 0">
        <div class="stat-card stat-primary">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="clipboard-check" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.totalLicencias) }}</h3>
            <p class="stat-label">Total Licencias</p>
          </div>
        </div>
        <div class="stat-card stat-success">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="check-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.totalVigentes) }}</h3>
            <p class="stat-label">Vigentes</p>
          </div>
        </div>
        <div class="stat-card stat-warning">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="pause-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.totalSuspendidas) }}</h3>
            <p class="stat-label">Suspendidas</p>
          </div>
        </div>
        <div class="stat-card stat-info">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="clock" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.totalTemporales) }}</h3>
            <p class="stat-label">Temporales</p>
          </div>
        </div>
      </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header clickable" @click="toggleFilters">
        <h5>
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
        </h5>
      </div>
      <div class="municipal-card-body" v-show="showFilters">
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
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadLicencias"
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
          Licencias Vigentes
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="totalRecords > 0">
            {{ formatNumber(totalRecords) }} registros
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th class="th-checkbox">
                  <input
                    type="checkbox"
                    :checked="allSelected"
                    @change="toggleSelectAll"
                    title="Seleccionar todos"
                  >
                </th>
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
              <tr v-for="licencia in licencias" :key="licencia.numero" class="row-hover" :class="{ 'row-selected': isSelected(licencia) }">
                <td class="td-checkbox">
                  <input
                    type="checkbox"
                    :checked="isSelected(licencia)"
                    @change="toggleSelection(licencia)"
                  >
                </td>
                <td><strong class="text-primary">{{ licencia.numero || 'N/A' }}</strong></td>
                <td>{{ licencia.propietario || 'N/A' }}</td>
                <td>
                  <span class="badge-purple">
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
              <tr v-if="licencias.length === 0">
                <td colspan="9" class="empty-state">
                  <div class="empty-state-content">
                    <font-awesome-icon icon="inbox" class="empty-state-icon" />
                    <p class="empty-state-text">No se encontraron licencias vigentes</p>
                    <p class="empty-state-hint">Intenta ajustar los filtros de búsqueda</p>
                  </div>
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
                  <span class="badge-purple">
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
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Baja Masiva -->
    <Modal
      :show="showBajaMasivaModal"
      title="Confirmar Baja Masiva"
      size="lg"
      @close="showBajaMasivaModal = false"
      :showDefaultFooter="false"
    >
      <div class="baja-masiva-content">
        <div class="alert alert-warning">
          <font-awesome-icon icon="exclamation-triangle" class="me-2" />
          <strong>¡Atención!</strong> Esta acción dará de baja las siguientes {{ selectedItems.length }} licencias.
        </div>

        <div class="selected-licenses-list">
          <h6>Licencias seleccionadas:</h6>
          <div class="licenses-scroll">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>Número</th>
                  <th>Propietario</th>
                  <th>Estado Actual</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in selectedItems" :key="item.numero">
                  <td><strong>{{ item.numero }}</strong></td>
                  <td>{{ item.propietario }}</td>
                  <td>
                    <span class="badge" :class="getStatusBadge(item.estado)">
                      {{ item.estado }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="form-group mt-3">
          <label class="municipal-form-label">Motivo de la baja (requerido):</label>
          <textarea
            v-model="motivoBaja"
            class="municipal-form-control"
            rows="3"
            placeholder="Ingrese el motivo de la baja masiva..."
          ></textarea>
        </div>

        <div class="modal-actions mt-4">
          <button
            class="btn-municipal-danger"
            @click="ejecutarBajaMasiva"
            :disabled="!motivoBaja || bajaMasivaEnProceso"
          >
            <font-awesome-icon :icon="bajaMasivaEnProceso ? 'spinner' : 'trash-alt'" :spin="bajaMasivaEnProceso" />
            {{ bajaMasivaEnProceso ? 'Procesando...' : 'Confirmar Baja Masiva' }}
          </button>
          <button class="btn-municipal-secondary" @click="showBajaMasivaModal = false" :disabled="bajaMasivaEnProceso">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>
      </div>
    </Modal>

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
import { useExcelExport } from '@/composables/useExcelExport'
import { usePdfExport } from '@/composables/usePdfExport'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { exportToExcel } = useExcelExport()
const { exportToPdf } = usePdfExport()

// Importar useGlobalLoading para el loading estándar
import { useGlobalLoading } from '@/composables/useGlobalLoading'
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const licencias = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedLicencia = ref(null)
const showDetailModal = ref(false)
const loadingStats = ref(false)
const showFilters = ref(false)
const loading = ref(false)

// Estado para selección múltiple y baja masiva
const selectedItems = ref([])
const showBajaMasivaModal = ref(false)
const motivoBaja = ref('')
const bajaMasivaEnProceso = ref(false)

// Stats
const stats = ref({
  totalLicencias: 0,
  totalVigentes: 0,
  totalSuspendidas: 0,
  totalTemporales: 0
})

// Función para calcular fecha de hace 6 meses
const getSixMonthsAgo = () => {
  const date = new Date()
  date.setMonth(date.getMonth() - 6)
  return date.toISOString().split('T')[0]
}

// Función para obtener fecha de hoy
const getToday = () => {
  return new Date().toISOString().split('T')[0]
}

// Filtros con acotamiento de fechas por defecto (últimos 6 meses)
const filters = ref({
  giro: null,
  zona: null,
  estado: null,
  fechaDesde: getSixMonthsAgo(),
  fechaHasta: getToday(),
  propietario: null
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

// Computed para selección
const allSelected = computed(() => {
  return licencias.value.length > 0 && selectedItems.value.length === licencias.value.length
})

// Definición de columnas para exportación
const columnasExport = [
  { header: 'Número', key: 'numero', width: 15 },
  { header: 'Propietario', key: 'propietario', width: 35 },
  { header: 'Giro', key: 'giro', width: 30 },
  { header: 'Ubicación', key: 'ubicacion', width: 40 },
  { header: 'Zona', key: 'zona', width: 15 },
  { header: 'Fecha Otorgamiento', key: 'fecha_otorgamiento', type: 'date', width: 18 },
  { header: 'Estado', key: 'estado', width: 15 }
]

// Calcular estadísticas desde la base de datos (OPTIMIZADO - 1 sola consulta)
const loadStats = async () => {
  loadingStats.value = true

  try {
    const response = await execute(
      'LicenciasVigentesfrm_sp_stats',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const statsData = response.result[0]

      stats.value = {
        totalLicencias: parseInt(statsData.total_licencias) || 0,
        totalVigentes: parseInt(statsData.total_vigentes) || 0,
        totalSuspendidas: parseInt(statsData.total_suspendidas) || 0,
        totalTemporales: parseInt(statsData.total_temporales) || 0
      }
    }
  } catch (error) {
    stats.value = {
      totalLicencias: 0,
      totalVigentes: 0,
      totalSuspendidas: 0,
      totalTemporales: 0
    }
  } finally {
    loadingStats.value = false
  }
}

// Calcular estadísticas desde los datos cargados
const calculateStats = () => {
  const vigentes = licencias.value.filter(l => l.estado === 'VIGENTE').length
  const suspendidas = licencias.value.filter(l => l.estado === 'SUSPENDIDA').length
  const temporales = licencias.value.filter(l => l.estado === 'TEMPORAL').length

  stats.value = {
    totalLicencias: totalRecords.value,
    totalVigentes: vigentes,
    totalSuspendidas: suspendidas,
    totalTemporales: temporales
  }
}

// Métodos
const loadLicencias = async () => {
  showLoading('Cargando licencias vigentes...')
  showFilters.value = false

  // Timer para medir el tiempo de consulta
  const startTime = performance.now()

  try {
    // Helper function para convertir strings vacíos a null
    const cleanValue = (val) => {
      if (val === '' || val === undefined) return null
      return val
    }

    const response = await execute(
      'LicenciasVigentesfrm_sp_licencias_vigentes',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_giro', valor: cleanValue(filters.value.giro), tipo: 'string' },
        { nombre: 'p_zona', valor: cleanValue(filters.value.zona), tipo: 'string' },
        { nombre: 'p_estado', valor: cleanValue(filters.value.estado), tipo: 'string' },
        { nombre: 'p_fecha_desde', valor: cleanValue(filters.value.fechaDesde), tipo: 'string' },
        { nombre: 'p_fecha_hasta', valor: cleanValue(filters.value.fechaHasta), tipo: 'string' },
        { nombre: 'p_propietario', valor: cleanValue(filters.value.propietario), tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      licencias.value = response.result
      if (licencias.value.length > 0) {
        totalRecords.value = parseInt(licencias.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }

      // Formatear el mensaje con el tiempo
      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', 'Licencias cargadas correctamente', timeMessage)
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
    hideLoading()
  }
}

const buscarLicencias = () => {
  currentPage.value = 1
  loadLicencias()
}

const limpiarFiltros = () => {
  filters.value = {
    giro: null,
    zona: null,
    estado: null,
    fechaDesde: getSixMonthsAgo(),
    fechaHasta: getToday(),
    propietario: null
  }
  currentPage.value = 1
  loadLicencias()
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
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

// Funciones de selección múltiple
const isSelected = (licencia) => {
  return selectedItems.value.some(item => item.numero === licencia.numero)
}

const toggleSelection = (licencia) => {
  const index = selectedItems.value.findIndex(item => item.numero === licencia.numero)
  if (index === -1) {
    selectedItems.value.push(licencia)
  } else {
    selectedItems.value.splice(index, 1)
  }
}

const toggleSelectAll = () => {
  if (allSelected.value) {
    selectedItems.value = []
  } else {
    selectedItems.value = [...licencias.value]
  }
}

const clearSelection = () => {
  selectedItems.value = []
}

// Funciones de Baja Masiva
const iniciarBajaMasiva = () => {
  if (selectedItems.value.length === 0) {
    showToast('warning', 'Seleccione al menos una licencia')
    return
  }
  motivoBaja.value = ''
  showBajaMasivaModal.value = true
}

const ejecutarBajaMasiva = async () => {
  if (!motivoBaja.value.trim()) {
    showToast('warning', 'Debe ingresar un motivo para la baja')
    return
  }

  bajaMasivaEnProceso.value = true

  try {
    // Preparar lista de números de licencia
    const numerosLicencias = selectedItems.value.map(item => item.numero).join(',')

    const response = await execute(
      'LicenciasVigentesfrm_sp_baja_masiva',
      'padron_licencias',
      [
        { nombre: 'p_numeros_licencia', valor: numerosLicencias, tipo: 'string' },
        { nombre: 'p_motivo', valor: motivoBaja.value.trim(), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      const resultado = response.result[0] || {}
      const procesadas = resultado.procesadas || selectedItems.value.length
      const errores = resultado.errores || 0

      if (errores === 0) {
        await Swal.fire({
          icon: 'success',
          title: 'Baja Masiva Completada',
          text: `Se dieron de baja ${procesadas} licencias correctamente`,
          confirmButtonColor: '#28a745'
        })
        showToast('success', `${procesadas} licencias dadas de baja`)
      } else {
        await Swal.fire({
          icon: 'warning',
          title: 'Baja Masiva Parcial',
          html: `Procesadas: ${procesadas}<br>Con errores: ${errores}`,
          confirmButtonColor: '#ea8215'
        })
        showToast('warning', `${procesadas} procesadas, ${errores} con errores`)
      }

      // Cerrar modal y recargar datos
      showBajaMasivaModal.value = false
      clearSelection()
      loadLicencias()
      loadStats()
    } else {
      throw new Error('Respuesta inválida del servidor')
    }
  } catch (error) {
    await Swal.fire({
      icon: 'error',
      title: 'Error en Baja Masiva',
      text: error.message || 'Error al procesar la baja masiva',
      confirmButtonColor: '#dc3545'
    })
    handleApiError(error)
  } finally {
    bajaMasivaEnProceso.value = false
  }
}

// Funciones de Exportación
const exportarExcel = async () => {
  if (licencias.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  showLoading('Generando Excel...', 'Por favor espere')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    const success = exportToExcel(licencias.value, columnasExport, 'Licencias_Vigentes')

    if (success) {
      showToast('success', 'Excel generado correctamente')
    } else {
      showToast('error', 'Error al generar Excel')
    }
  } catch (error) {
    showToast('error', 'Error al generar Excel')
  } finally {
    hideLoading()
  }
}

const exportarPDF = async () => {
  if (licencias.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  showLoading('Generando PDF...', 'Por favor espere')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    const success = exportToPdf(licencias.value, columnasExport, {
      title: 'Reporte de Licencias Vigentes',
      subtitle: `Generado el ${new Date().toLocaleDateString('es-MX')}`,
      orientation: 'landscape'
    })

    if (success) {
      showToast('success', 'PDF generado correctamente')
    } else {
      showToast('error', 'Error al generar PDF')
    }
  } catch (error) {
    showToast('error', 'Error al generar PDF')
  } finally {
    hideLoading()
  }
}

const getStatusBadge = (estado) => {
  const estados = {
    'VIGENTE': 'badge-success',
    'SUSPENDIDA': 'badge-warning',
    'TEMPORAL': 'badge-purple',
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

const formatNumber = (value) => {
  if (!value && value !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(value)
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
  // Cargar estadísticas automáticamente al montar el componente
  loadStats()
  // La tabla de licencias solo se carga al presionar "Actualizar"
})
</script>

<style scoped>
/* Estilos para checkbox de selección */
.th-checkbox,
.td-checkbox {
  width: 40px;
  text-align: center;
  vertical-align: middle;
}

.th-checkbox input[type="checkbox"],
.td-checkbox input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: var(--municipal-primary, #ea8215);
}

/* Fila seleccionada */
.row-selected {
  background-color: rgba(234, 130, 21, 0.1) !important;
}

.row-selected:hover {
  background-color: rgba(234, 130, 21, 0.15) !important;
}

/* Estilos para modal de baja masiva */
.baja-masiva-content .alert-warning {
  background-color: #fff3cd;
  border-color: #ffc107;
  color: #856404;
  padding: 1rem;
  border-radius: 0.375rem;
  margin-bottom: 1rem;
}

.selected-licenses-list h6 {
  color: var(--municipal-text, #333);
  margin-bottom: 0.75rem;
  font-weight: 600;
}

.licenses-scroll {
  max-height: 250px;
  overflow-y: auto;
  border: 1px solid var(--municipal-border, #dee2e6);
  border-radius: 0.375rem;
}

.licenses-scroll .municipal-table {
  margin-bottom: 0;
}

.licenses-scroll .municipal-table th,
.licenses-scroll .municipal-table td {
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
}

.modal-actions .btn-municipal-danger,
.modal-actions .btn-municipal-secondary {
  min-width: 150px;
}

/* Ajustes responsive */
@media (max-width: 768px) {
  .modal-actions {
    flex-direction: column;
  }

  .modal-actions button {
    width: 100%;
  }
}
</style>

