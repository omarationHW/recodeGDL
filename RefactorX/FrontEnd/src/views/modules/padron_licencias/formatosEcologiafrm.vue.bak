<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="leaf" />
      </div>
      <div class="module-view-info">
        <h1>Formatos de Ecología</h1>
        <p>Padrón de Licencias - Generación de Formatos Ecológicos para Trámites</p></div>
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
          @click="generarReporte"
          :disabled="loading || tramites.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          Generar Reporte
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
            <label class="municipal-form-label">Fecha de Captura <span class="required">*</span></label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fecha"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Trámite (Búsqueda Directa)</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.id_tramite"
              placeholder="Buscar por ID específico"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchTramites"
            :disabled="loading || (!filters.fecha && !filters.id_tramite)"
          >
            <font-awesome-icon icon="search" />
            Buscar Trámites
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            v-if="filters.id_tramite"
            class="btn-municipal-info"
            @click="buscarPorId"
            :disabled="loading || !filters.id_tramite"
          >
            <font-awesome-icon icon="search-plus" />
            Buscar por ID
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Trámites Capturados
          <span class="badge-info" v-if="tramites.length > 0">{{ tramites.length }} trámites</span>
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
                <th>ID Trámite</th>
                <th>Folio</th>
                <th>Tipo</th>
                <th>Actividad</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Zona/Subzona</th>
                <th>Fecha Captura</th>
                <th>Estatus</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tramite in tramites" :key="tramite.id_tramite" class="row-hover">
                <td><strong class="text-primary">{{ tramite.id_tramite }}</strong></td>
                <td><code class="text-muted">{{ tramite.folio }}</code></td>
                <td>
                  <span class="badge-secondary">{{ tramite.tipo_tramite || 'N/A' }}</span>
                </td>
                <td>
                  <small class="actividad-text">{{ tramite.actividad?.trim() || 'N/A' }}</small>
                </td>
                <td>{{ tramite.propietarionvo?.trim() || tramite.propietario?.trim() || 'N/A' }}</td>
                <td>
                  <small class="domicilio-text">{{ tramite.domcompleto?.trim() || tramite.ubicacion?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <div class="zona-info">
                    <span class="badge-info">Z: {{ tramite.zona || tramite.zona_1 || 'N/A' }}</span>
                    <span class="badge-info">SZ: {{ tramite.subzona || tramite.subzona_1 || 'N/A' }}</span>
                  </div>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(tramite.feccap) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getEstatusBadgeClass(tramite.estatus)">
                    {{ tramite.estatus || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewTramite(tramite)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="verCruceCalles(tramite.id_tramite)"
                      title="Ver cruce de calles"
                    >
                      <font-awesome-icon icon="road" />
                    </button>
                    <button
                      class="btn-municipal-success btn-sm"
                      @click="generarFormato(tramite)"
                      title="Generar formato"
                    >
                      <font-awesome-icon icon="file-alt" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="tramites.length === 0 && !loading">
                <td colspan="10" class="text-center text-muted">
                  <font-awesome-icon icon="calendar-times" size="2x" class="empty-icon" />
                  <p>No se encontraron trámites para la fecha seleccionada</p>
                  <p><small>Seleccione una fecha y presione Buscar</small></p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && tramites.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando trámites...</p>
      </div>
    </div>

    <!-- Modal de visualización de trámite -->
    <Modal
      :show="showViewModal"
      :title="`Detalle del Trámite ${selectedTramite?.id_tramite}`"
      size="xl"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedTramite" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="file-alt" />
              Información del Trámite
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Trámite:</td>
                <td><code>{{ selectedTramite.id_tramite }}</code></td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td>{{ selectedTramite.folio }}</td>
              </tr>
              <tr>
                <td class="label">Tipo Trámite:</td>
                <td>{{ selectedTramite.tipo_tramite || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Actividad:</td>
                <td>{{ selectedTramite.actividad?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>{{ selectedTramite.id_giro || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Estatus:</td>
                <td>
                  <span class="badge" :class="getEstatusBadgeClass(selectedTramite.estatus)">
                    {{ selectedTramite.estatus || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ selectedTramite.propietarionvo?.trim() || selectedTramite.propietario?.trim() || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td>{{ selectedTramite.rfc?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CURP:</td>
                <td>{{ selectedTramite.curp?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>
                  <font-awesome-icon icon="phone" class="text-info" />
                  {{ selectedTramite.telefono_prop?.trim() || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ selectedTramite.email?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label" colspan="2">Domicilio Completo:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedTramite.domcompleto?.trim() || selectedTramite.ubicacion?.trim() || 'N/A' }}
                  </div>
                </td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedTramite.colonia_ubic?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CP:</td>
                <td>{{ selectedTramite.cp || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td><span class="badge-secondary">{{ selectedTramite.zona || selectedTramite.zona_1 || 'N/A' }}</span></td>
              </tr>
              <tr>
                <td class="label">Subzona:</td>
                <td><span class="badge-secondary">{{ selectedTramite.subzona || selectedTramite.subzona_1 || 'N/A' }}</span></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="tools" />
              Datos Técnicos
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Sup. Construida:</td>
                <td>{{ selectedTramite.sup_construida || 'N/A' }} m²</td>
              </tr>
              <tr>
                <td class="label">Sup. Autorizada:</td>
                <td>{{ selectedTramite.sup_autorizada || 'N/A' }} m²</td>
              </tr>
              <tr>
                <td class="label">Num. Cajones:</td>
                <td>{{ selectedTramite.num_cajones || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Num. Empleados:</td>
                <td>{{ selectedTramite.num_empleados || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Aforo:</td>
                <td>{{ selectedTramite.aforo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Inversión:</td>
                <td>{{ formatCurrency(selectedTramite.inversion) }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedTramite.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturista:</td>
                <td>{{ selectedTramite.capturista?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="verCruceCalles(selectedTramite.id_tramite)">
            <font-awesome-icon icon="road" />
            Ver Cruce de Calles
          </button>
          <button class="btn-municipal-success" @click="generarFormato(selectedTramite)">
            <font-awesome-icon icon="file-alt" />
            Generar Formato
          </button>
        </div>
      </div>
    </Modal>

    <!-- Modal de cruce de calles -->
    <Modal
      :show="showCruceModal"
      :title="`Cruce de Calles - Trámite ${selectedIdTramite}`"
      size="lg"
      @close="showCruceModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="cruceCalles.length > 0">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Calle 1</th>
                <th>Calle 2</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(cruce, index) in cruceCalles" :key="index">
                <td>{{ cruce.calle }}</td>
                <td>{{ cruce.calle_1 }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else class="text-center text-muted py-4">
        <font-awesome-icon icon="road" size="2x" class="empty-icon" />
        <p>No hay cruces de calles registrados para este trámite</p>
      </div>
      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="showCruceModal = false">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </Modal>

    <!-- Toast Notification -->
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
      :componentName="'formatosEcologiafrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
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
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const tramites = ref([])
const selectedTramite = ref(null)
const selectedIdTramite = ref(null)
const cruceCalles = ref([])
const showViewModal = ref(false)
const showCruceModal = ref(false)

// Filtros
const filters = ref({
  fecha: '',
  id_tramite: null
})

// Métodos
const loadTramitesByFecha = async () => {
  if (!filters.value.fecha) {
    showToast('warning', 'Por favor seleccione una fecha')
    return
  }

  setLoading(true, 'Cargando trámites...')

  try {
    const response = await execute(
      'SP_GET_TRAMITES_BY_FECHA',
      'padron_licencias',
      [
        { nombre: 'p_fecha', valor: filters.value.fecha, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      tramites.value = response.result
      showToast('success', `Se encontraron ${tramites.value.length} trámites`)
    } else {
      tramites.value = []
      showToast('info', 'No se encontraron trámites para la fecha seleccionada')
    }
  } catch (error) {
    handleApiError(error)
    tramites.value = []
  } finally {
    setLoading(false)
  }
}

const loadTramiteById = async () => {
  if (!filters.value.id_tramite) {
    showToast('warning', 'Por favor ingrese un ID de trámite')
    return
  }

  setLoading(true, 'Buscando trámite...')

  try {
    const response = await execute(
      'SP_GET_TRAMITE_BY_ID',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(filters.value.id_tramite), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramites.value = response.result
      showToast('success', 'Trámite encontrado')
    } else {
      tramites.value = []
      showToast('warning', 'No se encontró el trámite con ese ID')
    }
  } catch (error) {
    handleApiError(error)
    tramites.value = []
  } finally {
    setLoading(false)
  }
}

const searchTramites = () => {
  if (filters.value.id_tramite) {
    loadTramiteById()
  } else if (filters.value.fecha) {
    loadTramitesByFecha()
  } else {
    showToast('warning', 'Por favor seleccione una fecha o ingrese un ID de trámite')
  }
}

const buscarPorId = () => {
  loadTramiteById()
}

const clearFilters = () => {
  filters.value = {
    fecha: '',
    id_tramite: null
  }
  tramites.value = []
}

const viewTramite = (tramite) => {
  selectedTramite.value = tramite
  showViewModal.value = true
}

const verCruceCalles = async (id_tramite) => {
  selectedIdTramite.value = id_tramite
  setLoading(true, 'Cargando cruce de calles...')

  try {
    const response = await execute(
      'SP_GET_CRUCE_CALLES_BY_TRAMITE',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(id_tramite), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      cruceCalles.value = response.result
      showCruceModal.value = true
    } else {
      cruceCalles.value = []
      showCruceModal.value = true
    }
  } catch (error) {
    handleApiError(error)
    cruceCalles.value = []
  } finally {
    setLoading(false)
  }
}

const generarFormato = async (tramite) => {
  await Swal.fire({
    icon: 'info',
    title: 'Generar Formato de Ecología',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p><strong>Trámite:</strong> ${tramite.id_tramite}</p>
        <p><strong>Propietario:</strong> ${tramite.propietarionvo || tramite.propietario}</p>
        <p><strong>Actividad:</strong> ${tramite.actividad}</p>
        <p style="margin-top: 15px;">La funcionalidad de generación de formato está en desarrollo.</p>
      </div>
    `,
    confirmButtonColor: '#ea8215'
  })
}

const generarReporte = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Generar Reporte',
    text: `Se generará un reporte con ${tramites.value.length} trámites. Funcionalidad en desarrollo.`,
    confirmButtonColor: '#ea8215'
  })
}

// Utilidades
const getEstatusBadgeClass = (estatus) => {
  const classes = {
    'T': 'badge-warning',
    'A': 'badge-success',
    'R': 'badge-danger',
    'P': 'badge-info'
  }
  return classes[estatus] || 'badge-secondary'
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

const formatCurrency = (value) => {
  if (!value) return 'N/A'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return value
  }
}

// Lifecycle
onMounted(() => {
  // Establecer fecha actual por defecto
  const today = new Date()
  filters.value.fecha = today.toISOString().split('T')[0]
})

onBeforeUnmount(() => {
  showViewModal.value = false
  showCruceModal.value = false
})
</script>

<style scoped>
.zona-info {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.domicilio-text {
  display: block;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.actividad-text {
  display: block;
  max-width: 180px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.observaciones-box {
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #dee2e6;
  min-height: 40px;
  white-space: pre-wrap;
}

.details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

@media (max-width: 768px) {
  .details-grid {
    grid-template-columns: 1fr;
  }
}

.required {
  color: #dc3545;
}

.empty-icon {
  color: #6c757d;
  margin-bottom: 10px;
}
</style>
