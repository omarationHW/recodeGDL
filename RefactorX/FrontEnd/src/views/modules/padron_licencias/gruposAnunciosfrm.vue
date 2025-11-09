<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bullhorn" />
      </div>
      <div class="module-view-info">
        <h1>Grupos de Anuncios</h1>
        <p>Padrón de Licencias - Gestión de Grupos y Asignación de Anuncios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          v-if="currentView === 'list'"
          class="btn-municipal-success"
          @click="openCreateModal"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Grupo
        </button>
        <button
          v-if="currentView === 'list'"
          class="btn-municipal-primary"
          @click="loadGrupos"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          v-if="currentView === 'manage'"
          class="btn-municipal-secondary"
          @click="backToList"
        >
          <font-awesome-icon icon="arrow-left" />
          Volver a Lista
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Vista de Lista de Grupos -->
    <div v-if="currentView === 'list'">

      <!-- Tabla de grupos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Grupos Registrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="totalRecords > 0">
              {{ formatNumber(totalRecords) }} grupo{{ totalRecords !== 1 ? 's' : '' }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 10%;">
                    <font-awesome-icon icon="hashtag" class="me-2" />
                    ID
                  </th>
                  <th style="width: 60%;">
                    <font-awesome-icon icon="bullhorn" class="me-2" />
                    Descripción
                  </th>
                  <th style="width: 30%; text-align: center;">
                    <font-awesome-icon icon="cog" class="me-1" />
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="grupo in paginatedGrupos" :key="grupo.id" class="row-hover">
                  <td>
                    <strong class="text-primary">{{ grupo.id }}</strong>
                  </td>
                  <td>
                    <div class="giro-name">
                      <font-awesome-icon icon="bullhorn" class="giro-icon" />
                      <span class="giro-text">{{ grupo.descripcion || 'N/A' }}</span>
                    </div>
                  </td>
                  <td style="text-align: center;">
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
                <tr v-if="grupos.length === 0">
                  <td colspan="3" class="empty-state">
                    <div class="empty-state-content">
                      <font-awesome-icon icon="inbox" class="empty-state-icon" />
                      <p class="empty-state-text">No hay grupos registrados</p>
                      <p class="empty-state-hint">Presiona "Nuevo Grupo" para crear el primero</p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="pagination-container" v-if="totalRecords > 0">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
            de {{ totalRecords }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model="itemsPerPage" @change="changePageSize">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-button"
                :class="{ active: page === currentPage }"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="pagination-button"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
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

          <div class="row mt-4">
            <!-- Columna Izquierda: Anuncios Disponibles -->
            <div class="col-md-6">
              <div class="licencias-panel">
                <div class="panel-header">
                  <h6>
                    <font-awesome-icon icon="list" />
                    Anuncios Disponibles
                    <span class="badge-purple">{{ filteredAnunciosDisponibles.length }}</span>
                  </h6>
                  <button
                    class="btn-municipal-primary btn-sm"
                    @click="addSelectedAnuncios"
                    :disabled="selectedDisponibles.length === 0"
                  >
                    <font-awesome-icon icon="arrow-right" />
                    Agregar ({{ selectedDisponibles.length }})
                  </button>
                </div>
                <div class="panel-body">
                  <div class="licencias-list">
                    <div
                      v-for="anuncio in filteredAnunciosDisponibles"
                      :key="anuncio.anuncio"
                      class="licencia-item"
                    >
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          :value="anuncio.anuncio"
                          v-model="selectedDisponibles"
                        />
                        <span class="licencia-info">
                          <strong>{{ anuncio.anuncio }}</strong>
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
                    :disabled="selectedGrupoAnuncios.length === 0"
                  >
                    <font-awesome-icon icon="arrow-left" />
                    Quitar ({{ selectedGrupoAnuncios.length }})
                  </button>
                </div>
                <div class="panel-body">
                  <div class="licencias-list">
                    <div
                      v-for="anuncio in filteredAnunciosGrupo"
                      :key="anuncio.anuncio"
                      class="licencia-item licencia-grupo"
                    >
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          :value="anuncio.anuncio"
                          v-model="selectedGrupoAnuncios"
                        />
                        <span class="licencia-info">
                          <strong>{{ anuncio.anuncio }}</strong>
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

    </div>
    <!-- /module-view-content -->

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Grupo"
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'gruposAnunciosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
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

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)

// Formularios
const newGrupo = ref({
  descripcion: ''
})

const editForm = ref({
  id: null,
  descripcion: ''
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Computed para paginación de grupos
const paginatedGrupos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return grupos.value.slice(start, end)
})

// Computed SIN límite - muestra todos los anuncios
const filteredAnunciosDisponibles = computed(() => {
  let filtered = anunciosDisponibles.value

  if (selectedGiroFilter.value) {
    filtered = filtered.filter(
      anun => anun.id_giro === parseInt(selectedGiroFilter.value)
    )
  }

  return filtered
})

const filteredAnunciosGrupo = computed(() => {
  let filtered = anunciosGrupo.value

  if (selectedGiroFilter.value) {
    filtered = filtered.filter(
      anun => anun.id_giro === parseInt(selectedGiroFilter.value)
    )
  }

  return filtered
})

// Métodos
const loadGrupos = async () => {
  showLoading('Cargando grupos...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'GET_GRUPOS_ANUNCIOS',
      'padron_licencias',
      [],
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      grupos.value = response.result
      totalRecords.value = grupos.value.length

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', 'Grupos cargados correctamente', timeMessage)
    } else {
      grupos.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar grupos')
    }
  } catch (error) {
    handleApiError(error)
    grupos.value = []
    totalRecords.value = 0
  } finally {
    hideLoading()
  }
}

