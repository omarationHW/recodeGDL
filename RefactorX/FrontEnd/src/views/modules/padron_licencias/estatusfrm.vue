<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="exchange-alt" />
      </div>
      <div class="module-view-info">
        <h1>Cambio de Estatus de Revisión</h1>
        <p>Padrón de Licencias - Cambiar Estado de Revisiones de Trámites</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="searchTramite" :disabled="loading">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Trámite</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.tramite"
              placeholder="Ingrese número de trámite"
              @keyup.enter="searchTramite"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchTramite"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
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

    <!-- Información de la revisión actual -->
    <div class="municipal-card" v-if="revisionInfo">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Información de la Revisión Actual
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-item">
            <span class="label">Trámite:</span>
            <span class="value"><strong>{{ revisionInfo.tramite }}</strong></span>
          </div>
          <div class="detail-item">
            <span class="label">Contribuyente:</span>
            <span class="value">{{ revisionInfo.contribuyente || 'N/A' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">Giro:</span>
            <span class="value">{{ revisionInfo.giro || 'N/A' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">Fecha Solicitud:</span>
            <span class="value">
              <font-awesome-icon icon="calendar" />
              {{ formatDate(revisionInfo.fecha_solicitud) }}
            </span>
          </div>
          <div class="detail-item">
            <span class="label">Estatus Actual:</span>
            <span class="value">
              <span class="badge" :class="getStatusBadgeClass(revisionInfo.estatus)">
                <font-awesome-icon :icon="getStatusIcon(revisionInfo.estatus)" />
                {{ revisionInfo.estatus || 'Pendiente' }}
              </span>
            </span>
          </div>
          <div class="detail-item">
            <span class="label">Última Actualización:</span>
            <span class="value">
              <font-awesome-icon icon="clock" />
              {{ formatDate(revisionInfo.fecha_actualizacion) }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulario de cambio de estatus -->
    <div class="municipal-card" v-if="revisionInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="edit" />
          Cambiar Estatus de Revisión
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="confirmChangeStatus">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Estatus: <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="statusForm.estatus" required>
                <option value="">Seleccionar estatus...</option>
                <option value="Pendiente">Pendiente</option>
                <option value="En Proceso">En Proceso</option>
                <option value="Aprobado">Aprobado</option>
                <option value="Rechazado">Rechazado</option>
                <option value="Requiere Información">Requiere Información</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">Observaciones: <span class="required">*</span></label>
            <textarea
              class="municipal-form-control"
              v-model="statusForm.observaciones"
              rows="4"
              placeholder="Ingrese observaciones sobre el cambio de estatus..."
              required
            ></textarea>
          </div>
          <div class="button-group">
            <button
              type="submit"
              class="btn-municipal-primary"
              :disabled="loading || !statusForm.estatus || !statusForm.observaciones"
            >
              <font-awesome-icon icon="save" />
              Guardar Cambio de Estatus
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="resetForm"
              :disabled="loading"
            >
              <font-awesome-icon icon="undo" />
              Restablecer
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Historial de cambios de estatus -->
    <div class="municipal-card" v-if="revisionInfo">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="history" />
          Historial de Cambios de Estatus
        </h5>
        <span class="badge-purple" v-if="historialEstatus.length > 0">
          {{ historialEstatus.length }} registro{{ historialEstatus.length !== 1 ? 's' : '' }}
        </span>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Fecha</th>
                <th>Estatus Anterior</th>
                <th>Estatus Nuevo</th>
                <th>Observaciones</th>
                <th>Usuario</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(hist, index) in historialEstatus" :key="index" class="row-hover">
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(hist.fecha_cambio) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(hist.estatus_anterior)">
                    {{ hist.estatus_anterior || 'N/A' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(hist.estatus_nuevo)">
                    <font-awesome-icon icon="arrow-right" />
                    {{ hist.estatus_nuevo }}
                  </span>
                </td>
                <td>{{ hist.observaciones?.trim() || 'Sin observaciones' }}</td>
                <td>
                  <code class="text-muted">
                    <font-awesome-icon icon="user" />
                    {{ hist.usuario?.trim() || 'Sistema' }}
                  </code>
                </td>
              </tr>
              <tr v-if="historialEstatus.length === 0">
                <td colspan="5" class="text-center text-muted">
                  <font-awesome-icon icon="folder-open" size="2x" class="empty-icon" />
                  <p>No hay historial de cambios de estatus</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && !revisionInfo" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando información de la revisión...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'estatusfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
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
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const loading = ref(false)
const revisionInfo = ref(null)
const historialEstatus = ref([])

// Filtros
const filters = ref({
  tramite: ''
})

// Formulario
const statusForm = ref({
  estatus: '',
  observaciones: ''
})

// Métodos
const searchTramite = async () => {
  if (!filters.value.tramite) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese un número de trámite',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  loading.value = true
  showLoading('Buscando información de la revisión...', 'Consultando base de datos')

  try {
    const response = await execute(
      'estatusfrm_sp_get_revision_info',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      revisionInfo.value = response.result[0]
      await loadHistorialEstatus()
      resetForm()
      showToast('success', 'Información de la revisión cargada correctamente')
    } else {
      revisionInfo.value = null
      historialEstatus.value = []
      await Swal.fire({
        icon: 'error',
        title: 'Trámite no encontrado',
        text: 'No se encontró información de revisión para el trámite especificado',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    revisionInfo.value = null
    historialEstatus.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const loadHistorialEstatus = async () => {
  if (!filters.value.tramite) return

  try {
    const response = await execute(
      'estatusfrm_sp_get_historial_estatus',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historialEstatus.value = response.result
    } else {
      historialEstatus.value = []
    }
  } catch (error) {
    handleApiError(error)
    historialEstatus.value = []
  }
}

const confirmChangeStatus = async () => {
  if (!statusForm.value.estatus || !statusForm.value.observaciones) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar cambio de estatus?',
    html: `
      <div>
        <p>Se cambiará el estatus de la revisión:</p>
        <ul>
          <li><strong>Trámite:</strong> ${filters.value.tramite}</li>
          <li><strong>Estatus Actual:</strong> ${revisionInfo.value.estatus || 'Pendiente'}</li>
          <li><strong>Nuevo Estatus:</strong> <span>${statusForm.value.estatus}</span></li>
          <li><strong>Observaciones:</strong> ${statusForm.value.observaciones}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cambiar estatus',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await changeStatus()
  }
}

const changeStatus = async () => {
  loading.value = true
  showLoading('Cambiando estatus de revisión...', 'Actualizando información')

  try {
    const response = await execute(
      'estatusfrm_sp_cambiar_estatus_revision',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' },
        { nombre: 'p_estatus', valor: statusForm.value.estatus, tipo: 'string' },
        { nombre: 'p_observaciones', valor: statusForm.value.observaciones.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await searchTramite()
      resetForm()

      await Swal.fire({
        icon: 'success',
        title: 'Estatus actualizado',
        text: 'El estatus de la revisión ha sido actualizado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Estatus actualizado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al actualizar estatus',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const resetForm = () => {
  statusForm.value = {
    estatus: '',
    observaciones: ''
  }
}

const clearFilters = () => {
  filters.value = {
    tramite: ''
  }
  revisionInfo.value = null
  historialEstatus.value = []
  resetForm()
}

// Utilidades
const getStatusBadgeClass = (estatus) => {
  const classes = {
    'Pendiente': 'badge-warning',
    'En Proceso': 'badge-purple',
    'Aprobado': 'badge-success',
    'Rechazado': 'badge-danger',
    'Requiere Información': 'badge-secondary',
    'Cancelado': 'badge-danger'
  }
  return classes[estatus] || 'badge-secondary'
}

const getStatusIcon = (estatus) => {
  const icons = {
    'Pendiente': 'clock',
    'En Proceso': 'spinner',
    'Aprobado': 'check-circle',
    'Rechazado': 'times-circle',
    'Requiere Información': 'question-circle',
    'Cancelado': 'ban'
  }
  return icons[estatus] || 'info-circle'
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

// Lifecycle
onMounted(() => {
  // Componente listo
})

onBeforeUnmount(() => {
  // Limpieza si es necesario
})
</script>
