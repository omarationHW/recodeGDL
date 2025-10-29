<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Actividades</h1>
        <p>Padrón de Licencias - Búsqueda de Actividades Comerciales</p></div>
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
          <font-awesome-icon icon="filter" />
          Criterios de Búsqueda
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">ID Actividad</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.id_actividad"
              placeholder="Buscar por ID"
              @keyup.enter="searchActividades"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
              @keyup.enter="searchActividades"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchActividades"
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

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Resultados de Búsqueda
          <span class="badge-info" v-if="actividades.length > 0">{{ actividades.length }} registros</span>
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
                <th>ID Actividad</th>
                <th>Descripción</th>
                <th>ID Giro</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="actividad in actividades" :key="actividad.id_actividad" class="row-hover">
                <td><strong class="text-primary">{{ actividad.id_actividad }}</strong></td>
                <td>{{ actividad.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">
                    {{ actividad.id_giro || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewActividad(actividad)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="selectActividad(actividad)"
                      title="Seleccionar actividad"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="actividades.length === 0 && !loading">
                <td colspan="4" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron actividades. Use los filtros para buscar.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Panel de actividad seleccionada -->
    <div class="municipal-card" v-if="actividadSeleccionada">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" class="text-success" />
          Actividad Seleccionada
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="selected-item-panel">
          <div class="selected-item-info">
            <div class="info-row">
              <span class="info-label">ID Actividad:</span>
              <span class="info-value"><code>{{ actividadSeleccionada.id_actividad }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Descripción:</span>
              <span class="info-value">{{ actividadSeleccionada.descripcion?.trim() }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">ID Giro:</span>
              <span class="info-value">
                <span class="badge-secondary">{{ actividadSeleccionada.id_giro }}</span>
              </span>
            </div>
          </div>
          <div class="selected-item-actions">
            <button
              class="btn-municipal-secondary"
              @click="clearSelection"
            >
              <font-awesome-icon icon="times" />
              Limpiar Selección
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && actividades.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Buscando actividades...</p>
      </div>
    </div>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de Actividad: ${selectedActividad?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedActividad" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información de la Actividad
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Actividad:</td>
                <td><code>{{ selectedActividad.id_actividad }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedActividad.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">ID Giro:</td>
                <td>
                  <span class="badge-secondary">
                    {{ selectedActividad.id_giro || 'N/A' }}
                  </span>
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
          <button class="btn-municipal-primary" @click="selectActividad(selectedActividad); showViewModal = false">
            <font-awesome-icon icon="check" />
            Seleccionar Actividad
          </button>
        </div>
      </div>
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
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'BusquedaActividadFrm'"
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
const actividades = ref([])
const actividadSeleccionada = ref(null)
const selectedActividad = ref(null)
const showViewModal = ref(false)

// Filtros
const filters = ref({
  id_actividad: '',
  descripcion: ''
})

// Métodos
const searchActividades = async () => {
  if (!filters.value.id_actividad && !filters.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando actividades...')

  try {
    // Si hay ID, buscar por ID, sino buscar por descripción
    const operacion = filters.value.id_actividad ? 'BUSCAR_ACTIVIDADES_POR_ID' : 'BUSCAR_ACTIVIDADES'
    const parametros = filters.value.id_actividad
      ? [{ nombre: 'p_id_actividad', valor: parseInt(filters.value.id_actividad), tipo: 'integer' }]
      : [{ nombre: 'p_descripcion', valor: filters.value.descripcion, tipo: 'string' }]

    const response = await execute(
      operacion,
      'padron_licencias',
      parametros,
      'guadalajara'
    )

    if (response && response.result) {
      actividades.value = response.result
      if (actividades.value.length > 0) {
        showToast('success', `Se encontraron ${actividades.value.length} actividades`)
      } else {
        showToast('info', 'No se encontraron actividades con los criterios especificados')
      }
    } else {
      actividades.value = []
      showToast('error', 'Error al buscar actividades')
    }
  } catch (error) {
    handleApiError(error)
    actividades.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    id_actividad: '',
    descripcion: ''
  }
  actividades.value = []
}

const viewActividad = (actividad) => {
  selectedActividad.value = actividad
  showViewModal.value = true
}

const selectActividad = async (actividad) => {
  actividadSeleccionada.value = actividad

  await Swal.fire({
    icon: 'success',
    title: 'Actividad Seleccionada',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Ha seleccionado la siguiente actividad:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>ID:</strong> ${actividad.id_actividad}</li>
          <li style="margin: 5px 0;"><strong>Descripción:</strong> ${actividad.descripcion?.trim()}</li>
          <li style="margin: 5px 0;"><strong>ID Giro:</strong> ${actividad.id_giro}</li>
        </ul>
      </div>
    `,
    confirmButtonColor: '#ea8215',
    timer: 3000
  })

  showToast('success', 'Actividad seleccionada correctamente')
}

const clearSelection = () => {
  actividadSeleccionada.value = null
  showToast('info', 'Selección limpiada')
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente, esperar búsqueda del usuario
})

onBeforeUnmount(() => {
  showViewModal.value = false
})
</script>
