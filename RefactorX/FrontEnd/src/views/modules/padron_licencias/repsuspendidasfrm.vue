<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Licencias Suspendidas</h1>
        <p>Padrón de Licencias - Consulta de Licencias con Suspensión o Bloqueo</p>
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
              >
            </div>

            <!-- Filtro por fecha específica -->
            <div class="form-group" v-if="filters.tipoFiltro === 'date'">
              <label class="municipal-form-label">Fecha: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.dateFrom"
              >
            </div>

            <!-- Filtro por rango -->
            <div class="form-group" v-if="filters.tipoFiltro === 'range'">
              <label class="municipal-form-label">Fecha Inicio: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.dateFrom"
              >
            </div>
            <div class="form-group" v-if="filters.tipoFiltro === 'range'">
              <label class="municipal-form-label">Fecha Fin: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.dateTo"
              >
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Tipo de Suspensión:</label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoSuspension"
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
              :disabled="!isFormValid"
            >
              <font-awesome-icon icon="search" />
              Generar Reporte
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="licencias.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Licencias Suspendidas
          </h5>
          <div class="header-right">
            <span class="badge-danger" v-if="licencias.length > 0">
              {{ licencias.length }} licencias
            </span>
            <button
              class="btn-municipal-primary"
              @click="exportarExcel"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="th-w-10">Licencia</th>
                  <th class="th-w-15">Propietario</th>
                  <th class="th-w-10">RFC</th>
                  <th class="th-w-10">Giro</th>
                  <th class="th-w-20">Ubicación</th>
                  <th class="th-w-15">Colonia</th>
                  <th class="th-w-10">Zona</th>
                  <th class="th-w-15">Fecha Otorgamiento</th>
                  <th class="th-w-15">Fecha Baja</th>
                  <th class="th-w-10">Estado</th>
                  <th class="th-w-10">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="lic in licencias"
                  :key="lic.id_licencia"
                  @click="selectedRow = lic"
                  :class="{ 'table-row-selected': selectedRow === lic }"
                  class="row-hover"
                >
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
                    <span class="badge-purple">{{ lic.zona || 'N/A' }}</span>
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
                      @click.stop="viewDetalle(lic)"
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

      <!-- Empty State - Sin búsqueda -->
      <div v-if="licencias.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="ban" size="3x" />
        </div>
        <h4>Reporte de Licencias Suspendidas</h4>
        <p>Configure los criterios de búsqueda y presione "Generar Reporte" para consultar las licencias suspendidas o bloqueadas</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="licencias.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron licencias suspendidas con los criterios especificados</p>
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
        :componentName="'repsuspendidasfrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Reporte de Licencias Suspendidas'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->

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
                <td><span class="badge-purple">Zona {{ selectedLicencia.zona }}</span></td>
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
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useExcelExport } from '@/composables/useExcelExport'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

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
const { exportToExcel } = useExcelExport()

// Estado
const licencias = ref([])
const selectedLicencia = ref(null)
const selectedRow = ref(null)
const showDetailModal = ref(false)
const reporteGenerado = ref(false)
const hasSearched = ref(false)

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

  showLoading('Generando reporte de licencias suspendidas...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null
  reporteGenerado.value = false

  try {
    const startTime = performance.now()

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
      'report_licencias_suspendidas',
      'padron_licencias',
      params,
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      licencias.value = response.result
      reporteGenerado.value = true

      if (licencias.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${licencias.value.length} licencias suspendidas`)
      } else {
        toast.value.duration = durationText
        showToast('info', 'No se encontraron licencias suspendidas con los criterios especificados')
      }
    } else {
      licencias.value = []
      reporteGenerado.value = true
      toast.value.duration = durationText
      showToast('info', 'No se encontraron resultados')
    }
  } catch (error) {
    handleApiError(error)
    licencias.value = []
    reporteGenerado.value = true
  } finally {
    hideLoading()
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

  try {
    const columns = [
      { header: 'Licencia', key: 'licencia', width: 15 },
      { header: 'Propietario', key: 'propietarionvo', width: 35 },
      { header: 'RFC', key: 'rfc', width: 15 },
      { header: 'ID Giro', key: 'id_giro', width: 10 },
      { header: 'Ubicación', key: 'ubicacion', width: 30 },
      { header: 'Núm. Ext.', key: 'numext_ubic', width: 10 },
      { header: 'Colonia', key: 'colonia_ubic', width: 25 },
      { header: 'Zona', key: 'zona', width: 8 },
      { header: 'Fecha Otorgamiento', key: 'fecha_otorgamiento', type: 'date', width: 18 },
      { header: 'Fecha Baja', key: 'fecha_baja', type: 'date', width: 15 },
      { header: 'Tipo Bloqueo', key: 'bloqueado', width: 12 }
    ]

    const filename = `Licencias_Suspendidas_${getPeriodoText().replace(/[/\s:]/g, '_')}`
    const success = exportToExcel(licencias.value, columns, filename, 'Licencias_Suspendidas')

    if (success) {
      showToast('success', `Excel exportado: ${licencias.value.length} licencias`)
    } else {
      showToast('error', 'Error al exportar Excel')
    }
  } catch (error) {
    showToast('error', 'Error al generar el archivo Excel')
  }
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
  hasSearched.value = false
  selectedRow.value = null
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