const loadGiros = async () => {
  try {
    const response = await execute(
      'GET_GIROS',
      'padron_licencias',
      [],
      'public'
    )

    if (response && response.result) {
      giros.value = response.result.filter(g => g.id_giro) // Solo giros tipo 'A'
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
      <div>
        <p>Se creará un nuevo grupo:</p>
        <p><strong>Descripción:</strong> ${newGrupo.value.descripcion}</p>
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
      'INSERT_GRUPO_ANUNCIO',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: newGrupo.value.descripcion, tipo: 'string' }
      ],
      'public'
    )

    console.log('INSERT Response:', response)

    // Verificar si tiene success=true O si tiene id/descripcion (formato antiguo)
    const hasSuccess = response?.result?.[0]?.success === true
    const hasIdDescripcion = response?.result?.[0]?.id && response?.result?.[0]?.descripcion

    if (response && response.result && (hasSuccess || hasIdDescripcion)) {
      showCreateModal.value = false
      creatingGrupo.value = false
      await loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo creado!',
        text: response.result[0]?.message || 'El grupo ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Grupo creado exitosamente')
    } else {
      creatingGrupo.value = false
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear grupo',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    creatingGrupo.value = false
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear el grupo',
      confirmButtonColor: '#ea8215'
    })
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
      <div>
        <p>Se actualizarán los datos del grupo:</p>
        <p><strong>ID:</strong> ${editForm.value.id}</p>
        <p><strong>Descripción:</strong> ${editForm.value.descripcion}</p>
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
      'UPDATE_GRUPO_ANUNCIO',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion, tipo: 'string' }
      ],
      'public'
    )

    console.log('UPDATE Response:', response)

    // Verificar si tiene success=true O si tiene id/descripcion (formato antiguo)
    const hasSuccess = response?.result?.[0]?.success === true
    const hasIdDescripcion = response?.result?.[0]?.id && response?.result?.[0]?.descripcion

    if (response && response.result && (hasSuccess || hasIdDescripcion)) {
      showEditModal.value = false
      updatingGrupo.value = false
      await loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo actualizado!',
        text: response.result[0]?.message || 'Los datos del grupo han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Grupo actualizado exitosamente')
    } else {
      updatingGrupo.value = false
      await Swal.fire({
        icon: 'error',
        title: 'Error al actualizar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    updatingGrupo.value = false
    handleApiError(error)
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
  showLoading('Eliminando grupo...')

  try {
    const response = await execute(
      'DELETE_GRUPO_ANUNCIO',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: grupo.id, tipo: 'integer' }
      ],
      'public'
    )

    console.log('DELETE Response:', response)

    hideLoading()

    // Verificar si tiene success=true O si tiene id/descripcion (formato antiguo)
    const hasSuccess = response?.result?.[0]?.success === true
    const hasIdDescripcion = response?.result?.[0]?.id && response?.result?.[0]?.descripcion

    if (response && response.result && (hasSuccess || hasIdDescripcion)) {
      await loadGrupos()

      await Swal.fire({
        icon: 'success',
        title: '¡Grupo eliminado!',
        text: response.result[0]?.message || 'El grupo ha sido eliminado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Grupo eliminado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al eliminar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
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
  showLoading('Cargando anuncios disponibles...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'GET_ANUNCIOS_DISPONIBLES',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' }
      ],
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      anunciosDisponibles.value = response.result

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', `${formatNumber(anunciosDisponibles.value.length)} anuncios disponibles`, timeMessage)
    } else {
      anunciosDisponibles.value = []
      showToast('warning', 'No se encontraron anuncios disponibles')
    }
  } catch (error) {
    handleApiError(error)
    anunciosDisponibles.value = []
  } finally {
    hideLoading()
  }
}

const loadAnunciosGrupo = async (grupoId) => {
  showLoading('Cargando anuncios del grupo...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'GET_ANUNCIOS_GRUPO',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: grupoId, tipo: 'integer' }
      ],
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      anunciosGrupo.value = response.result

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', `${formatNumber(anunciosGrupo.value.length)} anuncios en el grupo`, timeMessage)
    } else {
      anunciosGrupo.value = []
      showToast('warning', 'No se encontraron anuncios en el grupo')
    }
  } catch (error) {
    handleApiError(error)
    anunciosGrupo.value = []
  } finally {
    hideLoading()
  }
}

