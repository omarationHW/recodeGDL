<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-check" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Tipos de Aseo</h1>
        <p>Aseo Contratado - Administración de tipos de servicio</p>
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
                v-model="searchQuery"
                placeholder="Descripción, control o tipo..."
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
              @click="loadTipos"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportToExcel"
              :disabled="loading || tipos.length === 0"
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
            Tipos de Aseo Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Tipo</th>
                  <th>Descripción</th>
                  <th>Cta. Aplicación</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="tipos.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron tipos de aseo</p>
                  </td>
                </tr>
                <tr v-else v-for="tipo in tipos" :key="tipo.ctrol_aseo" class="row-hover">
                  <td>
                    <span class="badge-control">{{ String(tipo.ctrol_aseo).padStart(3, '0') }}</span>
                  </td>
                  <td>
                    <span class="badge-secondary">{{ tipo.tipo_aseo }}</span>
                  </td>
                  <td>{{ tipo.descripcion }}</td>
                  <td class="text-center">
                    <span v-if="tipo.cta_aplicacion">{{ tipo.cta_aplicacion }}</span>
                    <span v-else class="text-muted">-</span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="openViewModal(tipo)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="openEditModal(tipo)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDelete(tipo)"
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
            <p>Cargando tipos de aseo...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <Modal
      :show="showCreateModal"
      @close="closeCreateModal"
      title="Nuevo Tipo de Aseo"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="createTipo" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label for="tipo_aseo" class="municipal-form-label required">Tipo</label>
              <input
                type="text"
                id="tipo_aseo"
                v-model="formData.tipo_aseo"
                class="municipal-form-control"
                maxlength="1"
                placeholder="Ej: A, B, C..."
                required
              />
              <small class="form-text">Un solo carácter</small>
            </div>

            <div class="form-group">
              <label for="cta_aplicacion" class="municipal-form-label">Cuenta Aplicación</label>
              <input
                type="number"
                id="cta_aplicacion"
                v-model="formData.cta_aplicacion"
                class="municipal-form-control"
                placeholder="Número de cuenta"
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
              maxlength="80"
              placeholder="Descripción del tipo de aseo"
              required
            />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeCreateModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="createTipo" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Crear Tipo
        </button>
      </template>
    </Modal>

    <!-- Modal Editar -->
    <Modal
      :show="showEditModal"
      @close="closeEditModal"
      title="Editar Tipo de Aseo"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="updateTipo" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Control</label>
            <input
              type="text"
              :value="String(formData.ctrol_aseo).padStart(3, '0')"
              class="municipal-form-control"
              disabled
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="edit_tipo_aseo" class="municipal-form-label required">Tipo</label>
              <input
                type="text"
                id="edit_tipo_aseo"
                v-model="formData.tipo_aseo"
                class="municipal-form-control"
                maxlength="1"
                required
              />
            </div>

            <div class="form-group">
              <label for="edit_cta_aplicacion" class="municipal-form-label">Cuenta Aplicación</label>
              <input
                type="number"
                id="edit_cta_aplicacion"
                v-model="formData.cta_aplicacion"
                class="municipal-form-control"
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
              maxlength="80"
              required
            />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeEditModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="updateTipo" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <!-- Modal Ver -->
    <Modal
      :show="showViewModal"
      @close="closeViewModal"
      title="Detalle del Tipo de Aseo"
      size="medium"
    >
      <template #body>
        <div class="detail-grid">
          <div class="detail-item">
            <label class="detail-label">Control</label>
            <p class="detail-value">
              <span class="badge-control">{{ String(viewData.ctrol_aseo).padStart(3, '0') }}</span>
            </p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Tipo</label>
            <p class="detail-value">
              <span class="badge-secondary">{{ viewData.tipo_aseo }}</span>
            </p>
          </div>

          <div class="detail-item full-width">
            <label class="detail-label">Descripción</label>
            <p class="detail-value">{{ viewData.descripcion }}</p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Cuenta Aplicación</label>
            <p class="detail-value">
              {{ viewData.cta_aplicacion || 'No especificada' }}
            </p>
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
      title="Ayuda - Catálogo de Tipos de Aseo"
    >
      <h3>Catálogo de Tipos de Aseo</h3>
      <p>
        Este módulo permite administrar los diferentes tipos de servicio de aseo contratado
        que ofrece el municipio.
      </p>

      <h4>Funcionalidades Principales:</h4>
      <ul>
        <li><strong>Crear:</strong> Agregar nuevos tipos de aseo al catálogo</li>
        <li><strong>Editar:</strong> Modificar información de tipos existentes</li>
        <li><strong>Eliminar:</strong> Dar de baja tipos que no estén en uso</li>
        <li><strong>Buscar:</strong> Filtrar tipos por descripción, control o tipo</li>
        <li><strong>Exportar:</strong> Generar archivo Excel con el catálogo</li>
      </ul>

      <h4>Campos:</h4>
      <ul>
        <li><strong>Control:</strong> Número de control asignado automáticamente</li>
        <li><strong>Tipo:</strong> Código de un carácter que identifica el tipo (A, B, C, etc.)</li>
        <li><strong>Descripción:</strong> Nombre descriptivo del tipo de aseo (obligatorio)</li>
        <li><strong>Cuenta Aplicación:</strong> Número de cuenta contable asociada</li>
      </ul>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>El número de control se asigna automáticamente al crear un tipo</li>
        <li>No se puede eliminar un tipo que esté en uso en contratos activos</li>
        <li>La descripción debe ser única en el catálogo</li>
        <li>El campo Tipo es de un solo carácter</li>
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
const tipos = ref([])
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
  ctrol_aseo: null,
  tipo_aseo: '',
  descripcion: '',
  cta_aplicacion: null
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
const loadTipos = async () => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_TIPOS_LIST',
      'aseo_contratado',
      {
        p_page: currentPage.value,
        p_limit: itemsPerPage.value,
        p_search: searchQuery.value || null
      }
    )

    if (response && response.data) {
      tipos.value = response.data
      if (response.data.length > 0) {
        totalRecords.value = response.data[0].total_records || 0
      } else {
        totalRecords.value = 0
      }
    }
  } catch (error) {
    console.error('Error al cargar tipos:', error)
    showToast('Error al cargar los tipos de aseo', 'error')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadTipos()
}

