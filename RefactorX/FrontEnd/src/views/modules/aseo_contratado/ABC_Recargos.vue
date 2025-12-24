<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percent" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Recargos</h1>
        <p>Aseo Contratado - Gestión de Recargos Aplicables</p>
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
          Nuevo Recargo
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
                placeholder="Descripción, ID o porcentaje..."
                @keyup.enter="searchRecargos"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchRecargos"
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
              @click="loadRecargos"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarExcel"
              :disabled="loading || recargos.length === 0"
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
            Recargos Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Recargo</th>
                  <th>Descripción</th>
                  <th>Porcentaje</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="recargos.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="percent" size="2x" class="empty-icon" />
                    <p>No se encontraron recargos registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="recargo in recargos" :key="recargo.id_recargo" class="row-hover">
                  <td><strong class="text-primary">{{ recargo.id_recargo }}</strong></td>
                  <td>{{ recargo.descripcion }}</td>
                  <td>
                    <span class="badge-secondary">{{ recargo.porcentaje }}%</span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewRecargo(recargo)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editRecargo(recargo)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDeleteRecargo(recargo)"
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
      <div v-if="loading && recargos.length === 0" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando recargos...</p>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Recargo"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createRecargo"
      :loading="creatingRecargo"
      confirmText="Crear Recargo"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createRecargo">
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newRecargo.descripcion"
            maxlength="100"
            required
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Porcentaje (%): <span class="required">*</span></label>
          <input
            type="number"
            class="municipal-form-control"
            v-model="newRecargo.porcentaje"
            step="0.01"
            min="0"
            max="999.99"
            required
          />
          <small class="form-text">
            Ingrese el porcentaje de recargo (0.00 - 999.99)
          </small>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Recargo: ${selectedRecargo?.descripcion}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateRecargo"
      :loading="updatingRecargo"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateRecargo">
        <div class="form-group full-width">
          <label class="municipal-form-label">ID Recargo:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="editForm.id_recargo"
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
        <div class="form-group full-width">
          <label class="municipal-form-label">Porcentaje (%): <span class="required">*</span></label>
          <input
            type="number"
            class="municipal-form-control"
            v-model="editForm.porcentaje"
            step="0.01"
            min="0"
            max="999.99"
            required
          />
          <small class="form-text">
            Ingrese el porcentaje de recargo (0.00 - 999.99)
          </small>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Recargo: ${selectedRecargo?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedRecargo" class="empresa-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información del Recargo
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Recargo:</td>
                <td><code>{{ selectedRecargo.id_recargo }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedRecargo.descripcion }}</td>
              </tr>
              <tr>
                <td class="label">Porcentaje:</td>
                <td>
                  <span class="badge-secondary">{{ selectedRecargo.porcentaje }}%</span>
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
          <button class="btn-municipal-primary" @click="editRecargo(selectedRecargo); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Recargo
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
    :componentName="'ABC_Recargos'"
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
const recargos = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedRecargo = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingRecargo = ref(false)
const updatingRecargo = ref(false)

// Filtros
const filters = ref({
  search: ''
})

// Formularios
const newRecargo = ref({
  descripcion: '',
  porcentaje: null
})

const editForm = ref({
  id_recargo: null,
  descripcion: '',
  porcentaje: null
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
const loadRecargos = async () => {
  setLoading(true, 'Cargando recargos...')

  try {
    const response = await execute(
      'SP_ASEO_RECARGOS_LIST',
      'aseo_contratado',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_search', valor: filters.value.search || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      recargos.value = response.result
      if (recargos.value.length > 0) {
        totalRecords.value = parseInt(recargos.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Recargos cargados correctamente')
    } else {
      recargos.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar recargos')
    }
  } catch (error) {
    handleApiError(error)
    recargos.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchRecargos = () => {
  currentPage.value = 1
  loadRecargos()
}

const clearFilters = () => {
  filters.value = {
    search: ''
  }
  currentPage.value = 1
  loadRecargos()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadRecargos()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadRecargos()
}

const openCreateModal = () => {
  newRecargo.value = {
    descripcion: '',
    porcentaje: null
  }
  showCreateModal.value = true
}

const createRecargo = async () => {
  if (!newRecargo.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (newRecargo.value.porcentaje === null || newRecargo.value.porcentaje === '') {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El porcentaje es obligatorio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de recargo?',
    html: `
      <p>Se creará un nuevo recargo con los siguientes datos:</p>
      <ul class="list-unstyled-left">
        <li><strong>Descripción:</strong> ${newRecargo.value.descripcion}</li>
        <li><strong>Porcentaje:</strong> ${newRecargo.value.porcentaje}%</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear recargo',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  creatingRecargo.value = true

  try {
    const response = await execute(
      'SP_ASEO_RECARGOS_CREATE',
      'aseo_contratado',
      [
        { nombre: 'p_descripcion', valor: newRecargo.value.descripcion },
        { nombre: 'p_porcentaje', valor: newRecargo.value.porcentaje },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadRecargos()

      await Swal.fire({
        icon: 'success',
        title: '¡Recargo creado!',
        text: 'El recargo ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Recargo creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear recargo',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingRecargo.value = false
  }
}

const editRecargo = (recargo) => {
  selectedRecargo.value = recargo
  editForm.value = {
    id_recargo: recargo.id_recargo,
    descripcion: recargo.descripcion,
    porcentaje: recargo.porcentaje
  }
  showEditModal.value = true
}

const updateRecargo = async () => {
  if (!editForm.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (editForm.value.porcentaje === null || editForm.value.porcentaje === '') {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El porcentaje es obligatorio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <p>Se actualizarán los datos del recargo:</p>
      <ul class="list-unstyled-left">
        <li><strong>ID Recargo:</strong> ${editForm.value.id_recargo}</li>
        <li><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
        <li><strong>Porcentaje:</strong> ${editForm.value.porcentaje}%</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  updatingRecargo.value = true

  try {
    const response = await execute(
      'SP_ASEO_RECARGOS_UPDATE',
      'aseo_contratado',
      [
        { nombre: 'p_id_recargo', valor: editForm.value.id_recargo },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion },
        { nombre: 'p_porcentaje', valor: editForm.value.porcentaje },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadRecargos()

      await Swal.fire({
        icon: 'success',
        title: '¡Recargo actualizado!',
        text: 'Los datos han sido actualizados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Recargo actualizado exitosamente')
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
    updatingRecargo.value = false
  }
}

const viewRecargo = (recargo) => {
  selectedRecargo.value = recargo
  showViewModal.value = true
}

const confirmDeleteRecargo = async (recargo) => {
  const result = await Swal.fire({
    title: '¿Eliminar recargo?',
    html: `
      <p>¿Está seguro de eliminar el recargo:</p>
      <p><strong>${recargo.descripcion}</strong>?</p>
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
    await deleteRecargo(recargo)
  }
}

const deleteRecargo = async (recargo) => {
  try {
    const response = await execute(
      'SP_ASEO_RECARGOS_DELETE',
      'aseo_contratado',
      [
        { nombre: 'p_id_recargo', valor: recargo.id_recargo },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadRecargos()

      await Swal.fire({
        icon: 'success',
        title: '¡Recargo eliminado!',
        text: 'El recargo ha sido eliminado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Recargo eliminado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'Error al eliminar el recargo',
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
  loadRecargos()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
