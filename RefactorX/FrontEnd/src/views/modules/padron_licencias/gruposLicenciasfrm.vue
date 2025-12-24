<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="layer-group" />
      </div>
      <div class="module-view-info">
        <h1>Grupos de Licencias</h1>
        <p>Padrón de Licencias - Gestión de Grupos y Asignación de Licencias</p>
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
          class="btn-municipal-warning"
          @click="backToList"
        >
          <font-awesome-icon icon="arrow-left" />
          Volver a Lista
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
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
                    <font-awesome-icon icon="layer-group" class="me-2" />
                    Descripción
                  </th>
                  <th style="width: 30%; text-align: center;">
                    <font-awesome-icon icon="cog" class="me-1" />
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="grupo in paginatedGrupos"
                  :key="grupo.id"
                  @click="selectedRow = grupo"
                  :class="{ 'table-row-selected': selectedRow === grupo }"
                  class="row-hover"
                >
                  <td>
                    <strong class="text-primary">{{ grupo.id }}</strong>
                  </td>
                  <td>
                    <div class="giro-name">
                      <font-awesome-icon icon="layer-group" class="giro-icon" />
                      <span class="giro-text">{{ grupo.descripcion || 'N/A' }}</span>
                    </div>
                  </td>
                  <td style="text-align: center;">
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click.stop="manageLicencias(grupo)"
                        title="Gestionar licencias"
                      >
                        <font-awesome-icon icon="cog" />
                        Licencias
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
        <div v-if="grupos.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ formatNumber(totalRecords) }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="itemsPerPage"
              @change="changePageSize($event.target.value)"
              style="width: auto; display: inline-block;"
            >
              <option value="5">5</option>
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
              <font-awesome-icon icon="angle-double-left" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
              <font-awesome-icon icon="angle-left" />
            </button>
            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
              <font-awesome-icon icon="angle-right" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
              <font-awesome-icon icon="angle-double-right" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Vista de Gestión de Licencias -->
    <div v-if="currentView === 'manage'">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="layer-group" />
            Gestión de Licencias - {{ selectedGrupo?.descripcion }}
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
            <!-- Columna Izquierda: Licencias Disponibles -->
            <div class="col-md-6">
              <div class="licencias-panel">
                <div class="panel-header">
                  <h6>
                    <font-awesome-icon icon="list" />
                    Licencias Disponibles
                    <span class="badge-purple">{{ filteredLicenciasDisponibles.length }}</span>
                  </h6>
                  <button
                    class="btn-municipal-primary btn-sm"
                    @click="addSelectedLicencias"
                    :disabled="selectedDisponibles.length === 0"
                  >
                    <font-awesome-icon icon="arrow-right" />
                    Agregar ({{ selectedDisponibles.length }})
                  </button>
                </div>
                <div class="panel-body">
                  <div class="licencias-list">
                    <div
                      v-for="licencia in filteredLicenciasDisponibles"
                      :key="licencia.licencia"
                      class="licencia-item"
                    >
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          :value="licencia.licencia"
                          v-model="selectedDisponibles"
                        />
                        <span class="licencia-info">
                          <strong>{{ licencia.licencia }}</strong>
                          <small class="text-muted">{{ licencia.descripcion }}</small>
                        </span>
                      </label>
                    </div>
                    <div v-if="filteredLicenciasDisponibles.length === 0" class="text-center text-muted">
                      <p>No hay licencias disponibles</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Columna Derecha: Licencias en el Grupo -->
            <div class="col-md-6">
              <div class="licencias-panel">
                <div class="panel-header">
                  <h6>
                    <font-awesome-icon icon="check-circle" />
                    Licencias en el Grupo
                    <span class="badge-success">{{ filteredLicenciasGrupo.length }}</span>
                  </h6>
                  <button
                    class="btn-municipal-danger btn-sm"
                    @click="removeSelectedLicencias"
                    :disabled="selectedGrupoLicencias.length === 0"
                  >
                    <font-awesome-icon icon="arrow-left" />
                    Quitar ({{ selectedGrupoLicencias.length }})
                  </button>
                </div>
                <div class="panel-body">
                  <div class="licencias-list">
                    <div
                      v-for="licencia in filteredLicenciasGrupo"
                      :key="licencia.licencia"
                      class="licencia-item licencia-grupo"
                    >
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          :value="licencia.licencia"
                          v-model="selectedGrupoLicencias"
                        />
                        <span class="licencia-info">
                          <strong>{{ licencia.licencia }}</strong>
                          <small class="text-muted">{{ licencia.descripcion }}</small>
                        </span>
                      </label>
                    </div>
                    <div v-if="filteredLicenciasGrupo.length === 0" class="text-center text-muted">
                      <p>No hay licencias en este grupo</p>
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
      :componentName="'gruposLicenciasfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Grupos de Licencias'"
      @close="showDocModal = false"
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

// Variables de estado
const selectedRow = ref(null)
const hasSearched = ref(false)

// Estado
const currentView = ref('list') // 'list' | 'manage'
const grupos = ref([])
const giros = ref([])
const licenciasDisponibles = ref([])
const licenciasGrupo = ref([])
const selectedGrupo = ref(null)
const selectedGiroFilter = ref('')
const selectedDisponibles = ref([])
const selectedGrupoLicencias = ref([])
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
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
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

