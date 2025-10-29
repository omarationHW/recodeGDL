<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="layer-group" />
      </div>
      <div class="module-view-info">
        <h1>Grupos de Licencias</h1>
        <p>Padrón de Licencias - Administración de Grupos de Licencias</p></div>
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
          Nuevo Grupo
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
              @keyup.enter="searchGrupos"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchGrupos"
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
            @click="loadGrupos"
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
          Grupos de Licencias
          <span class="badge-info" v-if="grupos.length > 0">{{ grupos.length }} registros</span>
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
                <th>Descripción</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="grupo in grupos" :key="grupo.id" class="row-hover">
                <td><strong class="text-primary">{{ grupo.id }}</strong></td>
                <td>{{ grupo.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewGrupo(grupo)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editGrupo(grupo)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmDeleteGrupo(grupo)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="grupos.length === 0 && !loading">
                <td colspan="3" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron grupos de licencias</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && grupos.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando grupos de licencias...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Grupo de Licencias"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createGrupo"
      :loading="creatingGrupo"
      confirmText="Crear Grupo"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createGrupo">
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newGrupo.descripcion"
            maxlength="100"
            required
            placeholder="Ingrese la descripción del grupo"
          >
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Grupo: ${selectedGrupo?.descripcion}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateGrupo"
      :loading="updatingGrupo"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateGrupo">
        <div class="form-group full-width">
          <label class="municipal-form-label">ID (No editable):</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="editForm.id"
            disabled
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.descripcion"
            maxlength="100"
            required
          >
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Grupo: ${selectedGrupo?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedGrupo" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información del Grupo
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedGrupo.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedGrupo.descripcion?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editGrupo(selectedGrupo); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Grupo
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
      :componentName="'GruposLicenciasAbcfrm'"
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
const grupos = ref([])
const selectedGrupo = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingGrupo = ref(false)
const updatingGrupo = ref(false)

// Filtros
const filters = ref({
  descripcion: ''
})

// Formularios
const newGrupo = ref({
  descripcion: ''
})

const editForm = ref({
  id: null,
  descripcion: ''
})

// Métodos
const loadGrupos = async () => {
  setLoading(true, 'Cargando grupos de licencias...')

  try {
    const response = await execute(
      'SP_LIST_GRUPOS_LICENCIAS',
      'padron_licencias',
      [
        { nombre: 'p_search', valor: filters.value.descripcion || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      grupos.value = response.result
      showToast('success', 'Grupos cargados correctamente')
    } else {
      grupos.value = []
      showToast('error', 'Error al cargar grupos')
    }
  } catch (error) {
    handleApiError(error)
    grupos.value = []
  } finally {
    setLoading(false)
  }
}

const searchGrupos = () => {
  loadGrupos()
}

const clearFilters = () => {
  filters.value = {
    descripcion: ''
  }
  loadGrupos()
}

const openCreateModal = () => {
  newGrupo.value = {
    descripcion: ''
  }
  showCreateModal.value = true
}

const createGrupo = async () => {
  if (!newGrupo.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor ingrese la descripción del grupo',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de grupo?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo grupo con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Descripción:</strong> ${newGrupo.value.descripcion}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear grupo',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingGrupo.value = true

  try {
    const response = await execute(
      'SP_INSERT_GRUPO_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: newGrupo.value.descripcion.trim(), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo creado!',
        text: 'El grupo ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Grupo creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear grupo',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear el grupo',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingGrupo.value = false
  }
}

const editGrupo = (grupo) => {
  selectedGrupo.value = grupo
  editForm.value = {
    id: grupo.id,
    descripcion: grupo.descripcion?.trim() || ''
  }
  showEditModal.value = true
}

const updateGrupo = async () => {
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
        <p style="margin-bottom: 10px;">Se actualizarán los datos del grupo:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>ID:</strong> ${editForm.value.id}</li>
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

  updatingGrupo.value = true

  try {
    const response = await execute(
      'SP_UPDATE_GRUPO_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion.trim(), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo actualizado!',
        text: 'Los datos del grupo han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Grupo actualizado exitosamente')
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
    updatingGrupo.value = false
  }
}

const viewGrupo = (grupo) => {
  selectedGrupo.value = grupo
  showViewModal.value = true
}

const confirmDeleteGrupo = async (grupo) => {
  const result = await Swal.fire({
    title: '¿Eliminar grupo?',
    text: `¿Está seguro de eliminar el grupo "${grupo.descripcion?.trim()}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteGrupo(grupo)
  }
}

const deleteGrupo = async (grupo) => {
  try {
    const response = await execute(
      'SP_DELETE_GRUPO_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: grupo.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo eliminado!',
        text: 'El grupo ha sido eliminado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Grupo eliminado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Lifecycle
onMounted(() => {
  loadGrupos()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
