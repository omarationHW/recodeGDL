<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Claves de Operación</h1>
        <p>Aseo Contratado - Administración de claves de operación</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="openCreateModal" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nueva Clave
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input type="text" class="municipal-form-control" v-model="searchQuery"
                placeholder="Descripción o clave..." @keyup.enter="handleSearch" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="handleSearch" :disabled="loading">
              <font-awesome-icon icon="search" /> Buscar
            </button>
            <button class="btn-municipal-secondary" @click="clearSearch" :disabled="loading">
              <font-awesome-icon icon="times" /> Limpiar
            </button>
            <button class="btn-municipal-secondary" @click="loadClaves" :disabled="loading">
              <font-awesome-icon icon="sync-alt" /> Actualizar
            </button>
            <button class="btn-municipal-primary" @click="exportToExcel" :disabled="loading || claves.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Claves Registradas
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Clave</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="claves.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron claves</p>
                  </td>
                </tr>
                <tr v-else v-for="clave in claves" :key="clave.cve_operacion" class="row-hover">
                  <td><span class="badge badge-primary">{{ clave.cve_operacion }}</span></td>
                  <td>{{ clave.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="openViewModal(clave)" title="Ver detalles">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button class="btn-municipal-primary btn-sm" @click="openEditModal(clave)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-secondary btn-sm" @click="confirmDelete(clave)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="pagination-container" v-if="totalPages > 1">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, totalRecords) }} de {{ totalRecords }} registros
            </div>
            <div class="pagination">
              <button @click="goToPage(1)" :disabled="currentPage === 1" class="pagination-btn" title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" class="pagination-btn" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>
              <template v-for="page in paginationRange" :key="page">
                <button v-if="page !== '...'" @click="goToPage(page)" :class="['pagination-btn', { active: currentPage === page }]">
                  {{ page }}
                </button>
                <span v-else class="pagination-ellipsis">...</span>
              </template>
              <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" class="pagination-btn" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button @click="goToPage(totalPages)" :disabled="currentPage === totalPages" class="pagination-btn" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>

        <div class="municipal-card-body" v-else>
          <div class="loading-state">
            <div class="spinner"></div>
            <p>Cargando claves...</p>
          </div>
        </div>
      </div>
    </div>

    <Modal :show="showCreateModal" @close="closeCreateModal" title="Nueva Clave de Operación" size="medium">
      <template #body>
        <form @submit.prevent="createClave" class="modal-form">
          <div class="form-group">
            <label for="descripcion" class="municipal-form-label required">Descripción</label>
            <input type="text" id="descripcion" v-model="formData.descripcion" class="municipal-form-control"
              maxlength="100" placeholder="Descripción de la clave" required />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeCreateModal" class="btn-secondary">Cancelar</button>
        <button type="button" @click="createClave" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Crear Clave
        </button>
      </template>
    </Modal>

    <Modal :show="showEditModal" @close="closeEditModal" title="Editar Clave de Operación" size="medium">
      <template #body>
        <form @submit.prevent="updateClave" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Clave</label>
            <input type="text" :value="formData.cve_operacion" class="municipal-form-control" disabled />
          </div>
          <div class="form-group">
            <label for="edit_descripcion" class="municipal-form-label required">Descripción</label>
            <input type="text" id="edit_descripcion" v-model="formData.descripcion" class="municipal-form-control"
              maxlength="100" required />
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeEditModal" class="btn-secondary">Cancelar</button>
        <button type="button" @click="updateClave" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <Modal :show="showViewModal" @close="closeViewModal" title="Detalle de la Clave" size="medium">
      <template #body>
        <div class="detail-grid">
          <div class="detail-item">
            <label class="detail-label">Clave</label>
            <p class="detail-value"><span class="badge badge-primary">{{ viewData.cve_operacion }}</span></p>
          </div>
          <div class="detail-item full-width">
            <label class="detail-label">Descripción</label>
            <p class="detail-value">{{ viewData.descripcion }}</p>
          </div>
        </div>
      </template>
      <template #footer>
        <button type="button" @click="closeViewModal" class="btn-secondary">Cerrar</button>
        <button type="button" @click="editFromView" class="btn-primary">
          <font-awesome-icon icon="edit" /> Editar
        </button>
      </template>
    </Modal>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Claves de Operación">
      <h3>Catálogo de Claves de Operación</h3>
      <p>Administración de claves de operación para el módulo de aseo contratado.</p>
      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Crear:</strong> Agregar nuevas claves</li>
        <li><strong>Editar:</strong> Modificar claves existentes</li>
        <li><strong>Eliminar:</strong> Dar de baja claves no utilizadas</li>
        <li><strong>Buscar:</strong> Filtrar por descripción o clave</li>
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

const claves = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const searchQuery = ref('')
const loading = ref(false)
const showDocumentation = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const formData = ref({ cve_operacion: null, descripcion: '' })
const viewData = ref({})

const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))
const paginationRange = computed(() => {
  const range = []
  const delta = 2
  for (let i = Math.max(2, currentPage.value - delta); i <= Math.min(totalPages.value - 1, currentPage.value + delta); i++) {
    range.push(i)
  }
  if (currentPage.value - delta > 2) range.unshift('...')
  if (currentPage.value + delta < totalPages.value - 1) range.push('...')
  range.unshift(1)
  if (totalPages.value > 1) range.push(totalPages.value)
  return range
})

