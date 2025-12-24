<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-check-alt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Empresas Recaudadoras</h1>
        <p>Aseo Contratado - Administración de empresas recaudadoras</p>
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
          Nueva Recaudadora
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
                v-model="searchQuery"
                placeholder="Descripción o número..."
                @keyup.enter="handleSearch"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="handleSearch"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearSearch"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="loadRecaudadoras"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportToExcel"
              :disabled="loading || recaudadoras.length === 0"
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
            Recaudadoras Registradas
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
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
                <tr v-if="recaudadoras.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron recaudadoras</p>
                  </td>
                </tr>
                <tr v-else v-for="recaudadora in recaudadoras" :key="recaudadora.num_rec" class="row-hover">
                  <td>
                    <span class="badge badge-success">{{ recaudadora.num_rec }}</span>
                  </td>
                  <td>{{ recaudadora.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="openViewModal(recaudadora)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="openEditModal(recaudadora)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDelete(recaudadora)"
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

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, totalRecords) }} de {{ totalRecords }} registros
            </div>
            <div class="pagination">
              <button
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                class="pagination-btn"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                class="pagination-btn"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <template v-for="page in paginationRange" :key="page">
                <button
                  v-if="page !== '...'"
                  @click="goToPage(page)"
                  :class="['pagination-btn', { active: currentPage === page }]"
                >
                  {{ page }}
                </button>
                <span v-else class="pagination-ellipsis">...</span>
              </template>

              <button
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                class="pagination-btn"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                class="pagination-btn"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>

        <div class="municipal-card-body" v-else>
          <div class="loading-state">
            <div class="spinner"></div>
            <p>Cargando recaudadoras...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <Modal
      :show="showCreateModal"
      @close="closeCreateModal"
      title="Nueva Empresa Recaudadora"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="createRecaudadora" class="modal-form">
          <div class="form-group">
            <label for="descripcion" class="municipal-form-label required">Descripción</label>
            <input
              type="text"
              id="descripcion"
              v-model="formData.descripcion"
              class="municipal-form-control"
              maxlength="100"
              placeholder="Nombre de la empresa recaudadora"
              required
            />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeCreateModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="createRecaudadora" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Crear Recaudadora
        </button>
      </template>
    </Modal>

    <!-- Modal Editar -->
    <Modal
      :show="showEditModal"
      @close="closeEditModal"
      title="Editar Empresa Recaudadora"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="updateRecaudadora" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Número</label>
            <input
              type="text"
              :value="formData.num_rec"
              class="municipal-form-control"
              disabled
            />
          </div>

          <div class="form-group">
            <label for="edit_descripcion" class="municipal-form-label required">Descripción</label>
            <input
              type="text"
              id="edit_descripcion"
              v-model="formData.descripcion"
              class="municipal-form-control"
              maxlength="100"
              required
            />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeEditModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="updateRecaudadora" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <!-- Modal Ver -->
    <Modal
      :show="showViewModal"
      @close="closeViewModal"
      title="Detalle de la Recaudadora"
      size="medium"
    >
      <template #body>
        <div class="detail-grid">
          <div class="detail-item">
            <label class="detail-label">Número</label>
            <p class="detail-value">
              <span class="badge badge-success">{{ viewData.num_rec }}</span>
            </p>
          </div>

          <div class="detail-item full-width">
            <label class="detail-label">Descripción</label>
            <p class="detail-value">{{ viewData.descripcion }}</p>
          </div>
        </div>
      </template>
      <template #footer>
        <button type="button" @click="closeViewModal" class="btn-secondary">
          Cerrar
        </button>
        <button type="button" @click="editFromView" class="btn-primary">
          <font-awesome-icon icon="edit" />
          Editar
        </button>
      </template>
    </Modal>

    <!-- Modal Documentación -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Catálogo de Recaudadoras"
    >
      <h3>Catálogo de Empresas Recaudadoras</h3>
      <p>
        Este módulo permite administrar el catálogo de empresas recaudadoras
        que participan en el servicio de aseo contratado.
      </p>

      <h4>Funcionalidades Principales:</h4>
      <ul>
        <li><strong>Crear:</strong> Agregar nuevas empresas recaudadoras</li>
        <li><strong>Editar:</strong> Modificar información de recaudadoras existentes</li>
        <li><strong>Eliminar:</strong> Dar de baja recaudadoras no utilizadas</li>
        <li><strong>Buscar:</strong> Filtrar recaudadoras por descripción o número</li>
        <li><strong>Exportar:</strong> Generar archivo Excel con el catálogo</li>
      </ul>

      <h4>Campos:</h4>
      <ul>
        <li><strong>Número:</strong> Identificador único asignado automáticamente</li>
        <li><strong>Descripción:</strong> Nombre de la empresa recaudadora (obligatorio)</li>
      </ul>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>El número se asigna automáticamente al crear una recaudadora</li>
        <li>La descripción debe ser única en el catálogo</li>
        <li>No se puede eliminar una recaudadora que esté en uso</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

