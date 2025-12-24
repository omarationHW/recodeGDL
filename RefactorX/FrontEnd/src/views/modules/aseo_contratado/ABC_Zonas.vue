<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Zonas de Recolección</h1>
        <p>Aseo Contratado - Administración de zonas y sub-zonas</p>
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
          Nueva Zona
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
                placeholder="Descripción, zona o sub-zona..."
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
              @click="loadZonas"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportToExcel"
              :disabled="loading || zonas.length === 0"
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
            Zonas Registradas
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Zona</th>
                  <th>Sub-Zona</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="zonas.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron zonas</p>
                  </td>
                </tr>
                <tr v-else v-for="zona in zonas" :key="zona.ctrol_zona" class="row-hover">
                  <td>
                    <span class="badge-control">{{ String(zona.ctrol_zona).padStart(3, '0') }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-info">{{ zona.zona }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-secondary">{{ zona.sub_zona }}</span>
                  </td>
                  <td>{{ zona.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="openViewModal(zona)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="openEditModal(zona)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDelete(zona)"
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
            <p>Cargando zonas...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <Modal
      :show="showCreateModal"
      @close="closeCreateModal"
      title="Nueva Zona de Recolección"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="createZona" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label for="zona" class="municipal-form-label required">Zona</label>
              <input
                type="number"
                id="zona"
                v-model="formData.zona"
                class="municipal-form-control"
                placeholder="Número de zona"
                required
              />
            </div>

            <div class="form-group">
              <label for="sub_zona" class="municipal-form-label required">Sub-Zona</label>
              <input
                type="number"
                id="sub_zona"
                v-model="formData.sub_zona"
                class="municipal-form-control"
                placeholder="Número de sub-zona"
                required
              />
            </div>
          </div>

          <div class="form-group">
            <label for="descripcion" class="municipal-form-label required">Descripción</label>
            <input
              type="text"
              id="descripcion"
              v-model="formData.descripcion"
              class="municipal-form-control"
              maxlength="100"
              placeholder="Descripción de la zona"
              required
            />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeCreateModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="createZona" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Crear Zona
        </button>
      </template>
    </Modal>

    <!-- Modal Editar -->
    <Modal
      :show="showEditModal"
      @close="closeEditModal"
      title="Editar Zona de Recolección"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="updateZona" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Control</label>
            <input
              type="text"
              :value="String(formData.ctrol_zona).padStart(3, '0')"
              class="municipal-form-control"
              disabled
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="edit_zona" class="municipal-form-label required">Zona</label>
              <input
                type="number"
                id="edit_zona"
                v-model="formData.zona"
                class="municipal-form-control"
                required
              />
            </div>

            <div class="form-group">
              <label for="edit_sub_zona" class="municipal-form-label required">Sub-Zona</label>
              <input
                type="number"
                id="edit_sub_zona"
                v-model="formData.sub_zona"
                class="municipal-form-control"
                required
              />
            </div>
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
        <button type="button" @click="updateZona" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <!-- Modal Ver -->
    <Modal
      :show="showViewModal"
      @close="closeViewModal"
      title="Detalle de la Zona"
      size="medium"
    >
      <template #body>
        <div class="detail-grid">
          <div class="detail-item">
            <label class="detail-label">Control</label>
            <p class="detail-value">
              <span class="badge-control">{{ String(viewData.ctrol_zona).padStart(3, '0') }}</span>
            </p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Zona</label>
            <p class="detail-value">
              <span class="badge badge-info">{{ viewData.zona }}</span>
            </p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Sub-Zona</label>
            <p class="detail-value">
              <span class="badge badge-secondary">{{ viewData.sub_zona }}</span>
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
      title="Ayuda - Catálogo de Zonas"
    >
      <h3>Catálogo de Zonas de Recolección</h3>
      <p>
        Este módulo permite administrar las zonas y sub-zonas de recolección de
        basura para el servicio de aseo contratado.
      </p>

      <h4>Funcionalidades Principales:</h4>
      <ul>
        <li><strong>Crear:</strong> Agregar nuevas zonas al catálogo</li>
        <li><strong>Editar:</strong> Modificar información de zonas existentes</li>
        <li><strong>Eliminar:</strong> Dar de baja zonas no utilizadas</li>
        <li><strong>Buscar:</strong> Filtrar zonas por descripción o número</li>
        <li><strong>Exportar:</strong> Generar archivo Excel con el catálogo</li>
      </ul>

      <h4>Campos:</h4>
      <ul>
        <li><strong>Control:</strong> Número de control asignado automáticamente</li>
        <li><strong>Zona:</strong> Número de zona principal (obligatorio)</li>
        <li><strong>Sub-Zona:</strong> Número de sub-zona (obligatorio)</li>
        <li><strong>Descripción:</strong> Nombre descriptivo de la zona (obligatorio)</li>
      </ul>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>El número de control se asigna automáticamente al crear una zona</li>
        <li>La descripción debe ser única en el catálogo</li>
        <li>Las zonas pueden estar asociadas a colonias y contratos</li>
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
const zonas = ref([])
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
  ctrol_zona: null,
  zona: null,
  sub_zona: null,
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
const loadZonas = async () => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_ZONAS_LIST',
      'aseo_contratado',
      {
        p_page: currentPage.value,
        p_limit: itemsPerPage.value,
        p_search: searchQuery.value || null
      }
    )

    if (response && response.data) {
      zonas.value = response.data
      if (response.data.length > 0) {
        totalRecords.value = response.data[0].total_records || 0
      } else {
        totalRecords.value = 0
      }
    }
  } catch (error) {
    console.error('Error al cargar zonas:', error)
    showToast('Error al cargar las zonas', 'error')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadZonas()
}

const clearSearch = () => {
  searchQuery.value = ''
  handleSearch()
}

const handleItemsPerPageChange = () => {
  currentPage.value = 1
  loadZonas()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadZonas()
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

// Create
const openCreateModal = () => {
  formData.value = {
    ctrol_zona: null,
    zona: null,
    sub_zona: null,
    descripcion: ''
  }
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
}

const createZona = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_ZONAS_CREATE',
      'aseo_contratado',
      {
        p_zona: formData.value.zona,
        p_sub_zona: formData.value.sub_zona,
        p_descripcion: formData.value.descripcion.trim()
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Zona creada exitosamente', 'success')
        closeCreateModal()
        loadZonas()
      } else {
        showToast(result.message || 'Error al crear la zona', 'error')
      }
    }
  } catch (error) {
    console.error('Error al crear zona:', error)
    showToast('Error al crear la zona', 'error')
  } finally {
    loading.value = false
  }
}

