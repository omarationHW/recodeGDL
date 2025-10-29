<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="bullhorn" />
      </div>
      <div class="module-view-info">
        <h1>Grupos de Anuncios</h1>
        <p>Padrón de Licencias - Gestión de Grupos y Asignación de Anuncios</p></div>
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
          v-if="currentView === 'list'"
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Grupo
        </button>
        <button
          v-if="currentView === 'manage'"
          class="btn-municipal-secondary"
          @click="backToList"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Volver a Lista
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Vista de Lista de Grupos -->
    <div v-if="currentView === 'list'">
      <!-- Tabla de grupos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Grupos de Anuncios Registrados
            <span class="badge-info" v-if="grupos.length > 0">{{ grupos.length }} grupos</span>
          </h5>
          <div class="button-group">
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
                  <td>{{ grupo.descripcion || 'N/A' }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="manageAnuncios(grupo)"
                        title="Gestionar anuncios"
                      >
                        <font-awesome-icon icon="cog" />
                        Anuncios
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
                    <p>No hay grupos de anuncios registrados</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Vista de Gestión de Anuncios -->
    <div v-if="currentView === 'manage'">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="bullhorn" />
            Gestión de Anuncios - {{ selectedGrupo?.descripcion }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Filtro de Giro -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtrar por Giro</label>
              <select class="municipal-form-control" v-model="selectedGiroFilter">
                <option value="">Todos los giros</option>
                <option v-for="giro in giros" :key="giro.id_giro" :value="giro.id_giro">
                  {{ giro.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="row" style="margin-top: 20px;">
            <!-- Columna Izquierda: Anuncios Disponibles -->
            <div class="col-md-6">
              <div class="licencias-panel">
                <div class="panel-header">
                  <h6>
                    <font-awesome-icon icon="list" />
                    Anuncios Disponibles
                    <span class="badge-info">{{ filteredAnunciosDisponibles.length }}</span>
                  </h6>
                  <button
                    class="btn-municipal-primary btn-sm"
                    @click="addSelectedAnuncios"
                    :disabled="selectedDisponibles.length === 0 || loading"
                  >
                    <font-awesome-icon icon="arrow-right" />
                    Agregar ({{ selectedDisponibles.length }})
                  </button>
                </div>
                <div class="panel-body">
                  <div class="licencias-list">
                    <div
                      v-for="anuncio in filteredAnunciosDisponibles"
                      :key="anuncio.id"
                      class="licencia-item"
                    >
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          :value="anuncio.id"
                          v-model="selectedDisponibles"
                        />
                        <span class="licencia-info">
                          <strong>{{ anuncio.numero }}</strong>
                          <small class="text-muted">{{ anuncio.descripcion }}</small>
                        </span>
                      </label>
                    </div>
                    <div v-if="filteredAnunciosDisponibles.length === 0" class="text-center text-muted">
                      <p>No hay anuncios disponibles</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Columna Derecha: Anuncios en el Grupo -->
            <div class="col-md-6">
              <div class="licencias-panel">
                <div class="panel-header">
                  <h6>
                    <font-awesome-icon icon="check-circle" />
                    Anuncios en el Grupo
                    <span class="badge-success">{{ filteredAnunciosGrupo.length }}</span>
                  </h6>
                  <button
                    class="btn-municipal-danger btn-sm"
                    @click="removeSelectedAnuncios"
                    :disabled="selectedGrupo.length === 0 || loading"
                  >
                    <font-awesome-icon icon="arrow-left" />
                    Quitar ({{ selectedGrupo.length }})
                  </button>
                </div>
                <div class="panel-body">
                  <div class="licencias-list">
                    <div
                      v-for="anuncio in filteredAnunciosGrupo"
                      :key="anuncio.id"
                      class="licencia-item licencia-grupo"
                    >
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          :value="anuncio.id"
                          v-model="selectedGrupo"
                        />
                        <span class="licencia-info">
                          <strong>{{ anuncio.numero }}</strong>
                          <small class="text-muted">{{ anuncio.descripcion }}</small>
                        </span>
                      </label>
                    </div>
                    <div v-if="filteredAnunciosGrupo.length === 0" class="text-center text-muted">
                      <p>No hay anuncios en este grupo</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && grupos.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando grupos de anuncios...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Grupo de Anuncios"
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
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newGrupo.descripcion"
            required
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
        <div class="form-group">
          <label class="municipal-form-label">ID (No editable):</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="editForm.id"
            disabled
          >
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.descripcion"
            required
          >
        </div>
      </form>
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
      :componentName="'gruposAnunciosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
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
const currentView = ref('list') // 'list' | 'manage'
const grupos = ref([])
const giros = ref([])
const anunciosDisponibles = ref([])
const anunciosGrupo = ref([])
const selectedGrupo = ref(null)
const selectedGiroFilter = ref('')
const selectedDisponibles = ref([])
const selectedGrupoAnuncios = ref([])
const showCreateModal = ref(false)
const showEditModal = ref(false)
const creatingGrupo = ref(false)
const updatingGrupo = ref(false)

// Formularios
const newGrupo = ref({
  descripcion: ''
})

const editForm = ref({
  id: null,
  descripcion: ''
})

// Computed
const filteredAnunciosDisponibles = computed(() => {
  if (!selectedGiroFilter.value) {
    return anunciosDisponibles.value
  }
  return anunciosDisponibles.value.filter(
    anun => anun.id_giro === parseInt(selectedGiroFilter.value)
  )
})

const filteredAnunciosGrupo = computed(() => {
  if (!selectedGiroFilter.value) {
    return anunciosGrupo.value
  }
  return anunciosGrupo.value.filter(
    anun => anun.id_giro === parseInt(selectedGiroFilter.value)
  )
})

// Métodos
const loadGrupos = async () => {
  setLoading(true, 'Cargando grupos de anuncios...')

  try {
    const response = await execute(
      'gruposAnunciosfrm_get_grupos_anuncios',
      'padron_licencias',
      [],
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

const loadGiros = async () => {
  try {
    const response = await execute(
      'gruposAnunciosfrm_get_giros',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      giros.value = response.result
    } else {
      giros.value = []
    }
  } catch (error) {
    handleApiError(error)
    giros.value = []
  }
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
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de grupo?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo grupo de anuncios:</p>
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
      'gruposAnunciosfrm_insert_grupo_anuncio',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: newGrupo.value.descripcion, tipo: 'string' }
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
    descripcion: grupo.descripcion || ''
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
      'gruposAnunciosfrm_update_grupo_anuncio',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion, tipo: 'string' }
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

const confirmDeleteGrupo = async (grupo) => {
  const result = await Swal.fire({
    title: '¿Eliminar grupo?',
    text: `¿Está seguro de eliminar el grupo "${grupo.descripcion}"?`,
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
  setLoading(true, 'Eliminando grupo...')

  try {
    const response = await execute(
      'gruposAnunciosfrm_delete_grupo_anuncio',
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
        text: 'El grupo ha sido eliminado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Grupo eliminado exitosamente')
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

const manageAnuncios = async (grupo) => {
  selectedGrupo.value = grupo
  selectedDisponibles.value = []
  selectedGrupoAnuncios.value = []
  selectedGiroFilter.value = ''
  currentView.value = 'manage'

  await Promise.all([
    loadAnunciosDisponibles(),
    loadAnunciosGrupo(grupo.id)
  ])
}

const loadAnunciosDisponibles = async () => {
  setLoading(true, 'Cargando anuncios disponibles...')

  try {
    const response = await execute(
      'gruposAnunciosfrm_get_anuncios_disponibles',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      anunciosDisponibles.value = response.result
    } else {
      anunciosDisponibles.value = []
    }
  } catch (error) {
    handleApiError(error)
    anunciosDisponibles.value = []
  } finally {
    setLoading(false)
  }
}

const loadAnunciosGrupo = async (grupoId) => {
  setLoading(true, 'Cargando anuncios del grupo...')

  try {
    const response = await execute(
      'gruposAnunciosfrm_get_anuncios_en_grupo',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: grupoId, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      anunciosGrupo.value = response.result
    } else {
      anunciosGrupo.value = []
    }
  } catch (error) {
    handleApiError(error)
    anunciosGrupo.value = []
  } finally {
    setLoading(false)
  }
}

const addSelectedAnuncios = async () => {
  if (selectedDisponibles.value.length === 0) {
    return
  }

  setLoading(true, 'Agregando anuncios al grupo...')

  try {
    const response = await execute(
      'gruposAnunciosfrm_add_anuncios_to_grupo',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' },
        { nombre: 'p_anuncios', valor: JSON.stringify(selectedDisponibles.value), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      selectedDisponibles.value = []
      await Promise.all([
        loadAnunciosDisponibles(),
        loadAnunciosGrupo(selectedGrupo.value.id)
      ])
      showToast('success', 'Anuncios agregados al grupo')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al agregar anuncios',
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

const removeSelectedAnuncios = async () => {
  if (selectedGrupoAnuncios.value.length === 0) {
    return
  }

  setLoading(true, 'Quitando anuncios del grupo...')

  try {
    const response = await execute(
      'gruposAnunciosfrm_remove_anuncios_from_grupo',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' },
        { nombre: 'p_anuncios', valor: JSON.stringify(selectedGrupoAnuncios.value), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      selectedGrupoAnuncios.value = []
      await Promise.all([
        loadAnunciosDisponibles(),
        loadAnunciosGrupo(selectedGrupo.value.id)
      ])
      showToast('success', 'Anuncios quitados del grupo')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al quitar anuncios',
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

const backToList = () => {
  currentView.value = 'list'
  selectedGrupo.value = null
  anunciosDisponibles.value = []
  anunciosGrupo.value = []
  selectedDisponibles.value = []
  selectedGrupoAnuncios.value = []
}

// Lifecycle
onMounted(async () => {
  await loadGiros()
  await loadGrupos()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
})
</script>

<style scoped>
.row {
  display: flex;
  margin: 0 -15px;
}

.col-md-6 {
  flex: 0 0 50%;
  max-width: 50%;
  padding: 0 15px;
}

.licencias-panel {
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
  background: white;
}

.panel-header {
  background: #f8f9fa;
  padding: 15px;
  border-bottom: 1px solid #ddd;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header h6 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}

.panel-body {
  padding: 15px;
  max-height: 500px;
  overflow-y: auto;
}

.licencias-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.licencia-item {
  padding: 12px;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  background: white;
  transition: all 0.2s;
}

.licencia-item:hover {
  background: #f8f9fa;
  border-color: #ea8215;
}

.licencia-grupo {
  background: #f0f8ff;
  border-color: #b3d9ff;
}

.checkbox-label {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  cursor: pointer;
  margin: 0;
}

.checkbox-label input[type="checkbox"] {
  margin-top: 3px;
  cursor: pointer;
}

.licencia-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.licencia-info strong {
  color: #333;
  font-size: 14px;
}

.licencia-info small {
  font-size: 12px;
  line-height: 1.4;
}
</style>