const clearSearch = () => {
  searchQuery.value = ''
  handleSearch()
}

const handleItemsPerPageChange = () => {
  currentPage.value = 1
  loadTipos()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadTipos()
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

// Create
const openCreateModal = () => {
  formData.value = {
    ctrol_aseo: null,
    tipo_aseo: '',
    descripcion: '',
    cta_aplicacion: null
  }
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
}

const createTipo = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_TIPOS_CREATE',
      'aseo_contratado',
      {
        p_tipo_aseo: formData.value.tipo_aseo?.trim() || null,
        p_descripcion: formData.value.descripcion.trim(),
        p_cta_aplicacion: formData.value.cta_aplicacion || null
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Tipo creado exitosamente', 'success')
        closeCreateModal()
        loadTipos()
      } else {
        showToast(result.message || 'Error al crear el tipo', 'error')
      }
    }
  } catch (error) {
    console.error('Error al crear tipo:', error)
    showToast('Error al crear el tipo de aseo', 'error')
  } finally {
    loading.value = false
  }
}

// Edit
const openEditModal = (tipo) => {
  formData.value = {
    ctrol_aseo: tipo.ctrol_aseo,
    tipo_aseo: tipo.tipo_aseo || '',
    descripcion: tipo.descripcion || '',
    cta_aplicacion: tipo.cta_aplicacion || null
  }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const updateTipo = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_TIPOS_UPDATE',
      'aseo_contratado',
      {
        p_ctrol_aseo: formData.value.ctrol_aseo,
        p_tipo_aseo: formData.value.tipo_aseo?.trim() || null,
        p_descripcion: formData.value.descripcion.trim(),
        p_cta_aplicacion: formData.value.cta_aplicacion || null
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Tipo actualizado exitosamente', 'success')
        closeEditModal()
        loadTipos()
      } else {
        showToast(result.message || 'Error al actualizar el tipo', 'error')
      }
    }
  } catch (error) {
    console.error('Error al actualizar tipo:', error)
    showToast('Error al actualizar el tipo de aseo', 'error')
  } finally {
    loading.value = false
  }
}

// View
const openViewModal = (tipo) => {
  viewData.value = { ...tipo }
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
const confirmDelete = async (tipo) => {
  const result = await Swal.fire({
    title: '¿Eliminar tipo de aseo?',
    html: `
      <p>¿Está seguro de eliminar el tipo:</p>
      <p><strong>${tipo.descripcion}</strong>?</p>
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
    await deleteTipo(tipo.ctrol_aseo)
  }
}

const deleteTipo = async (ctrol_aseo) => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_TIPOS_DELETE',
      'aseo_contratado',
      {
        p_ctrol_aseo: ctrol_aseo
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Tipo eliminado exitosamente', 'success')
        loadTipos()
      } else {
        showToast(result.message || 'Error al eliminar el tipo', 'error')
      }
    }
  } catch (error) {
    console.error('Error al eliminar tipo:', error)
    showToast('Error al eliminar el tipo de aseo', 'error')
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
  loadTipos()
})
</script>
