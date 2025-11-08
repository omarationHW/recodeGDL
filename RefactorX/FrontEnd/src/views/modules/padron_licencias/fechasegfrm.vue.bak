<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Fechas de Seguimiento</h1>
        <p>Padrón de Licencias - Gestión de Fechas de Seguimiento de Trámites</p></div>
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
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nueva Fecha
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">ID</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.id"
              placeholder="ID del registro"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchFechas"
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
          <button
            class="btn-municipal-secondary"
            @click="loadFechas"
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
          Fechas de Seguimiento Registradas
          <span class="badge-info" v-if="fechas.length > 0">{{ fechas.length }} registros</span>
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
                <th>ID</th>
                <th>Fecha</th>
                <th>Oficio</th>
                <th>Fecha Creación</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="fecha in fechas" :key="fecha.id" class="row-hover">
                <td><strong class="text-primary">{{ fecha.id }}</strong></td>
                <td>
                  <span class="badge-info">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(fecha.fecha) }}
                  </span>
                </td>
                <td>
                  <code>{{ fecha.oficio || 'N/A' }}</code>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="clock" />
                    {{ formatDateTime(fecha.created_at) }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewFecha(fecha)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="fechas.length === 0 && !loading">
                <td colspan="5" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron registros de fechas de seguimiento</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && fechas.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando fechas de seguimiento...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Registrar Nueva Fecha de Seguimiento"
      size="lg"
      @close="showCreateModal = false"
      @confirm="saveFecha"
      :loading="savingFecha"
      confirmText="Guardar Fecha"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="saveFecha">
        <div class="form-group">
          <label class="municipal-form-label">Fecha de Seguimiento: <span class="required">*</span></label>
          <input
            type="date"
            class="municipal-form-control"
            v-model="newFecha.fecha"
            required
          >
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Número de Oficio: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newFecha.oficio"
            maxlength="100"
            placeholder="Ej: OF/2025/001"
            required
          >
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de Fecha de Seguimiento ID: ${selectedFecha?.id}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedFecha" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Información del Registro
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedFecha.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Fecha de Seguimiento:</td>
                <td>
                  <span class="badge-info">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(selectedFecha.fecha) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Número de Oficio:</td>
                <td><strong>{{ selectedFecha.oficio || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Fecha de Creación:</td>
                <td>
                  <font-awesome-icon icon="clock" class="text-info" />
                  {{ formatDateTime(selectedFecha.created_at) }}
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
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
      :componentName="'fechasegfrm'"
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
const fechas = ref([])
const selectedFecha = ref(null)
const showCreateModal = ref(false)
const showViewModal = ref(false)
const savingFecha = ref(false)

// Filtros
const filters = ref({
  id: null
})

// Formularios
const newFecha = ref({
  fecha: '',
  oficio: ''
})

// Métodos
const loadFechas = async () => {
  setLoading(true, 'Cargando fechas de seguimiento...')

  try {
    const params = filters.value.id
      ? [{ nombre: 'p_id', valor: filters.value.id, tipo: 'integer' }]
      : []

    const response = await execute(
      filters.value.id ? 'FECHASEGFRM_GET' : 'FECHASEGFRM_LIST',
      'padron_licencias',
      params,
      'guadalajara'
    )

    if (response && response.result) {
      fechas.value = response.result
      showToast('success', 'Fechas de seguimiento cargadas correctamente')
    } else {
      fechas.value = []
      showToast('info', 'No se encontraron registros')
    }
  } catch (error) {
    handleApiError(error)
    fechas.value = []
  } finally {
    setLoading(false)
  }
}

const searchFechas = () => {
  loadFechas()
}

const clearFilters = () => {
  filters.value = {
    id: null
  }
  loadFechas()
}

const openCreateModal = () => {
  newFecha.value = {
    fecha: new Date().toISOString().split('T')[0],
    oficio: ''
  }
  showCreateModal.value = true
}

const saveFecha = async () => {
  if (!newFecha.value.fecha || !newFecha.value.oficio) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar registro de fecha?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se registrará la siguiente fecha de seguimiento:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Fecha:</strong> ${formatDate(newFecha.value.fecha)}</li>
          <li style="margin: 5px 0;"><strong>Oficio:</strong> ${newFecha.value.oficio}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, registrar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  savingFecha.value = true

  try {
    const response = await execute(
      'FECHASEGFRM_SAVE',
      'padron_licencias',
      [
        { nombre: 'p_fecha', valor: newFecha.value.fecha, tipo: 'string' },
        { nombre: 'p_oficio', valor: newFecha.value.oficio, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      showCreateModal.value = false
      loadFechas()

      await Swal.fire({
        icon: 'success',
        title: 'Fecha registrada',
        text: 'La fecha de seguimiento ha sido registrada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Fecha de seguimiento registrada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al registrar fecha',
        text: 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    savingFecha.value = false
  }
}

const viewFecha = (fecha) => {
  selectedFecha.value = fecha
  showViewModal.value = true
}

// Utilidades
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

const formatDateTime = (dateString) => {
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
  loadFechas()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showViewModal.value = false
})
</script>