// Edit
const openEditModal = (zona) => {
  formData.value = {
    ctrol_zona: zona.ctrol_zona,
    zona: zona.zona,
    sub_zona: zona.sub_zona,
    descripcion: zona.descripcion || ''
  }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const updateZona = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_ZONAS_UPDATE',
      'aseo_contratado',
      {
        p_ctrol_zona: formData.value.ctrol_zona,
        p_zona: formData.value.zona,
        p_sub_zona: formData.value.sub_zona,
        p_descripcion: formData.value.descripcion.trim()
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Zona actualizada exitosamente', 'success')
        closeEditModal()
        loadZonas()
      } else {
        showToast(result.message || 'Error al actualizar la zona', 'error')
      }
    }
  } catch (error) {
    console.error('Error al actualizar zona:', error)
    showToast('Error al actualizar la zona', 'error')
  } finally {
    loading.value = false
  }
}

// View
const openViewModal = (zona) => {
  viewData.value = { ...zona }
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
const confirmDelete = async (zona) => {
  const result = await Swal.fire({
    title: '¿Eliminar zona?',
    html: `
      <p>¿Está seguro de eliminar la zona:</p>
      <p><strong>${zona.descripcion}</strong>?</p>
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
    await deleteZona(zona.ctrol_zona)
  }
}

const deleteZona = async (ctrol_zona) => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_ZONAS_DELETE',
      'aseo_contratado',
      {
        p_ctrol_zona: ctrol_zona
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Zona eliminada exitosamente', 'success')
        loadZonas()
      } else {
        showToast(result.message || 'Error al eliminar la zona', 'error')
      }
    }
  } catch (error) {
    console.error('Error al eliminar zona:', error)
    showToast('Error al eliminar la zona', 'error')
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
  loadZonas()
})
</script>
