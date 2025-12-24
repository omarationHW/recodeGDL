<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building-user" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Tipos de Empresa</h1>
        <p>Aseo Contratado - Gestión de Tipos de Empresa</p>
      </div>
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
          Nuevo Tipo
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.search"
                placeholder="Descripción o código..."
                @keyup.enter="searchTiposEmp"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchTiposEmp"
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
              @click="loadTiposEmp"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarExcel"
              :disabled="loading || tiposEmp.length === 0"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Tipos de Empresa Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Tipo Empresa</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="tiposEmp.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="building-user" size="2x" class="empty-icon" />
                    <p>No se encontraron tipos de empresa registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="tipo in tiposEmp" :key="tipo.tipo_empresa" class="row-hover">
                  <td><strong class="text-primary">{{ tipo.tipo_empresa }}</strong></td>
                  <td>{{ tipo.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewTipoEmp(tipo)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editTipoEmp(tipo)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDeleteTipoEmp(tipo)"
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

        <!-- Paginación -->
        <div class="pagination-container" v-if="totalRecords > 0 && !loading">
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

      <!-- Loading overlay -->
      <div v-if="loading && tiposEmp.length === 0" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando tipos de empresa...</p>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Tipo de Empresa"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createTipoEmp"
      :loading="creatingTipoEmp"
      confirmText="Crear Tipo"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createTipoEmp">
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newTipoEmp.descripcion"
            maxlength="100"
            required
          />
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Tipo de Empresa: ${selectedTipoEmp?.descripcion}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateTipoEmp"
      :loading="updatingTipoEmp"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateTipoEmp">
        <div class="form-group full-width">
          <label class="municipal-form-label">Tipo Empresa:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="editForm.tipo_empresa"
            disabled
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.descripcion"
            maxlength="100"
            required
          />
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Tipo de Empresa: ${selectedTipoEmp?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedTipoEmp" class="empresa-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Tipo Empresa:</td>
                <td><code>{{ selectedTipoEmp.tipo_empresa }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedTipoEmp.descripcion }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editTipoEmp(selectedTipoEmp); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Tipo
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

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Tipos_Emp'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
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
const tiposEmp = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedTipoEmp = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingTipoEmp = ref(false)
const updatingTipoEmp = ref(false)

// Filtros
const filters = ref({
  search: ''
})

// Formularios
const newTipoEmp = ref({
  descripcion: ''
})

const editForm = ref({
  tipo_empresa: null,
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

// Métodos
const loadTiposEmp = async () => {
  setLoading(true, 'Cargando tipos de empresa...')

  try {
    const response = await execute(
      'SP_ASEO_TIPOS_EMP_LIST',
      'aseo_contratado',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_search', valor: filters.value.search || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      tiposEmp.value = response.result
      if (tiposEmp.value.length > 0) {
        totalRecords.value = parseInt(tiposEmp.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Tipos de empresa cargados correctamente')
    } else {
      tiposEmp.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar tipos de empresa')
    }
  } catch (error) {
    handleApiError(error)
    tiposEmp.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchTiposEmp = () => {
  currentPage.value = 1
  loadTiposEmp()
}

const clearFilters = () => {
  filters.value = {
    search: ''
  }
  currentPage.value = 1
  loadTiposEmp()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadTiposEmp()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadTiposEmp()
}

const openCreateModal = () => {
  newTipoEmp.value = {
    descripcion: ''
  }
  showCreateModal.value = true
}

const createTipoEmp = async () => {
  if (!newTipoEmp.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de tipo de empresa?',
    html: `
      <p>Se creará un nuevo tipo de empresa con los siguientes datos:</p>
      <ul class="list-unstyled-left">
        <li><strong>Descripción:</strong> ${newTipoEmp.value.descripcion}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear tipo',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  creatingTipoEmp.value = true

  try {
    const response = await execute(
      'SP_ASEO_TIPOS_EMP_CREATE',
      'aseo_contratado',
      [
        { nombre: 'p_descripcion', valor: newTipoEmp.value.descripcion },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadTiposEmp()

      await Swal.fire({
        icon: 'success',
        title: '¡Tipo de empresa creado!',
        text: 'El tipo de empresa ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Tipo de empresa creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear tipo de empresa',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingTipoEmp.value = false
  }
}

const editTipoEmp = (tipo) => {
  selectedTipoEmp.value = tipo
  editForm.value = {
    tipo_empresa: tipo.tipo_empresa,
    descripcion: tipo.descripcion
  }
  showEditModal.value = true
}

const updateTipoEmp = async () => {
  if (!editForm.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <p>Se actualizarán los datos del tipo de empresa:</p>
      <ul class="list-unstyled-left">
        <li><strong>Tipo Empresa:</strong> ${editForm.value.tipo_empresa}</li>
        <li><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  updatingTipoEmp.value = true

  try {
    const response = await execute(
      'SP_ASEO_TIPOS_EMP_UPDATE',
      'aseo_contratado',
      [
        { nombre: 'p_tipo_empresa', valor: editForm.value.tipo_empresa },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadTiposEmp()

      await Swal.fire({
        icon: 'success',
        title: '¡Tipo de empresa actualizado!',
        text: 'Los datos han sido actualizados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Tipo de empresa actualizado exitosamente')
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
    updatingTipoEmp.value = false
  }
}

const viewTipoEmp = (tipo) => {
  selectedTipoEmp.value = tipo
  showViewModal.value = true
}

const confirmDeleteTipoEmp = async (tipo) => {
  const result = await Swal.fire({
    title: '¿Eliminar tipo de empresa?',
    html: `
      <p>¿Está seguro de eliminar el tipo de empresa:</p>
      <p><strong>${tipo.descripcion}</strong>?</p>
      <p class="text-danger">Esta acción no se puede deshacer</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteTipoEmp(tipo)
  }
}

const deleteTipoEmp = async (tipo) => {
  try {
    const response = await execute(
      'SP_ASEO_TIPOS_EMP_DELETE',
      'aseo_contratado',
      [
        { nombre: 'p_tipo_empresa', valor: tipo.tipo_empresa },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadTiposEmp()

      await Swal.fire({
        icon: 'success',
        title: '¡Tipo de empresa eliminado!',
        text: 'El tipo de empresa ha sido eliminado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Tipo de empresa eliminado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'Error al eliminar el tipo de empresa',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  }
}

const exportarExcel = async () => {
  await Swal.fire({
    title: 'Exportar a Excel',
    text: 'Funcionalidad en desarrollo',
    icon: 'info',
    confirmButtonColor: '#ea8215'
  })
}

// Lifecycle
onMounted(() => {
  loadTiposEmp()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
