<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Zonas de Anuncios</h1>
        <p>Padrón de Licencias - Catálogo de Zonas de Anuncios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nueva Zona
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
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
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
              @keyup.enter="searchZonas"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigencia</label>
            <select class="municipal-form-control" v-model="filters.vigente">
              <option value="">Todas</option>
              <option value="V">Vigentes</option>
              <option value="C">Canceladas</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchZonas"
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
            @click="loadZonas"
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
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Zonas de Anuncios
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="zonas.length > 0">{{ zonas.length }} registros</span>
          <div v-if="loading" class="spinner-border spinner-sm" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Clave</th>
                <th>Descripción</th>
                <th>Vigencia</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="zona in zonas" :key="zona.id" class="row-hover">
                <td><strong class="text-primary">{{ zona.id }}</strong></td>
                <td><code class="text-muted">{{ zona.clave?.trim() || 'N/A' }}</code></td>
                <td>{{ zona.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getVigenciaBadgeClass(zona.vigente)">
                    <font-awesome-icon :icon="getVigenciaIcon(zona.vigente)" />
                    {{ getVigenciaText(zona.vigente) }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewZona(zona)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editZona(zona)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmDeleteZona(zona)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="zonas.length === 0 && !loading">
                <td colspan="5" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron zonas de anuncios</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && zonas.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando zonas de anuncios...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Zona de Anuncios"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createZona"
      :loading="creatingZona"
      confirmText="Crear Zona"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createZona">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Clave: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newZona.clave"
              maxlength="20"
              required
              placeholder="Clave de la zona"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigencia: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newZona.vigente" required>
              <option value="">Seleccionar...</option>
              <option value="V">Vigente</option>
              <option value="C">Cancelada</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <textarea
            class="municipal-form-control"
            v-model="newZona.descripcion"
            rows="3"
            maxlength="255"
            required
            placeholder="Descripción de la zona"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Zona: ${selectedZona?.descripcion}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateZona"
      :loading="updatingZona"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateZona">
        <div class="form-group full-width">
          <label class="municipal-form-label">ID (No editable):</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="editForm.id"
            disabled
          >
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Clave: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.clave"
              maxlength="20"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigencia: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="editForm.vigente" required>
              <option value="V">Vigente</option>
              <option value="C">Cancelada</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <textarea
            class="municipal-form-control"
            v-model="editForm.descripcion"
            rows="3"
            maxlength="255"
            required
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de la Zona: ${selectedZona?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedZona" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información de la Zona
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedZona.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Clave:</td>
                <td><code class="text-muted">{{ selectedZona.clave?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedZona.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Vigencia:</td>
                <td>
                  <span class="badge" :class="getVigenciaBadgeClass(selectedZona.vigente)">
                    <font-awesome-icon :icon="getVigenciaIcon(selectedZona.vigente)" />
                    {{ getVigenciaText(selectedZona.vigente) }}
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
          <button class="btn-municipal-primary" @click="editZona(selectedZona); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Zona
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
      :componentName="'ZonaAnuncio'"
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
const zonas = ref([])
const selectedZona = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingZona = ref(false)
const updatingZona = ref(false)

// Filtros
const filters = ref({
  descripcion: '',
  vigente: ''
})

// Formularios
const newZona = ref({
  clave: '',
  descripcion: '',
  vigente: ''
})

const editForm = ref({
  id: null,
  clave: '',
  descripcion: '',
  vigente: ''
})

// Métodos
const loadZonas = async () => {
  setLoading(true, 'Cargando zonas de anuncios...')

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_zonaanuncio_list',
      'padron_licencias',
      [
        { nombre: 'p_search', valor: filters.value.descripcion || null, tipo: 'string' },
        { nombre: 'p_vigente', valor: filters.value.vigente || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      zonas.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${zonas.value.length} zonas`)
    } else {
      zonas.value = []
      showToast('error', 'Error al cargar zonas')
    }
  } catch (error) {
    handleApiError(error)
    zonas.value = []
  } finally {
    setLoading(false)
  }
}

const searchZonas = () => {
  loadZonas()
}

const clearFilters = () => {
  filters.value = {
    descripcion: '',
    vigente: ''
  }
  loadZonas()
}

const openCreateModal = () => {
  newZona.value = {
    clave: '',
    descripcion: '',
    vigente: ''
  }
  showCreateModal.value = true
}

const createZona = async () => {
  if (!newZona.value.clave || !newZona.value.descripcion || !newZona.value.vigente) {
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
    title: '¿Confirmar creación de zona?',
    html: `
      <div class="swal-selection-content">
        <p class="swal-selection-text">Se creará una nueva zona con los siguientes datos:</p>
        <ul class="swal-selection-list">
          <li><strong>Clave:</strong> ${newZona.value.clave}</li>
          <li><strong>Descripción:</strong> ${newZona.value.descripcion}</li>
          <li><strong>Vigencia:</strong> ${newZona.value.vigente === 'V' ? 'Vigente' : 'Cancelada'}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear zona',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingZona.value = true

  try {
    const response = await execute(
      'sp_zonaanuncio_create',
      'padron_licencias',
      [
        { nombre: 'p_clave', valor: newZona.value.clave.trim(), tipo: 'string' },
        { nombre: 'p_descripcion', valor: newZona.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_vigente', valor: newZona.value.vigente, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadZonas()

      await Swal.fire({
        icon: 'success',
        title: '¡Zona creada!',
        text: 'La zona ha sido creada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Zona creada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear zona',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear la zona',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingZona.value = false
  }
}

const editZona = (zona) => {
  selectedZona.value = zona
  editForm.value = {
    id: zona.id,
    clave: zona.clave?.trim() || '',
    descripcion: zona.descripcion?.trim() || '',
    vigente: zona.vigente || ''
  }
  showEditModal.value = true
}

const updateZona = async () => {
  if (!editForm.value.clave || !editForm.value.descripcion || !editForm.value.vigente) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <div class="swal-selection-content">
        <p class="swal-selection-text">Se actualizarán los datos de la zona:</p>
        <ul class="swal-selection-list">
          <li><strong>ID:</strong> ${editForm.value.id}</li>
          <li><strong>Clave:</strong> ${editForm.value.clave}</li>
          <li><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
          <li><strong>Vigencia:</strong> ${editForm.value.vigente === 'V' ? 'Vigente' : 'Cancelada'}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  updatingZona.value = true

  try {
    const response = await execute(
      'sp_zonaanuncio_update',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_clave', valor: editForm.value.clave.trim(), tipo: 'string' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_vigente', valor: editForm.value.vigente, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadZonas()

      await Swal.fire({
        icon: 'success',
        title: '¡Zona actualizada!',
        text: 'Los datos de la zona han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Zona actualizada exitosamente')
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
    updatingZona.value = false
  }
}

const viewZona = (zona) => {
  selectedZona.value = zona
  showViewModal.value = true
}

const confirmDeleteZona = async (zona) => {
  const result = await Swal.fire({
    title: '¿Eliminar zona?',
    text: `¿Está seguro de eliminar la zona "${zona.descripcion?.trim()}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteZona(zona)
  }
}

const deleteZona = async (zona) => {
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_zonaanuncio_delete',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: zona.anuncio, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      loadZonas()

      await Swal.fire({
        icon: 'success',
        title: '¡Zona eliminada!',
        text: 'La zona ha sido eliminada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Zona eliminada exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const getVigenciaBadgeClass = (vigente) => {
  return vigente === 'V' ? 'badge-success' : 'badge-danger'
}

const getVigenciaText = (vigente) => {
  return vigente === 'V' ? 'Vigente' : 'Cancelada'
}

const getVigenciaIcon = (vigente) => {
  return vigente === 'V' ? 'check-circle' : 'times-circle'
}

// Lifecycle
onMounted(() => {
  loadZonas()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
