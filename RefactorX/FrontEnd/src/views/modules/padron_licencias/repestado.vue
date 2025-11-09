<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Estado de Trámites</h1>
        <p>Padrón de Licencias - Seguimiento y Estado de Trámites</p></div>
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
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Trámite
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Trámite: <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filters.idTramite"
                placeholder="Ingrese el ID del trámite"
                :disabled="loading"
                @keyup.enter="consultarTramite"
              >
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="consultarTramite"
              :disabled="loading || !filters.idTramite"
            >
              <font-awesome-icon icon="search" />
              Consultar Estado
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
              v-if="tramite"
              class="btn-municipal-info"
              @click="exportarReporte"
              :disabled="loading"
            >
              <font-awesome-icon icon="file-pdf" />
              Generar PDF
            </button>
          </div>
        </div>
      </div>

      <!-- Información del trámite -->
      <div class="municipal-card" v-if="tramite">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Trámite
            <span class="badge" :class="getEstadoBadgeClass(tramite.estatus)">
              {{ tramite.estatus || 'Sin estado' }}
            </span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="file-alt" />
                Datos Generales
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">ID Trámite:</td>
                  <td><strong>{{ tramite.id_tramite }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Folio:</td>
                  <td><code>{{ tramite.folio || 'N/A' }}</code></td>
                </tr>
                <tr>
                  <td class="label">Tipo de Trámite:</td>
                  <td><span class="badge-purple">{{ tramite.tipo_tramite || 'N/A' }}</span></td>
                </tr>
                <tr>
                  <td class="label">Fecha Captura:</td>
                  <td>
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(tramite.feccap) }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Capturado por:</td>
                  <td>{{ tramite.capturista || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Información del Propietario
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Nombre:</td>
                  <td><strong>{{ tramite.propietarionvo || 'N/A' }}</strong></td>
                </tr>
                <tr>
                  <td class="label">RFC:</td>
                  <td><code>{{ tramite.rfc || 'N/A' }}</code></td>
                </tr>
                <tr>
                  <td class="label">CURP:</td>
                  <td><code>{{ tramite.curp || 'N/A' }}</code></td>
                </tr>
                <tr>
                  <td class="label">Teléfono:</td>
                  <td>{{ tramite.telefono_prop || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Email:</td>
                  <td>{{ tramite.email || 'N/A' }}</td>
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
                  <td class="label">Calle:</td>
                  <td>{{ tramite.ubicacion || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Número Ext.:</td>
                  <td>{{ tramite.numext_ubic || 'N/A' }} {{ tramite.letraext_ubic || '' }}</td>
                </tr>
                <tr>
                  <td class="label">Número Int.:</td>
                  <td>{{ tramite.numint_ubic || 'N/A' }} {{ tramite.letraint_ubic || '' }}</td>
                </tr>
                <tr>
                  <td class="label">Colonia:</td>
                  <td>{{ tramite.colonia_ubic || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Zona:</td>
                  <td><span class="badge-secondary">Zona {{ tramite.zona || 'N/A' }}</span></td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="building" />
                Información del Establecimiento
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Giro:</td>
                  <td><span class="badge-purple">ID: {{ tramite.id_giro || 'N/A' }}</span></td>
                </tr>
                <tr>
                  <td class="label">Actividad:</td>
                  <td>{{ tramite.actividad || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Superficie Construida:</td>
                  <td>{{ tramite.sup_construida || 0 }} m²</td>
                </tr>
                <tr>
                  <td class="label">Superficie Autorizada:</td>
                  <td>{{ tramite.sup_autorizada || 0 }} m²</td>
                </tr>
                <tr>
                  <td class="label">Número de Empleados:</td>
                  <td>{{ tramite.num_empleados || 0 }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Observaciones -->
          <div v-if="tramite.observaciones" class="detail-section full-width">
            <h6 class="section-title">
              <font-awesome-icon icon="comment-alt" />
              Observaciones
            </h6>
            <div class="observaciones-box">
              {{ tramite.observaciones }}
            </div>
          </div>
        </div>
      </div>

      <!-- Historial de revisiones -->
      <div class="municipal-card" v-if="revisiones.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="history" />
            Historial de Revisiones
            <span class="badge-purple" v-if="revisiones.length > 0">{{ revisiones.length }} revisiones</span>
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
          <div class="timeline">
            <div
              v-for="(revision, index) in revisiones"
              :key="revision.id_revision"
              class="timeline-item"
            >
              <div class="timeline-marker" :class="getRevisionMarkerClass(revision.resultado)">
                <font-awesome-icon :icon="getRevisionIcon(revision.resultado)" />
              </div>
              <div class="timeline-content">
                <div class="timeline-header">
                  <h6>
                    Revisión #{{ revision.id_revision }}
                    <span class="badge" :class="getRevisionBadgeClass(revision.resultado)">
                      {{ revision.resultado || 'Pendiente' }}
                    </span>
                  </h6>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(revision.fecha_revision) }}
                  </small>
                </div>
                <div class="timeline-body">
                  <p><strong>Dependencia:</strong> {{ revision.dependencia || 'N/A' }}</p>
                  <p v-if="revision.usuario_reviso"><strong>Revisó:</strong> {{ revision.usuario_reviso }}</p>
                  <p v-if="revision.observaciones" class="observaciones">
                    <strong>Observaciones:</strong> {{ revision.observaciones }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay datos -->
      <div class="municipal-card" v-if="!loading && !tramite && filters.idTramite">
        <div class="municipal-card-body text-center text-muted">
          <font-awesome-icon icon="search" size="3x" class="empty-icon" />
          <p>No se encontró el trámite con ID: {{ filters.idTramite }}</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Consultando estado del trámite...</p>
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
      :componentName="'repestado'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
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
const tramite = ref(null)
const revisiones = ref([])
const filters = ref({
  idTramite: ''
})

// Métodos
const consultarTramite = async () => {
  if (!filters.value.idTramite) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el ID del trámite',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Consultando trámite...')

  try {
    // Obtener datos del trámite
    const responseTramite = await execute(
      'sp_get_tramite_estado',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(filters.value.idTramite), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (responseTramite && responseTramite.result && responseTramite.result.length > 0) {
      tramite.value = responseTramite.result[0]
      showToast('success', 'Trámite encontrado')

      // Cargar revisiones
      await loadRevisiones()
    } else {
      tramite.value = null
      revisiones.value = []
      showToast('warning', 'No se encontró el trámite')
    }
  } catch (error) {
    handleApiError(error)
    tramite.value = null
    revisiones.value = []
  } finally {
    setLoading(false)
  }
}

const loadRevisiones = async () => {
  try {
    const response = await execute(
      'sp_get_tramite_revisiones',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(filters.value.idTramite), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      revisiones.value = response.result
    } else {
      revisiones.value = []
    }
  } catch (error) {
    revisiones.value = []
  }
}

const exportarReporte = async () => {
  if (!tramite.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay un trámite consultado',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showToast('info', 'Función de generación de PDF en desarrollo')
}

const exportarExcel = async () => {
  if (revisiones.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay revisiones para exportar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showToast('info', 'Función de exportación a Excel en desarrollo')
}

const clearFilters = () => {
  filters.value.idTramite = ''
  tramite.value = null
  revisiones.value = []
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const getEstadoBadgeClass = (estatus) => {
  const classes = {
    'APROBADO': 'badge-success',
    'RECHAZADO': 'badge-danger',
    'EN_REVISION': 'badge-warning',
    'PENDIENTE': 'badge-secondary'
  }
  return classes[estatus] || 'badge-secondary'
}

const getRevisionBadgeClass = (resultado) => {
  const classes = {
    'APROBADO': 'badge-success',
    'RECHAZADO': 'badge-danger',
    'OBSERVACIONES': 'badge-warning',
    'PENDIENTE': 'badge-secondary'
  }
  return classes[resultado] || 'badge-secondary'
}

const getRevisionMarkerClass = (resultado) => {
  const classes = {
    'APROBADO': 'timeline-marker-success',
    'RECHAZADO': 'timeline-marker-danger',
    'OBSERVACIONES': 'timeline-marker-warning',
    'PENDIENTE': 'timeline-marker-secondary'
  }
  return classes[resultado] || 'timeline-marker-secondary'
}

const getRevisionIcon = (resultado) => {
  const icons = {
    'APROBADO': 'check-circle',
    'RECHAZADO': 'times-circle',
    'OBSERVACIONES': 'exclamation-triangle',
    'PENDIENTE': 'clock'
  }
  return icons[resultado] || 'circle'
}

// Lifecycle
onMounted(() => {
  // Inicialización si es necesario
})
</script>