const loadClaves = async () => {
  loading.value = true
  try {
    const response = await execute('SP_ASEO_CVES_OPERACION_LIST', 'aseo_contratado', {
      p_page: currentPage.value,
      p_limit: itemsPerPage.value,
      p_search: searchQuery.value || null
    })
    if (response && response.data) {
      claves.value = response.data
      totalRecords.value = response.data.length > 0 ? response.data[0].total_records || 0 : 0
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al cargar las claves', 'error')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadClaves()
}

const clearSearch = () => {
  searchQuery.value = ''
  handleSearch()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadClaves()
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const openCreateModal = () => {
  formData.value = { cve_operacion: null, descripcion: '' }
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
}

const createClave = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }
  loading.value = true
  try {
    const response = await execute('SP_ASEO_CVES_OPERACION_CREATE', 'aseo_contratado', {
      p_descripcion: formData.value.descripcion.trim()
    })
    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Clave creada exitosamente', 'success')
        closeCreateModal()
        loadClaves()
      } else {
        showToast(result.message || 'Error al crear la clave', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al crear la clave', 'error')
  } finally {
    loading.value = false
  }
}

const openEditModal = (clave) => {
  formData.value = { cve_operacion: clave.cve_operacion, descripcion: clave.descripcion || '' }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const updateClave = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }
  loading.value = true
  try {
    const response = await execute('SP_ASEO_CVES_OPERACION_UPDATE', 'aseo_contratado', {
      p_cve_operacion: formData.value.cve_operacion,
      p_descripcion: formData.value.descripcion.trim()
    })
    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Clave actualizada exitosamente', 'success')
        closeEditModal()
        loadClaves()
      } else {
        showToast(result.message || 'Error al actualizar la clave', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al actualizar la clave', 'error')
  } finally {
    loading.value = false
  }
}

const openViewModal = (clave) => {
  viewData.value = { ...clave }
  showViewModal.value = true
}

const closeViewModal = () => {
  showViewModal.value = false
}

const editFromView = () => {
  closeViewModal()
  openEditModal(viewData.value)
}

const confirmDelete = async (clave) => {
  const result = await Swal.fire({
    title: '¿Eliminar clave?',
    html: `<p>¿Está seguro de eliminar:<br/><strong>${clave.descripcion}</strong>?</p><p class="text-danger">Esta acción no se puede deshacer.</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  if (result.isConfirmed) await deleteClave(clave.cve_operacion)
}

const deleteClave = async (cve_operacion) => {
  loading.value = true
  try {
    const response = await execute('SP_ASEO_CVES_OPERACION_DELETE', 'aseo_contratado', {
      p_cve_operacion: cve_operacion
    })
    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Clave eliminada exitosamente', 'success')
        loadClaves()
      } else {
        showToast(result.message || 'Error al eliminar la clave', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al eliminar la clave', 'error')
  } finally {
    loading.value = false
  }
}

const exportToExcel = () => {
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

onMounted(() => {
  loadClaves()
})
</script>
