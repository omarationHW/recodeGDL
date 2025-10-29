<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="redo" />
      </div>
      <div class="module-view-info">
        <h1>Reactivar Trámite</h1>
        <p>Padrón de Licencias - Reactivación de trámites cancelados</p></div>
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
      <!-- Búsqueda de Trámite -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Trámite Cancelado
          </h5>
        </div>
        <div class="municipal-card-body">
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
                    :disabled="loading || !searchTramite"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
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
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Datos del Trámite
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">ID Trámite:</td>
                  <td><strong>{{ tramiteData.id_tramite }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Licencia:</td>
                  <td><code>{{ tramiteData.licencia }}</code></td>
                </tr>
                <tr>
                  <td class="label">Tipo:</td>
                  <td>{{ tramiteData.tipo_tramite }}</td>
                </tr>
                <tr>
                  <td class="label">Fecha:</td>
                  <td>{{ formatDate(tramiteData.fecha) }}</td>
                </tr>
                <tr>
                  <td class="label">Estado Actual:</td>
                  <td>
                    <span :class="getEstadoBadgeClass(tramiteData.estatus)" class="badge">
                      <font-awesome-icon :icon="getEstadoIcon(tramiteData.estatus)" />
                      {{ getEstadoText(tramiteData.estatus) }}
                    </span>
                  </td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Información Adicional
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Solicitante:</td>
                  <td>{{ tramiteData.solicitante || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">RFC:</td>
                  <td><code>{{ tramiteData.rfc || 'N/A' }}</code></td>
                </tr>
                <tr>
                  <td class="label">Domicilio:</td>
                  <td>{{ tramiteData.domicilio || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Usuario Captura:</td>
                  <td><code>{{ tramiteData.usuario_captura }}</code></td>
                </tr>
                <tr>
                  <td class="label">Fecha Cancelación:</td>
                  <td>{{ formatDate(tramiteData.fecha_cancelacion) }}</td>
                </tr>
                <tr>
                  <td class="label">Motivo Cancelación:</td>
                  <td>{{ tramiteData.motivo_cancelacion || 'Sin motivo registrado' }}</td>
                </tr>
              </table>
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
                    placeholder="Ingrese el motivo detallado de la reactivación del trámite"
                    required
                  ></textarea>
                  <small class="form-text text-muted">
                    Explique claramente por qué se debe reactivar este trámite cancelado
                  </small>
                </div>
              </div>

              <div class="alert alert-info">
                <font-awesome-icon icon="info-circle" />
                <strong>Información:</strong> Al reactivar el trámite, su estado cambiará de <strong>CANCELADO</strong> a <strong>ACTIVO</strong> y podrá continuar con el proceso normal.
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-success"
                    :disabled="loading"
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

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
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
      :componentName="'ReactivaTramite'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  loadingMessage,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const searchTramite = ref(null)
const tramiteData = ref(null)

const reactivacionForm = ref({
  motivo: ''
})

// Métodos
const buscarTramite = async () => {
  if (!searchTramite.value) return

  setLoading(true, 'Buscando trámite...')
  try {
    const response = await execute(
      'GET_TRAMITE_BY_ID',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramiteData.value = response.result[0]

      if (tramiteData.value.estatus === 'C') {
        showToast('success', 'Trámite cancelado encontrado - Puede reactivarlo')
      } else {
        showToast('warning', 'Trámite encontrado pero no está cancelado')
      }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El trámite no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      tramiteData.value = null
    }
  } catch (error) {
    handleApiError(error)
    tramiteData.value = null
  } finally {
    setLoading(false)
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

  // Primera confirmación
  const firstConfirm = await Swal.fire({
    icon: 'question',
    title: '¿Reactivar trámite?',
    html: `
      <p>¿Está seguro de reactivar el trámite <strong>#${tramiteData.value.id_tramite}</strong>?</p>
      <p><strong>Motivo:</strong> ${reactivacionForm.value.motivo}</p>
      <p class="text-muted">El trámite pasará de estado <strong class="text-danger">CANCELADO</strong> a <strong class="text-success">ACTIVO</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Continuar',
    cancelButtonText: 'Cancelar'
  })

  if (!firstConfirm.isConfirmed) return

  // Segunda confirmación
  const secondConfirm = await Swal.fire({
    icon: 'warning',
    title: 'Confirmación final',
    html: `
      <p><strong>Esta acción reactivará el trámite cancelado</strong></p>
      <p class="text-info">Se restaurará el flujo normal del trámite</p>
      <p>¿Desea continuar?</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, reactivar',
    cancelButtonText: 'Cancelar'
  })

  if (!secondConfirm.isConfirmed) return

  setLoading(true, 'Reactivando trámite...')
  try {
    const response = await execute(
      'REACTIVAR_TRAMITE',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' },
        { nombre: 'p_motivo', valor: reactivacionForm.value.motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Trámite reactivado',
        html: `
          <p>${response.result[0].message}</p>
          <p class="text-success"><strong>El trámite ahora está ACTIVO</strong></p>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      limpiarFormulario()
      showToast('success', 'Trámite reactivado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al reactivar',
        text: response?.result?.[0]?.message || 'No se pudo reactivar el trámite',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const limpiarFormulario = () => {
  searchTramite.value = null
  tramiteData.value = null
  reactivacionForm.value = {
    motivo: ''
  }
}

const getEstadoBadgeClass = (estatus) => {
  const classes = {
    'A': 'badge-success',
    'P': 'badge-warning',
    'C': 'badge-danger',
    'T': 'badge-info'
  }
  return classes[estatus] || 'badge-secondary'
}

const getEstadoText = (estatus) => {
  const estados = {
    'A': 'Activo',
    'P': 'Pendiente',
    'C': 'Cancelado',
    'T': 'Terminado'
  }
  return estados[estatus] || 'Desconocido'
}

const getEstadoIcon = (estatus) => {
  const icons = {
    'A': 'check-circle',
    'P': 'clock',
    'C': 'times-circle',
    'T': 'flag-checkered'
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
