<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="layer-group" />
      </div>
      <div class="module-view-info">
        <h1>Grupos de Licencias</h1>
        <p>Padrón de Licencias - Administración de Grupos de Licencias</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
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
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadGrupos"
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
          Grupos de Licencias
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="grupos.length > 0">
            {{ grupos.length }} registros
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="grupos.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="layer-group" size="3x" />
          </div>
          <h4>Grupos de Licencias</h4>
          <p>Utilice los filtros para buscar grupos de licencias o cargue todos los registros</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="grupos.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron registros con los criterios especificados</p>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Descripción</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="grupo in grupos"
                :key="grupo.id"
                @click="selectedRow = grupo"
                :class="{ 'table-row-selected': selectedRow === grupo }"
                class="row-hover"
              >
                <td><strong class="text-primary">{{ grupo.id }}</strong></td>
                <td>{{ grupo.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewGrupo(grupo)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="editGrupo(grupo)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click.stop="confirmDeleteGrupo(grupo)"
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
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'GruposLicenciasAbcfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Grupos de Licencias ABC'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

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
const grupos = ref([])
const selectedGrupo = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
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
  showLoading('Cargando grupos de licencias...')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const startTime = performance.now()
    const response = await execute(
      'sp_list_grupos_licencias',
      'padron_licencias',
      [
        { nombre: 'p_search', valor: filters.value.descripcion || null, tipo: 'string' }
      ],
      'guadalajara'
    )
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      grupos.value = response.result
      toast.value.message = 'Grupos cargados correctamente'
      toast.value.duration = durationText
      showToast('success', 'Grupos cargados correctamente')
    } else {
      grupos.value = []
      showToast('error', 'Error al cargar grupos')
    }
  } catch (error) {
    handleApiError(error)
    grupos.value = []
  } finally {
    hideLoading()
  }
}

const searchGrupos = () => {
  loadGrupos()
}

const clearFilters = () => {
  filters.value = {
    descripcion: ''
  }
  grupos.value = []
  hasSearched.value = false
  selectedRow.value = null
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
      <div class="swal-confirmation-text">
        <p>Se creará un nuevo grupo con los siguientes datos:</p>
        <ul class="swal-selection-list">
          <li><strong>Descripción:</strong> ${newGrupo.value.descripcion}</li>
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
  const usuario = localStorage.getItem('usuario') || 'sistema'

  try {
    const startTime = performance.now()
    const response = await execute(
      'sp_insert_grupo_licencia',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: newGrupo.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

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

      toast.value.message = 'Grupo creado exitosamente'
      toast.value.duration = durationText
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
      <div class="swal-confirmation-text">
        <p>Se actualizarán los datos del grupo:</p>
        <ul class="swal-selection-list">
          <li><strong>ID:</strong> ${editForm.value.id}</li>
          <li><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
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
  const usuario = localStorage.getItem('usuario') || 'sistema'

  try {
    const startTime = performance.now()
    const response = await execute(
      'sp_update_grupo_licencia',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

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

      toast.value.message = 'Grupo actualizado exitosamente'
      toast.value.duration = durationText
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
    const startTime = performance.now()
    const response = await execute(
      'sp_delete_grupo_licencia',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: grupo.id, tipo: 'integer' }
      ],
      'guadalajara'
    )
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo eliminado!',
        text: 'El grupo ha sido eliminado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      toast.value.message = 'Grupo eliminado exitosamente'
      toast.value.duration = durationText
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
