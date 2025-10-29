<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Licencias Suspendidas</h1>
        <p>Padrón de Licencias - Consulta de Licencias con Suspensión o Bloqueo</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de reporte -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Criterios de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Filtro:</label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoFiltro"
                @change="onTipoFiltroChange"
                :disabled="loading"
              >
                <option value="year">Por Año</option>
                <option value="range">Por Rango de Fechas</option>
                <option value="date">Por Fecha Específica</option>
              </select>
            </div>

            <!-- Filtro por año -->
            <div class="form-group" v-if="filters.tipoFiltro === 'year'">
              <label class="municipal-form-label">Año: <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filters.year"
                :min="2000"
                :max="new Date().getFullYear()"
                placeholder="Ej: 2024"
                :disabled="loading"
              >
            </div>

            <!-- Filtro por fecha específica -->
            <div class="form-group" v-if="filters.tipoFiltro === 'date'">
              <label class="municipal-form-label">Fecha: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.dateFrom"
                :disabled="loading"
              >
            </div>

            <!-- Filtro por rango -->
            <div class="form-group" v-if="filters.tipoFiltro === 'range'">
              <label class="municipal-form-label">Fecha Inicio: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.dateFrom"
                :disabled="loading"
              >
            </div>
            <div class="form-group" v-if="filters.tipoFiltro === 'range'">
              <label class="municipal-form-label">Fecha Fin: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.dateTo"
                :disabled="loading"
              >
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Tipo de Suspensión:</label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoSuspension"
                :disabled="loading"
              >
                <option value="0">Todos los tipos</option>
                <option value="1">Tipo 1 - Suspensión Administrativa</option>
                <option value="2">Tipo 2 - Suspensión por Adeudo</option>
                <option value="3">Tipo 3 - Suspensión Temporal</option>
                <option value="4">Tipo 4 - Cancelación Definitiva</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="loading || !isFormValid"
            >
              <font-awesome-icon icon="search" />
              Generar Reporte
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="licencias.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Licencias Suspendidas
            <span class="badge-danger" v-if="licencias.length > 0">{{ licencias.length }} licencias</span>
          </h5>
          <button
            class="btn-municipal-primary"
            @click="exportarExcel"
            :disabled="loading"
          >
            <font-awesome-icon icon="file-excel" />
            Exportar a Excel
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 80px">Licencia</th>
                  <th>Propietario</th>
                  <th>RFC</th>
                  <th>Giro</th>
                  <th>Ubicación</th>
                  <th>Colonia</th>
                  <th style="width: 80px">Zona</th>
                  <th>Fecha Otorgamiento</th>
                  <th>Fecha Baja</th>
                  <th style="width: 100px">Estado</th>
                  <th style="width: 80px">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="lic in licencias" :key="lic.id_licencia" class="row-hover">
                  <td>
                    <strong class="text-primary">{{ lic.licencia }}</strong>
                  </td>
                  <td>{{ lic.propietarionvo || 'N/A' }}</td>
                  <td>
                    <code>{{ lic.rfc || 'N/A' }}</code>
                  </td>
                  <td>
                    <span class="badge-secondary">{{ lic.id_giro }}</span>
                  </td>
                  <td>
                    {{ lic.ubicacion }}
                    {{ lic.numext_ubic ? '#' + lic.numext_ubic : '' }}
                    {{ lic.letraext_ubic || '' }}
                  </td>
                  <td>{{ lic.colonia_ubic || 'N/A' }}</td>
                  <td class="text-center">
                    <span class="badge-info">{{ lic.zona || 'N/A' }}</span>
                  </td>
                  <td>
                    <small class="text-muted">
                      <font-awesome-icon icon="calendar" />
                      {{ formatDate(lic.fecha_otorgamiento) }}
                    </small>
                  </td>
                  <td>
                    <small class="text-danger">
                      <font-awesome-icon icon="ban" />
                      {{ formatDate(lic.fecha_baja) }}
                    </small>
                  </td>
                  <td>
                    <span class="badge badge-danger">
                      <font-awesome-icon icon="exclamation-circle" />
                      {{ getEstadoText(lic.bloqueado) }}
                    </span>
                  </td>
                  <td>
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewDetalle(lic)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Resumen -->
          <div class="table-summary">
            <div class="summary-item">
              <strong>Total de licencias suspendidas:</strong>
              <span class="badge-danger">{{ licencias.length }}</span>
            </div>
            <div class="summary-item">
              <strong>Periodo consultado:</strong>
              <span>{{ getPeriodoText() }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay datos -->
      <div class="municipal-card" v-if="!loading && licencias.length === 0 && reporteGenerado">
        <div class="municipal-card-body text-center text-muted">
          <font-awesome-icon icon="check-circle" size="3x" class="empty-icon" style="color: #28a745;" />
          <p>No se encontraron licencias suspendidas con los criterios especificados</p>
        </div>
      </div>
    </div>

    <!-- Modal de detalle -->
    <Modal
      :show="showDetailModal"
      title="Detalle de Licencia Suspendida"
      size="xl"
      @close="showDetailModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedLicencia" class="licencia-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información de la Licencia
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Licencia:</td>
                <td><strong>{{ selectedLicencia.licencia }}</strong></td>
              </tr>
              <tr>
                <td class="label">ID Licencia:</td>
                <td><code>{{ selectedLicencia.id_licencia }}</code></td>
              </tr>
              <tr>
                <td class="label">Empresa:</td>
                <td>{{ selectedLicencia.empresa || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo Registro:</td>
                <td>{{ selectedLicencia.tipo_registro || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Actividad:</td>
                <td>{{ selectedLicencia.actividad || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ selectedLicencia.propietarionvo }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ selectedLicencia.rfc || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">CURP:</td>
                <td><code>{{ selectedLicencia.curp || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ selectedLicencia.telefono_prop || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ selectedLicencia.email || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación del Establecimiento
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Calle:</td>
                <td>{{ selectedLicencia.ubicacion }}</td>
              </tr>
              <tr>
                <td class="label">Número:</td>
                <td>{{ selectedLicencia.numext_ubic }} {{ selectedLicencia.letraext_ubic }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedLicencia.colonia_ubic }}</td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td><span class="badge-info">Zona {{ selectedLicencia.zona }}</span></td>
              </tr>
              <tr>
                <td class="label">CP:</td>
                <td>{{ selectedLicencia.cp || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="ban" />
              Información de Suspensión
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge badge-danger">
                    {{ getEstadoText(selectedLicencia.bloqueado) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Otorgamiento:</td>
                <td>{{ formatDate(selectedLicencia.fecha_otorgamiento) }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Baja:</td>
                <td class="text-danger">{{ formatDate(selectedLicencia.fecha_baja) }}</td>
              </tr>
              <tr>
                <td class="label">Año Baja:</td>
                <td>{{ selectedLicencia.axo_baja || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Folio Baja:</td>
                <td>{{ selectedLicencia.folio_baja || 'N/A' }}</td>
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

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Generando reporte de licencias suspendidas...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'repsuspendidasfrm'"
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
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const licencias = ref([])
const selectedLicencia = ref(null)
const showDetailModal = ref(false)
const reporteGenerado = ref(false)

const filters = ref({
  tipoFiltro: 'year',
  year: new Date().getFullYear(),
  dateFrom: '',
  dateTo: '',
  tipoSuspension: '0'
})

// Computed
const isFormValid = computed(() => {
  if (filters.value.tipoFiltro === 'year') {
    return filters.value.year > 0
  } else if (filters.value.tipoFiltro === 'date') {
    return filters.value.dateFrom !== ''
  } else if (filters.value.tipoFiltro === 'range') {
    return filters.value.dateFrom !== '' && filters.value.dateTo !== ''
  }
  return false
})

// Métodos
const onTipoFiltroChange = () => {
  filters.value.dateFrom = ''
  filters.value.dateTo = ''
  if (filters.value.tipoFiltro === 'year') {
    filters.value.year = new Date().getFullYear()
  }
}

const generarReporte = async () => {
  if (!isFormValid.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Generando reporte...')
  reporteGenerado.value = false

  try {
    const params = []

    // Configurar parámetros según el tipo de filtro
    if (filters.value.tipoFiltro === 'year') {
      params.push({ nombre: 'p_year', valor: parseInt(filters.value.year), tipo: 'integer' })
      params.push({ nombre: 'p_date_from', valor: null, tipo: 'string' })
      params.push({ nombre: 'p_date_to', valor: null, tipo: 'string' })
    } else if (filters.value.tipoFiltro === 'date') {
      params.push({ nombre: 'p_year', valor: 0, tipo: 'integer' })
      params.push({ nombre: 'p_date_from', valor: filters.value.dateFrom, tipo: 'string' })
      params.push({ nombre: 'p_date_to', valor: null, tipo: 'string' })
    } else if (filters.value.tipoFiltro === 'range') {
      params.push({ nombre: 'p_year', valor: 0, tipo: 'integer' })
      params.push({ nombre: 'p_date_from', valor: filters.value.dateFrom, tipo: 'string' })
      params.push({ nombre: 'p_date_to', valor: filters.value.dateTo, tipo: 'string' })
    }

    params.push({ nombre: 'p_tipo_suspension', valor: parseInt(filters.value.tipoSuspension), tipo: 'integer' })

    const response = await execute(
      'REPORT_LICENCIAS_SUSPENDIDAS',
      'padron_licencias',
      params,
      'guadalajara'
    )

    if (response && response.result) {
      licencias.value = response.result
      reporteGenerado.value = true

      if (licencias.value.length > 0) {
        showToast('success', `Se encontraron ${licencias.value.length} licencias suspendidas`)
      } else {
        showToast('info', 'No se encontraron licencias suspendidas con los criterios especificados')
      }
    } else {
      licencias.value = []
      reporteGenerado.value = true
      showToast('info', 'No se encontraron resultados')
    }
  } catch (error) {
    handleApiError(error)
    licencias.value = []
    reporteGenerado.value = true
  } finally {
    setLoading(false)
  }
}

const exportarExcel = async () => {
  if (licencias.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay licencias para exportar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showToast('info', 'Función de exportación a Excel en desarrollo')
}

const viewDetalle = (licencia) => {
  selectedLicencia.value = licencia
  showDetailModal.value = true
}

const clearFilters = () => {
  filters.value = {
    tipoFiltro: 'year',
    year: new Date().getFullYear(),
    dateFrom: '',
    dateTo: '',
    tipoSuspension: '0'
  }
  licencias.value = []
  reporteGenerado.value = false
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

const getEstadoText = (bloqueado) => {
  const estados = {
    1: 'Suspensión Admin.',
    2: 'Suspensión Adeudo',
    3: 'Suspensión Temp.',
    4: 'Cancelación Def.'
  }
  return estados[bloqueado] || 'Suspendida'
}

const getPeriodoText = () => {
  if (filters.value.tipoFiltro === 'year') {
    return `Año ${filters.value.year}`
  } else if (filters.value.tipoFiltro === 'date') {
    return `Fecha: ${formatDate(filters.value.dateFrom)}`
  } else if (filters.value.tipoFiltro === 'range') {
    return `Del ${formatDate(filters.value.dateFrom)} al ${formatDate(filters.value.dateTo)}`
  }
  return 'N/A'
}

// Lifecycle
onMounted(() => {
  // Inicialización si es necesario
})
</script>

<style scoped>
.table-summary {
  margin-top: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.detail-section {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.section-title {
  font-size: 14px;
  font-weight: bold;
  color: #ea8215;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 2px solid #ea8215;
}

.detail-table {
  width: 100%;
}

.detail-table tr {
  border-bottom: 1px solid #e9ecef;
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 8px 0;
  font-size: 14px;
}

.detail-table td.label {
  width: 150px;
  font-weight: 600;
  color: #6c757d;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #dee2e6;
}
</style>