// Data
const recaudadoras = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const searchQuery = ref('')
const loading = ref(false)
const showDocumentation = ref(false)

// Modales
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)

// Form Data
const formData = ref({
  num_rec: null,
  descripcion: ''
})

const viewData = ref({})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginationRange = computed(() => {
  const range = []
  const delta = 2

  for (let i = Math.max(2, currentPage.value - delta); i <= Math.min(totalPages.value - 1, currentPage.value + delta); i++) {
    range.push(i)
  }

  if (currentPage.value - delta > 2) {
    range.unshift('...')
  }
  if (currentPage.value + delta < totalPages.value - 1) {
    range.push('...')
  }

  range.unshift(1)
  if (totalPages.value > 1) {
    range.push(totalPages.value)
  }

  return range
})

// Methods
const loadRecaudadoras = async () => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_RECAUDADORAS_LIST',
      'aseo_contratado',
      {
        p_page: currentPage.value,
        p_limit: itemsPerPage.value,
        p_search: searchQuery.value || null
      }
    )

    if (response && response.data) {
      recaudadoras.value = response.data
      if (response.data.length > 0) {
        totalRecords.value = response.data[0].total_records || 0
      } else {
        totalRecords.value = 0
      }
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error)
    showToast('Error al cargar las recaudadoras', 'error')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadRecaudadoras()
}

const clearSearch = () => {
  searchQuery.value = ''
  handleSearch()
}

const handleItemsPerPageChange = () => {
  currentPage.value = 1
  loadRecaudadoras()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadRecaudadoras()
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

// Create
const openCreateModal = () => {
  formData.value = {
    num_rec: null,
    descripcion: ''
  }
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
}

const createRecaudadora = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_RECAUDADORAS_CREATE',
      'aseo_contratado',
      {
        p_descripcion: formData.value.descripcion.trim()
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Recaudadora creada exitosamente', 'success')
        closeCreateModal()
        loadRecaudadoras()
      } else {
        showToast(result.message || 'Error al crear la recaudadora', 'error')
      }
    }
  } catch (error) {
    console.error('Error al crear recaudadora:', error)
    showToast('Error al crear la recaudadora', 'error')
  } finally {
    loading.value = false
  }
}

// Edit
const openEditModal = (recaudadora) => {
  formData.value = {
    num_rec: recaudadora.num_rec,
    descripcion: recaudadora.descripcion || ''
  }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const updateRecaudadora = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_RECAUDADORAS_UPDATE',
      'aseo_contratado',
      {
        p_num_rec: formData.value.num_rec,
        p_descripcion: formData.value.descripcion.trim()
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Recaudadora actualizada exitosamente', 'success')
        closeEditModal()
        loadRecaudadoras()
      } else {
        showToast(result.message || 'Error al actualizar la recaudadora', 'error')
      }
    }
  } catch (error) {
    console.error('Error al actualizar recaudadora:', error)
    showToast('Error al actualizar la recaudadora', 'error')
  } finally {
    loading.value = false
  }
}

// View
const openViewModal = (recaudadora) => {
  viewData.value = { ...recaudadora }
  showViewModal.value = true
}

const closeViewModal = () => {
  showViewModal.value = false
}

const editFromView = () => {
  closeViewModal()
  openEditModal(viewData.value)
}

// Delete
const confirmDelete = async (recaudadora) => {
  const result = await Swal.fire({
    title: '¿Eliminar recaudadora?',
    html: `
      <p>¿Está seguro de eliminar la recaudadora:</p>
      <p><strong>${recaudadora.descripcion}</strong>?</p>
      <p class="text-danger">Esta acción no se puede deshacer.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteRecaudadora(recaudadora.num_rec)
  }
}

const deleteRecaudadora = async (num_rec) => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_RECAUDADORAS_DELETE',
      'aseo_contratado',
      {
        p_num_rec: num_rec
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Recaudadora eliminada exitosamente', 'success')
        loadRecaudadoras()
      } else {
        showToast(result.message || 'Error al eliminar la recaudadora', 'error')
      }
    }
  } catch (error) {
    console.error('Error al eliminar recaudadora:', error)
    showToast('Error al eliminar la recaudadora', 'error')
  } finally {
    loading.value = false
  }
}

// Export
const exportToExcel = () => {
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

// Lifecycle
onMounted(() => {
  loadRecaudadoras()
})
</script>
