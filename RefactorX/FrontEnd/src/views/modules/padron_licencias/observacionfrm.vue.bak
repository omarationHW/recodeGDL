<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="comment-alt" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Observaciones</h1>
        <p>Padrón de Licencias - Registro y consulta de observaciones de trámites</p></div>
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
          @click="openCreateModal"
          :disabled="loading || !searchForm.numTramite"
        >
          <font-awesome-icon icon="plus" />
          Nueva Observación
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Formulario de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar Trámite/Licencia
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">
              <font-awesome-icon icon="hashtag" />
              Número de Trámite/Licencia: <span class="required">*</span>
            </label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.numTramite"
              placeholder="Ingrese número"
              @keyup.enter="buscarObservaciones"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">
              Tipo:
            </label>
            <select class="municipal-form-control" v-model="searchForm.tipo">
              <option value="">Todos</option>
              <option value="TRAMITE">Trámite</option>
              <option value="LICENCIA">Licencia</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarObservaciones"
            :disabled="loading || !searchForm.numTramite"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarBusqueda"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de observaciones -->
    <div v-if="observaciones.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Historial de Observaciones
          <span class="badge-info" v-if="observaciones.length > 0">{{ observaciones.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Fecha</th>
                <th>Observación</th>
                <th>Usuario</th>
                <th>Tipo</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="obs in observaciones" :key="obs.id" class="row-hover">
                <td><strong class="text-primary">{{ obs.id }}</strong></td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(obs.fecha) }}
                  </small>
                </td>
                <td>
                  <div class="observacion-text">
                    {{ obs.observacion || 'N/A' }}
                  </div>
                </td>
                <td>
                  <span class="badge-secondary">
                    {{ obs.usuario || 'N/A' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getTipoBadge(obs.tipo)">
                    {{ obs.tipo || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editObservacion(obs)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="confirmDeleteObservacion(obs)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Mensaje cuando no hay observaciones -->
    <div v-if="observaciones.length === 0 && hasSearched" class="municipal-card">
      <div class="municipal-card-body">
        <div class="empty-state">
          <font-awesome-icon icon="search" size="3x" class="empty-icon" />
          <h5>No se encontraron observaciones</h5>
          <p>No hay observaciones registradas para este trámite/licencia</p>
          <button
            class="btn-municipal-primary"
            @click="openCreateModal"
            :disabled="!searchForm.numTramite"
          >
            <font-awesome-icon icon="plus" />
            Agregar Primera Observación
          </button>
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

    </div>
    <!-- /module-view-content -->

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Nueva Observación"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createObservacion"
      :loading="creatingObservacion"
      confirmText="Guardar Observación"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createObservacion">
        <div class="form-group full-width">
          <label class="municipal-form-label">
            Número de Trámite/Licencia:
          </label>
          <input
            type="text"
            class="municipal-form-control"
            :value="searchForm.numTramite"
            disabled
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">
            Tipo: <span class="required">*</span>
          </label>
          <select class="municipal-form-control" v-model="newObservacion.tipo" required>
            <option value="">Seleccionar...</option>
            <option value="TRAMITE">Trámite</option>
            <option value="LICENCIA">Licencia</option>
            <option value="GENERAL">General</option>
          </select>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">
            Observación: <span class="required">*</span>
          </label>
          <textarea
            class="municipal-form-control"
            v-model="newObservacion.observacion"
            placeholder="Ingrese la observación"
            rows="5"
            required
            maxlength="1000"
          ></textarea>
          <small class="form-text">
            {{ newObservacion.observacion.length }}/1000 caracteres
          </small>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Observación #${selectedObservacion?.id}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateObservacion"
      :loading="updatingObservacion"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateObservacion">
        <div class="form-group full-width">
          <label class="municipal-form-label">
            ID Observación:
          </label>
          <input
            type="text"
            class="municipal-form-control"
            :value="selectedObservacion?.id"
            disabled
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">
            Tipo: <span class="required">*</span>
          </label>
          <select class="municipal-form-control" v-model="editForm.tipo" required>
            <option value="TRAMITE">Trámite</option>
            <option value="LICENCIA">Licencia</option>
            <option value="GENERAL">General</option>
          </select>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">
            Observación: <span class="required">*</span>
          </label>
          <textarea
            class="municipal-form-control"
            v-model="editForm.observacion"
            placeholder="Ingrese la observación"
            rows="5"
            required
            maxlength="1000"
          ></textarea>
          <small class="form-text">
            {{ editForm.observacion.length }}/1000 caracteres
          </small>
        </div>
        <div class="info-section">
          <small class="text-muted">
            <font-awesome-icon icon="info-circle" />
            Capturado por: <strong>{{ selectedObservacion?.usuario }}</strong>
            el {{ formatDate(selectedObservacion?.fecha) }}
          </small>
        </div>
      </form>
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
      :componentName="'observacionfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
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
const searchForm = ref({
  numTramite: null,
  tipo: ''
})

const observaciones = ref([])
const hasSearched = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const creatingObservacion = ref(false)
const updatingObservacion = ref(false)
const selectedObservacion = ref(null)

const newObservacion = ref({
  tipo: '',
  observacion: ''
})

const editForm = ref({
  tipo: '',
  observacion: ''
})

// Métodos
const buscarObservaciones = async () => {
  if (!searchForm.value.numTramite) {
    await Swal.fire({
      icon: 'warning',
      title: 'Número requerido',
      text: 'Por favor ingrese el número de trámite/licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando observaciones...')
  hasSearched.value = true

  try {
    const response = await execute(
      'observacionfrm_sp_get_observaciones',
      'padron_licencias',
      [
        { nombre: 'p_num_tramite', valor: searchForm.value.numTramite, tipo: 'integer' },
        { nombre: 'p_tipo', valor: searchForm.value.tipo || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      observaciones.value = response.result
      showToast('success', `${observaciones.value.length} observaciones encontradas`)
    } else {
      observaciones.value = []
      showToast('info', 'No se encontraron observaciones')
    }
  } catch (error) {
    handleApiError(error)
    observaciones.value = []
  } finally {
    setLoading(false)
  }
}

const openCreateModal = () => {
  if (!searchForm.value.numTramite) {
    Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Primero debe buscar un trámite/licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  newObservacion.value = {
    tipo: '',
    observacion: ''
  }
  showCreateModal.value = true
}

const createObservacion = async () => {
  if (!newObservacion.value.tipo || !newObservacion.value.observacion.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    title: '¿Confirmar nueva observación?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se agregará la siguiente observación:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Trámite/Licencia:</strong> ${searchForm.value.numTramite}</li>
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${newObservacion.value.tipo}</li>
          <li style="margin: 5px 0;"><strong>Observación:</strong> ${newObservacion.value.observacion.substring(0, 100)}${newObservacion.value.observacion.length > 100 ? '...' : ''}</li>
        </ul>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) {
    return
  }

  creatingObservacion.value = true

  try {
    const response = await execute(
      'observacionfrm_sp_save_observacion',
      'padron_licencias',
      [
        { nombre: 'p_num_tramite', valor: searchForm.value.numTramite, tipo: 'integer' },
        { nombre: 'p_tipo', valor: newObservacion.value.tipo, tipo: 'string' },
        { nombre: 'p_observacion', valor: newObservacion.value.observacion.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      buscarObservaciones()

      await Swal.fire({
        icon: 'success',
        title: '¡Observación guardada!',
        text: 'La observación ha sido registrada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Observación guardada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al guardar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingObservacion.value = false
  }
}

const editObservacion = (obs) => {
  selectedObservacion.value = obs
  editForm.value = {
    tipo: obs.tipo || '',
    observacion: obs.observacion || ''
  }
  showEditModal.value = true
}

const updateObservacion = async () => {
  if (!editForm.value.tipo || !editForm.value.observacion.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    title: '¿Confirmar actualización?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se actualizará la observación:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>ID:</strong> ${selectedObservacion.value.id}</li>
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${editForm.value.tipo}</li>
          <li style="margin: 5px 0;"><strong>Observación:</strong> ${editForm.value.observacion.substring(0, 100)}${editForm.value.observacion.length > 100 ? '...' : ''}</li>
        </ul>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) {
    return
  }

  updatingObservacion.value = true

  try {
    const response = await execute(
      'observacionfrm_sp_observacion_save',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: selectedObservacion.value.id, tipo: 'integer' },
        { nombre: 'p_tipo', valor: editForm.value.tipo, tipo: 'string' },
        { nombre: 'p_observacion', valor: editForm.value.observacion.trim(), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      buscarObservaciones()

      await Swal.fire({
        icon: 'success',
        title: '¡Observación actualizada!',
        text: 'La observación ha sido actualizada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Observación actualizada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al actualizar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    updatingObservacion.value = false
  }
}

const confirmDeleteObservacion = async (obs) => {
  const result = await Swal.fire({
    title: '¿Eliminar observación?',
    text: `¿Está seguro de eliminar la observación #${obs.id}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    // Aquí se implementaría el delete si existe el SP correspondiente
    await Swal.fire({
      icon: 'info',
      title: 'Función no implementada',
      text: 'La eliminación de observaciones no está habilitada',
      confirmButtonColor: '#ea8215'
    })
  }
}

const limpiarBusqueda = () => {
  searchForm.value = {
    numTramite: null,
    tipo: ''
  }
  observaciones.value = []
  hasSearched.value = false
  showToast('info', 'Búsqueda limpiada')
}

const getTipoBadge = (tipo) => {
  const tipos = {
    'TRAMITE': 'badge-primary',
    'LICENCIA': 'badge-success',
    'GENERAL': 'badge-info'
  }
  return tipos[tipo?.toUpperCase()] || 'badge-secondary'
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
  // No cargar nada automáticamente
})
</script>

<style scoped>
.observacion-text {
  max-width: 400px;
  white-space: pre-wrap;
  word-break: break-word;
  line-height: 1.4;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
}

.empty-icon {
  color: #dee2e6;
  margin-bottom: 16px;
}

.empty-state h5 {
  color: #6c757d;
  margin-bottom: 8px;
}

.empty-state p {
  color: #adb5bd;
  margin-bottom: 24px;
}

.required {
  color: #dc3545;
}

.full-width {
  grid-column: 1 / -1;
}

.form-text {
  display: block;
  margin-top: 4px;
  color: #6c757d;
  font-size: 0.875em;
}

.info-section {
  margin-top: 16px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #0066cc;
}
</style>