const addSelectedAnuncios = async () => {
  if (selectedDisponibles.value.length === 0) {
    return
  }

  // Confirmación antes de agregar
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Agregar anuncios al grupo?',
    html: `
      <div>
        <p>Se agregarán <strong>${selectedDisponibles.value.length}</strong> anuncio(s) al grupo:</p>
        <p><strong>${selectedGrupo.value.descripcion}</strong></p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, agregar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  showLoading('Agregando anuncios al grupo...')

  try {
    const response = await execute(
      'ADD_ANUNCIOS_TO_GRUPO',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' },
        { nombre: 'p_anuncios', valor: selectedDisponibles.value, tipo: 'integer_array' }
      ],
      'public'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      selectedDisponibles.value = []
      await Promise.all([
        loadAnunciosDisponibles(),
        loadAnunciosGrupo(selectedGrupo.value.id)
      ])

      await Swal.fire({
        icon: 'success',
        title: '¡Anuncios agregados!',
        text: response.result[0]?.message || 'Anuncios agregados al grupo exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Anuncios agregados al grupo')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al agregar anuncios',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const removeSelectedAnuncios = async () => {
  if (selectedGrupoAnuncios.value.length === 0) {
    return
  }

  // Confirmación antes de quitar
  const confirmResult = await Swal.fire({
    icon: 'warning',
    title: '¿Quitar anuncios del grupo?',
    html: `
      <div>
        <p>Se quitarán <strong>${selectedGrupoAnuncios.value.length}</strong> anuncio(s) del grupo:</p>
        <p><strong>${selectedGrupo.value.descripcion}</strong></p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, quitar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  showLoading('Quitando anuncios del grupo...')

  try {
    const response = await execute(
      'REMOVE_ANUNCIOS_FROM_GRUPO',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' },
        { nombre: 'p_anuncios', valor: selectedGrupoAnuncios.value, tipo: 'integer_array' }
      ],
      'public'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      selectedGrupoAnuncios.value = []
      await Promise.all([
        loadAnunciosDisponibles(),
        loadAnunciosGrupo(selectedGrupo.value.id)
      ])

      await Swal.fire({
        icon: 'success',
        title: '¡Anuncios quitados!',
        text: response.result[0]?.message || 'Anuncios quitados del grupo exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Anuncios quitados del grupo')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al quitar anuncios',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
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

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = () => {
  currentPage.value = 1
}

// Utilidades
const formatNumber = (value) => {
  if (!value && value !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(value)
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
