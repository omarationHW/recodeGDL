<template>
  <div class="module-view">
    <!-- Navigation Header -->
    <div class="navigation-header">
      <button
        type="button"
        class="btn-nav-back"
        @click="router.push({ name: 'ConsultaTramitefrm' })"
        title="Regresar a Consulta de Trámites"
      >
        <font-awesome-icon icon="arrow-left" />
        <span>Regresar a Consulta</span>
      </button>
      <button
        type="button"
        class="btn-nav-help"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
        <span>Ayuda</span>
      </button>
    </div>

    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="redo" />
      </div>
      <div class="module-view-info">
        <h1>Reactivar Trámite</h1>
        <p>Padrón de Licencias - Reactivación de trámites cancelados</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Trámite (Collapsible) -->
      <div class="municipal-card">
        <div
          class="accordion-header"
          :class="{ 'collapsed': !searchPanelExpanded }"
          @click="searchPanelExpanded = !searchPanelExpanded"
        >
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Trámite Cancelado
          </h5>
          <font-awesome-icon :icon="searchPanelExpanded ? 'chevron-up' : 'chevron-down'" />
        </div>
        <div v-show="searchPanelExpanded" class="municipal-card-body">
          <form @submit.prevent="buscarTramite">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">ID del Trámite:</label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="searchTramite"
                    placeholder="Ingrese ID del trámite"
                    required
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="!searchTramite"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Giro:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  :value="giroDescripcion"
                  disabled
                />
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="!tramiteData" class="empty-state-card">
        <div class="empty-state-icon">
          <font-awesome-icon icon="search" />
        </div>
        <h3>Busque un trámite cancelado</h3>
        <p>Ingrese el ID del trámite que desea reactivar</p>
      </div>

      <!-- Información del Trámite -->
      <div class="municipal-card" v-if="tramiteData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="file-invoice" />
            Información del Trámite #{{ tramiteData.id_tramite }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="tramite-details-grid">
            <!-- Sección 1: Datos Generales -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="info-circle" /> Datos Generales
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">ID Trámite:</span>
                <span class="tramite-detail-value"><strong>{{ tramiteData.id_tramite }}</strong></span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Folio:</span>
                <span class="tramite-detail-value">{{ tramiteData.licencia || 'S/F' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Tipo Trámite:</span>
                <span class="tramite-detail-value">{{ tramiteData.tipo_tramite || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Fecha Captura:</span>
                <span class="tramite-detail-value">{{ formatDate(tramiteData.feccap) }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Estado Actual:</span>
                <span class="tramite-detail-value">
                  <span :class="getEstadoBadgeClass(tramiteData.estatus)" class="badge">
                    <font-awesome-icon :icon="getEstadoIcon(tramiteData.estatus)" />
                    {{ getEstadoText(tramiteData.estatus) }}
                  </span>
                </span>
              </div>
            </div>

            <!-- Sección 2: Giro y Actividad -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="briefcase" /> Giro y Actividad
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Giro:</span>
                <span class="tramite-detail-value">{{ giroDescripcion || tramiteData.id_giro || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Actividad:</span>
                <span class="tramite-detail-value">{{ tramiteData.actividad || 'N/A' }}</span>
              </div>
            </div>

            <!-- Sección 3: Información del Solicitante -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="user" /> Información del Solicitante
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Propietario:</span>
                <span class="tramite-detail-value">{{ tramiteData.propietario || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">RFC:</span>
                <span class="tramite-detail-value">{{ tramiteData.rfc || 'N/A' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">CURP:</span>
                <span class="tramite-detail-value">{{ tramiteData.curp || 'N/A' }}</span>
              </div>
            </div>

            <!-- Sección 4: Ubicación -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="map-marker-alt" /> Ubicación
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Domicilio:</span>
                <span class="tramite-detail-value">{{ tramiteData.ubicacion || 'N/A' }}</span>
              </div>
            </div>

            <!-- Sección 5: Información de Cancelación -->
            <div class="tramite-detail-section">
              <h6 class="tramite-section-title">
                <font-awesome-icon icon="times-circle" /> Información de Cancelación
              </h6>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Fecha Cancelación:</span>
                <span class="tramite-detail-value">{{ formatDate(tramiteData.fec_cancel) }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Motivo Cancelación:</span>
                <span class="tramite-detail-value">{{ tramiteData.observaciones || 'Sin motivo registrado' }}</span>
              </div>
              <div class="tramite-detail-row">
                <span class="tramite-detail-label">Usuario Captura:</span>
                <span class="tramite-detail-value">{{ tramiteData.capturista || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <!-- Validación de estado -->
          <div class="alert alert-danger" v-if="tramiteData.estatus !== 'C'">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Este trámite NO puede ser reactivado</strong>
            <p class="mb-0">Solo se pueden reactivar trámites con estatus <strong>CANCELADO (C)</strong>. Estado actual: <strong>{{ getEstadoText(tramiteData.estatus) }}</strong></p>
          </div>

          <!-- Formulario de Reactivación -->
          <div class="mt-4" v-if="tramiteData.estatus === 'C'">
            <h6 class="section-title">
              <font-awesome-icon icon="redo" />
              Reactivar Trámite
            </h6>
            <form @submit.prevent="confirmarReactivacion">
              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">Motivo de la reactivación *:</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="reactivacionForm.motivo"
                    rows="4"
                    maxlength="500"
                    placeholder="Ingrese el motivo detallado de la reactivación del trámite"
                    required
                  ></textarea>
                  <small class="form-text text-muted">
                    {{ reactivacionForm.motivo.length }}/500 caracteres - Explique claramente por qué se debe reactivar este trámite cancelado
                  </small>
                </div>
              </div>

              <div class="alert alert-info">
                <font-awesome-icon icon="info-circle" />
                <strong>Información:</strong> Al reactivar el trámite, su estado cambiará de <strong>CANCELADO (C)</strong> a <strong>EN PROCESO (T)</strong> y podrá continuar con el flujo normal.
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-success"
                  >
                    <font-awesome-icon icon="redo" /> Reactivar Trámite
                  </button>
                  <button
                    type="button"
                    class="btn-municipal-secondary ms-2"
                    @click="limpiarFormulario"
                  >
                    <font-awesome-icon icon="times" /> Cancelar
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ReactivaTramite'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// UI State
const searchPanelExpanded = ref(true)

// Estado
const searchTramite = ref(null)
const tramiteData = ref(null)
const giroDescripcion = ref('')

const reactivacionForm = ref({
  motivo: ''
})

// Restore state on mount
onMounted(() => {
  const savedSearch = localStorage.getItem('reactivatramite_search')
  if (savedSearch) {
    searchTramite.value = parseInt(savedSearch)
    buscarTramite()
  }
})

// Métodos
const buscarTramite = async () => {
  if (!searchTramite.value) return

  // Save search to localStorage
  localStorage.setItem('reactivatramite_search', searchTramite.value.toString())

  const startTime = Date.now()
  showLoading('Buscando trámite...', 'Consultando base de datos')

  try {
    const response = await execute(
      'sp_get_tramite_by_id',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    hideLoading()
    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      tramiteData.value = response.result[0]
      searchPanelExpanded.value = false // Collapse search panel after successful search

      // Cargar descripción del giro
      await cargarGiroDescripcion()

      if (tramiteData.value.estatus === 'C') {
        showToast('success', `Trámite cancelado encontrado (${duration}s) - Puede reactivarlo`, 3000, 'bottom-right')
      } else {
        showToast('warning', `Trámite encontrado (${duration}s) pero no está cancelado`, 3000, 'bottom-right')
      }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El trámite no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      tramiteData.value = null
      giroDescripcion.value = ''
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    tramiteData.value = null
    giroDescripcion.value = ''
  }
}

const cargarGiroDescripcion = async () => {
  if (!tramiteData.value?.id_giro) return

  try {
    const response = await execute(
      'sp_get_giro_by_id',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: tramiteData.value.id_giro, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      giroDescripcion.value = response.result[0].descripcion
    }
  } catch (error) {
    giroDescripcion.value = tramiteData.value.id_giro?.toString() || ''
  }
}

const confirmarReactivacion = async () => {
  // Validaciones
  if (!reactivacionForm.value.motivo.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Motivo requerido',
      text: 'Debe ingresar el motivo de la reactivación',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (tramiteData.value.estatus !== 'C') {
    await Swal.fire({
      icon: 'error',
      title: 'Estado inválido',
      text: 'Solo se pueden reactivar trámites cancelados',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación única
  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Reactivar trámite?',
    html: `
      <div style="text-align: left;">
        <p><strong>Trámite:</strong> #${tramiteData.value.id_tramite}</p>
        <p><strong>Folio:</strong> ${tramiteData.value.licencia || 'S/F'}</p>
        <p><strong>Estado actual:</strong> <span class="badge badge-danger">CANCELADO</span></p>
        <p><strong>Nuevo estado:</strong> <span class="badge badge-purple">EN PROCESO</span></p>
        <hr>
        <p><strong>Motivo de reactivación:</strong></p>
        <p style="background: #f8f9fa; padding: 10px; border-left: 3px solid #ea8215;">${reactivacionForm.value.motivo}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: '<i class="fas fa-redo"></i> Sí, reactivar',
    cancelButtonText: '<i class="fas fa-times"></i> Cancelar',
    customClass: {
      popup: 'swal-wide'
    }
  })

  if (!confirm.isConfirmed) return

  const startTime = Date.now()
  showLoading('Reactivando trámite...', 'Procesando reactivación')

  try {
    const response = await execute(
      'sp_reactivar_tramite',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' },
        { nombre: 'p_motivo', valor: reactivacionForm.value.motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: localStorage.getItem('usuario') || 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'comun'
    )

    hideLoading()
    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]?.success) {
      // Actualizar el estatus localmente
      if (tramiteData.value) {
        tramiteData.value.estatus = 'T'
      }

      await Swal.fire({
        icon: 'success',
        title: 'Trámite reactivado',
        html: `
          <p>${response.result[0].message}</p>
          <p class="text-success"><strong>El trámite ahora está EN PROCESO (T)</strong></p>
          <p class="text-muted">Tiempo de operación: ${duration}s</p>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('success', `Trámite reactivado exitosamente (${duration}s)`, 3000, 'bottom-right')

      // Limpiar formulario pero mantener los datos del trámite para que vea el cambio
      reactivacionForm.value.motivo = ''
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al reactivar',
        text: response?.result?.[0]?.message || 'No se pudo reactivar el trámite',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const limpiarFormulario = () => {
  searchTramite.value = null
  tramiteData.value = null
  giroDescripcion.value = ''
  reactivacionForm.value = {
    motivo: ''
  }
  searchPanelExpanded.value = true
  localStorage.removeItem('reactivatramite_search')
}

const getEstadoBadgeClass = (estatus) => {
  const classes = {
    'A': 'badge-success',
    'P': 'badge-warning',
    'C': 'badge-danger',
    'T': 'badge-purple',
    'R': 'badge-secondary'
  }
  return classes[estatus] || 'badge-secondary'
}

const getEstadoText = (estatus) => {
  const estados = {
    'A': 'Autorizado',
    'P': 'Pendiente',
    'C': 'Cancelado',
    'T': 'En Proceso',
    'R': 'Rechazado'
  }
  return estados[estatus] || 'Desconocido'
}

const getEstadoIcon = (estatus) => {
  const icons = {
    'A': 'check-circle',
    'P': 'clock',
    'C': 'times-circle',
    'T': 'spinner',
    'R': 'ban'
  }
  return icons[estatus] || 'question-circle'
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
</script>

