<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Requisitos</h1>
        <p>Padrón de Licencias - Gestión de Requisitos para Trámites</p></div>
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
          Nuevo Requisito
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Requisito</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.req"
              placeholder="Número de requisito"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchRequisitos"
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
            @click="loadRequisitos"
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
          Requisitos Registrados
          <span class="badge-info" v-if="requisitos.length > 0">{{ requisitos.length }} registros</span>
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
                <th>Número</th>
                <th>Descripción</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="requisito in requisitos" :key="requisito.req" class="row-hover">
                <td>
                  <strong class="text-primary">
                    <font-awesome-icon icon="hashtag" />
                    {{ requisito.req }}
                  </strong>
                </td>
                <td>{{ requisito.descripcion || 'N/A' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewRequisito(requisito)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editRequisito(requisito)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmDeleteRequisito(requisito)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="requisitos.length === 0 && !loading">
                <td colspan="3" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron requisitos con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && requisitos.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando requisitos...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Requisito"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createRequisito"
      :loading="creatingRequisito"
      confirmText="Crear Requisito"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createRequisito">
        <div class="form-group">
          <label class="municipal-form-label">Número de Requisito: <span class="required">*</span></label>
          <input
            type="number"
            class="municipal-form-control"
            v-model="newRequisito.req"
            required
          >
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <textarea
            class="municipal-form-control"
            v-model="newRequisito.descripcion"
            rows="4"
            required
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Requisito #${selectedRequisito?.req}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateRequisito"
      :loading="updatingRequisito"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateRequisito">
        <div class="form-group">
          <label class="municipal-form-label">Número de Requisito (No editable):</label>
          <input
            type="number"
            class="municipal-form-control"
            :value="editForm.req"
            disabled
          >
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <textarea
            class="municipal-form-control"
            v-model="editForm.descripcion"
            rows="4"
            required
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Requisito #${selectedRequisito?.req}`"
      size="md"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedRequisito" class="user-details">
        <div class="detail-section">
          <h6 class="section-title">
            <font-awesome-icon icon="info-circle" />
            Información del Requisito
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Número:</td>
              <td>
                <code class="text-primary">
                  <font-awesome-icon icon="hashtag" />
                  {{ selectedRequisito.req }}
                </code>
              </td>
            </tr>
            <tr>
              <td class="label">Descripción:</td>
              <td>{{ selectedRequisito.descripcion || 'N/A' }}</td>
            </tr>
          </table>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editRequisito(selectedRequisito); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Requisito
          </button>
        </div>
      </div>
    </Modal>

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
      :componentName="'CatRequisitos'"
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
const requisitos = ref([])
const selectedRequisito = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingRequisito = ref(false)
const updatingRequisito = ref(false)

// Filtros
const filters = ref({
  req: '',
  descripcion: ''
})

// Formularios
const newRequisito = ref({
  req: null,
  descripcion: ''
})

const editForm = ref({
  req: null,
  descripcion: ''
})

// Métodos
const loadRequisitos = async () => {
  setLoading(true, 'Cargando requisitos...')

  try {
    const response = await execute(
      'SP_CAT_REQUISITOS_LIST',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      requisitos.value = response.result
      showToast('success', 'Requisitos cargados correctamente')
    } else {
      requisitos.value = []
      showToast('error', 'Error al cargar requisitos')
    }
  } catch (error) {
    handleApiError(error)
    requisitos.value = []
  } finally {
    setLoading(false)
  }
}

const searchRequisitos = async () => {
  if (!filters.value.descripcion && !filters.value.req) {
    loadRequisitos()
    return
  }

  setLoading(true, 'Buscando requisitos...')

  try {
    const response = await execute(
      'SP_CAT_REQUISITOS_SEARCH',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: filters.value.descripcion || '', tipo: 'string' },
        { nombre: 'p_req', valor: filters.value.req || null, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      requisitos.value = response.result
      showToast('success', `${response.result.length} requisitos encontrados`)
    } else {
      requisitos.value = []
      showToast('info', 'No se encontraron requisitos')
    }
  } catch (error) {
    handleApiError(error)
    requisitos.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    req: '',
    descripcion: ''
  }
  loadRequisitos()
}

const openCreateModal = () => {
  newRequisito.value = {
    req: null,
    descripcion: ''
  }
  showCreateModal.value = true
}

const createRequisito = async () => {
  if (!newRequisito.value.req || !newRequisito.value.descripcion) {
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
    title: '¿Confirmar creación de requisito?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo requisito:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Número:</strong> ${newRequisito.value.req}</li>
          <li style="margin: 5px 0;"><strong>Descripción:</strong> ${newRequisito.value.descripcion}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear requisito',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingRequisito.value = true

  try {
    const response = await execute(
      'SP_CAT_REQUISITOS_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_req', valor: newRequisito.value.req, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: newRequisito.value.descripcion, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadRequisitos()

      await Swal.fire({
        icon: 'success',
        title: '¡Requisito creado!',
        text: 'El requisito ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Requisito creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear requisito',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear el requisito',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingRequisito.value = false
  }
}

const editRequisito = (requisito) => {
  selectedRequisito.value = requisito
  editForm.value = {
    req: requisito.req,
    descripcion: requisito.descripcion || ''
  }
  showEditModal.value = true
}

const updateRequisito = async () => {
  if (!editForm.value.descripcion) {
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
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se actualizarán los datos del requisito:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Número:</strong> ${editForm.value.req}</li>
          <li style="margin: 5px 0;"><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
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

  updatingRequisito.value = true

  try {
    const response = await execute(
      'SP_CAT_REQUISITOS_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_req', valor: editForm.value.req, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadRequisitos()

      await Swal.fire({
        icon: 'success',
        title: '¡Requisito actualizado!',
        text: 'Los datos del requisito han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Requisito actualizado exitosamente')
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
    updatingRequisito.value = false
  }
}

const viewRequisito = (requisito) => {
  selectedRequisito.value = requisito
  showViewModal.value = true
}

const confirmDeleteRequisito = async (requisito) => {
  const result = await Swal.fire({
    title: '¿Eliminar requisito?',
    text: `¿Está seguro de eliminar el requisito #${requisito.req}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteRequisito(requisito)
  }
}

const deleteRequisito = async (requisito) => {
  setLoading(true, 'Eliminando requisito...')

  try {
    const response = await execute(
      'SP_CAT_REQUISITOS_DELETE',
      'padron_licencias',
      [
        { nombre: 'p_req', valor: requisito.req, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadRequisitos()

      await Swal.fire({
        icon: 'success',
        title: '¡Requisito eliminado!',
        text: 'El requisito ha sido eliminado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Requisito eliminado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al eliminar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Lifecycle
onMounted(() => {
  loadRequisitos()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