// Computed SIN límite - muestra todas las licencias
const filteredLicenciasDisponibles = computed(() => {
  let filtered = licenciasDisponibles.value

  if (selectedGiroFilter.value) {
    filtered = filtered.filter(
      lic => lic.id_giro === parseInt(selectedGiroFilter.value)
    )
  }

  return filtered
})

const filteredLicenciasGrupo = computed(() => {
  let filtered = licenciasGrupo.value

  if (selectedGiroFilter.value) {
    filtered = filtered.filter(
      lic => lic.id_giro === parseInt(selectedGiroFilter.value)
    )
  }

  return filtered
})

// Métodos
const loadGrupos = async () => {
  showLoading('Cargando grupos...')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(
      'GET_GRUPOS_LICENCIAS',
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
      'INSERT_GRUPO_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: newGrupo.value.descripcion, tipo: 'string' }
      ],
      'public'
    )

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
      'UPDATE_GRUPO_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion, tipo: 'string' }
      ],
      'public'
    )

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
      'DELETE_GRUPO_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: grupo.id, tipo: 'integer' }
      ],
      'public'
    )

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

const manageLicencias = async (grupo) => {
  selectedGrupo.value = grupo
  selectedDisponibles.value = []
  selectedGrupoLicencias.value = []
  selectedGiroFilter.value = ''
  currentView.value = 'manage'

  await Promise.all([
    loadLicenciasDisponibles(),
    loadLicenciasGrupo(grupo.id)
  ])
}

const loadLicenciasDisponibles = async () => {
  showLoading('Cargando licencias disponibles...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'GET_LICENCIAS_DISPONIBLES',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' }
      ],
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      licenciasDisponibles.value = response.result

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', `${formatNumber(licenciasDisponibles.value.length)} licencias disponibles`, timeMessage)
    } else {
      licenciasDisponibles.value = []
      showToast('warning', 'No se encontraron licencias disponibles')
    }
  } catch (error) {
    handleApiError(error)
    licenciasDisponibles.value = []
  } finally {
    hideLoading()
  }
}

const loadLicenciasGrupo = async (grupoId) => {
  showLoading('Cargando licencias del grupo...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'GET_LICENCIAS_GRUPO',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: grupoId, tipo: 'integer' }
      ],
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      licenciasGrupo.value = response.result

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast('success', `${formatNumber(licenciasGrupo.value.length)} licencias en el grupo`, timeMessage)
    } else {
      licenciasGrupo.value = []
      showToast('warning', 'No se encontraron licencias en el grupo')
    }
  } catch (error) {
    handleApiError(error)
    licenciasGrupo.value = []
  } finally {
    hideLoading()
  }
}

const addSelectedLicencias = async () => {
  if (selectedDisponibles.value.length === 0) {
    return
  }

  // Confirmación antes de agregar
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Agregar licencias al grupo?',
    html: `
      <div>
        <p>Se agregarán <strong>${selectedDisponibles.value.length}</strong> licencia(s) al grupo:</p>
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

  showLoading('Agregando licencias al grupo...')

  try {
    const response = await execute(
      'ADD_LICENCIAS_TO_GRUPO',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' },
        { nombre: 'p_licencias', valor: selectedDisponibles.value, tipo: 'integer_array' }
      ],
      'public'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      selectedDisponibles.value = []
      await Promise.all([
        loadLicenciasDisponibles(),
        loadLicenciasGrupo(selectedGrupo.value.id)
      ])

      await Swal.fire({
        icon: 'success',
        title: '¡Licencias agregadas!',
        text: response.result[0]?.message || 'Licencias agregadas al grupo exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Licencias agregadas al grupo')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al agregar licencias',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const removeSelectedLicencias = async () => {
  if (selectedGrupoLicencias.value.length === 0) {
    return
  }

  // Confirmación antes de quitar
  const confirmResult = await Swal.fire({
    icon: 'warning',
    title: '¿Quitar licencias del grupo?',
    html: `
      <div>
        <p>Se quitarán <strong>${selectedGrupoLicencias.value.length}</strong> licencia(s) del grupo:</p>
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

  showLoading('Quitando licencias del grupo...')

  try {
    const response = await execute(
      'REMOVE_LICENCIAS_FROM_GRUPO',
      'padron_licencias',
      [
        { nombre: 'p_grupo_id', valor: selectedGrupo.value.id, tipo: 'integer' },
        { nombre: 'p_licencias', valor: selectedGrupoLicencias.value, tipo: 'integer_array' }
      ],
      'public'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      selectedGrupoLicencias.value = []
      await Promise.all([
        loadLicenciasDisponibles(),
        loadLicenciasGrupo(selectedGrupo.value.id)
      ])

      await Swal.fire({
        icon: 'success',
        title: '¡Licencias quitadas!',
        text: response.result[0]?.message || 'Licencias quitadas del grupo exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', response.result[0]?.message || 'Licencias quitadas del grupo')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al quitar licencias',
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
  licenciasDisponibles.value = []
  licenciasGrupo.value = []
  selectedDisponibles.value = []
  selectedGrupoLicencias.value = []
}

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedRow.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
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
