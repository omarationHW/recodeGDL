<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="truck" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Unidades de Recolección</h1>
        <p>Aseo Contratado - Administración de unidades de recolección</p>
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
          Nueva Unidad
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
                placeholder="Descripción, clave o ejercicio..."
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
              @click="loadUnidades"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportToExcel"
              :disabled="loading || unidades.length === 0"
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
            Unidades Registradas
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Ejercicio</th>
                  <th>Clave</th>
                  <th>Descripción</th>
                  <th>Costo Unidad</th>
                  <th>Costo Excedente</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="unidades.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron unidades</p>
                  </td>
                </tr>
                <tr v-else v-for="unidad in unidades" :key="unidad.ctrol_recolec" class="row-hover">
                  <td>
                    <span class="badge-control">{{ String(unidad.ctrol_recolec).padStart(3, '0') }}</span>
                  </td>
                  <td class="text-center">{{ unidad.ejercicio_recolec }}</td>
                  <td>
                    <span class="badge badge-primary">{{ unidad.cve_recolec }}</span>
                  </td>
                  <td>{{ unidad.descripcion }}</td>
                  <td class="text-end">${{ formatCurrency(unidad.costo_unidad) }}</td>
                  <td class="text-end">${{ formatCurrency(unidad.costo_exed) }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="openViewModal(unidad)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="openEditModal(unidad)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDelete(unidad)"
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
            <p>Cargando unidades...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <Modal
      :show="showCreateModal"
      @close="closeCreateModal"
      title="Nueva Unidad de Recolección"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="createUnidad" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label for="ejercicio_recolec" class="municipal-form-label required">Ejercicio</label>
              <input
                type="number"
                id="ejercicio_recolec"
                v-model="formData.ejercicio_recolec"
                class="municipal-form-control"
                placeholder="Año"
                required
              />
            </div>

            <div class="form-group">
              <label for="cve_recolec" class="municipal-form-label required">Clave</label>
              <input
                type="text"
                id="cve_recolec"
                v-model="formData.cve_recolec"
                class="municipal-form-control"
                maxlength="10"
                placeholder="Clave de unidad"
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
              placeholder="Descripción de la unidad"
              required
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="costo_unidad" class="municipal-form-label">Costo Unidad</label>
              <input
                type="number"
                id="costo_unidad"
                v-model="formData.costo_unidad"
                class="municipal-form-control"
                step="0.01"
                placeholder="0.00"
              />
            </div>

            <div class="form-group">
              <label for="costo_exed" class="municipal-form-label">Costo Excedente</label>
              <input
                type="number"
                id="costo_exed"
                v-model="formData.costo_exed"
                class="municipal-form-control"
                step="0.01"
                placeholder="0.00"
              />
            </div>
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeCreateModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="createUnidad" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Crear Unidad
        </button>
      </template>
    </Modal>

    <!-- Modal Editar -->
    <Modal
      :show="showEditModal"
      @close="closeEditModal"
      title="Editar Unidad de Recolección"
      size="medium"
    >
      <template #body>
        <form @submit.prevent="updateUnidad" class="modal-form">
          <div class="form-group">
            <label class="municipal-form-label">Control</label>
            <input
              type="text"
              :value="String(formData.ctrol_recolec).padStart(3, '0')"
              class="municipal-form-control"
              disabled
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="edit_ejercicio_recolec" class="municipal-form-label required">Ejercicio</label>
              <input
                type="number"
                id="edit_ejercicio_recolec"
                v-model="formData.ejercicio_recolec"
                class="municipal-form-control"
                required
              />
            </div>

            <div class="form-group">
              <label for="edit_cve_recolec" class="municipal-form-label required">Clave</label>
              <input
                type="text"
                id="edit_cve_recolec"
                v-model="formData.cve_recolec"
                class="municipal-form-control"
                maxlength="10"
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

          <div class="form-row">
            <div class="form-group">
              <label for="edit_costo_unidad" class="municipal-form-label">Costo Unidad</label>
              <input
                type="number"
                id="edit_costo_unidad"
                v-model="formData.costo_unidad"
                class="municipal-form-control"
                step="0.01"
              />
            </div>

            <div class="form-group">
              <label for="edit_costo_exed" class="municipal-form-label">Costo Excedente</label>
              <input
                type="number"
                id="edit_costo_exed"
                v-model="formData.costo_exed"
                class="municipal-form-control"
                step="0.01"
              />
            </div>
          </div>
        </form>
      </template>
      <template #footer>
        <button type="button" @click="closeEditModal" class="btn-secondary">
          Cancelar
        </button>
        <button type="button" @click="updateUnidad" class="btn-primary" :disabled="loading">
          <font-awesome-icon v-if="loading" icon="spinner" spin />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <!-- Modal Ver -->
    <Modal
      :show="showViewModal"
      @close="closeViewModal"
      title="Detalle de la Unidad"
      size="medium"
    >
      <template #body>
        <div class="detail-grid">
          <div class="detail-item">
            <label class="detail-label">Control</label>
            <p class="detail-value">
              <span class="badge-control">{{ String(viewData.ctrol_recolec).padStart(3, '0') }}</span>
            </p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Ejercicio</label>
            <p class="detail-value">{{ viewData.ejercicio_recolec }}</p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Clave</label>
            <p class="detail-value">
              <span class="badge badge-primary">{{ viewData.cve_recolec }}</span>
            </p>
          </div>

          <div class="detail-item full-width">
            <label class="detail-label">Descripción</label>
            <p class="detail-value">{{ viewData.descripcion }}</p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Costo Unidad</label>
            <p class="detail-value">${{ formatCurrency(viewData.costo_unidad) }}</p>
          </div>

          <div class="detail-item">
            <label class="detail-label">Costo Excedente</label>
            <p class="detail-value">${{ formatCurrency(viewData.costo_exed) }}</p>
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
      title="Ayuda - Catálogo de Unidades de Recolección"
    >
      <h3>Catálogo de Unidades de Recolección</h3>
      <p>
        Este módulo permite administrar las unidades de recolección de basura,
        incluyendo sus costos y características.
      </p>

      <h4>Funcionalidades Principales:</h4>
      <ul>
        <li><strong>Crear:</strong> Agregar nuevas unidades al catálogo</li>
        <li><strong>Editar:</strong> Modificar información de unidades existentes</li>
        <li><strong>Eliminar:</strong> Dar de baja unidades no utilizadas</li>
        <li><strong>Buscar:</strong> Filtrar unidades por descripción, clave o ejercicio</li>
        <li><strong>Exportar:</strong> Generar archivo Excel con el catálogo</li>
      </ul>

      <h4>Campos:</h4>
      <ul>
        <li><strong>Control:</strong> Número de control asignado automáticamente</li>
        <li><strong>Ejercicio:</strong> Año fiscal de la unidad (obligatorio)</li>
        <li><strong>Clave:</strong> Código identificador de la unidad (obligatorio)</li>
        <li><strong>Descripción:</strong> Nombre descriptivo de la unidad (obligatorio)</li>
        <li><strong>Costo Unidad:</strong> Precio por unidad de servicio</li>
        <li><strong>Costo Excedente:</strong> Precio por unidad excedente</li>
      </ul>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>El número de control se asigna automáticamente</li>
        <li>La combinación de ejercicio y clave debe ser única</li>
        <li>Los costos son opcionales pero recomendados</li>
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

const unidades = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const searchQuery = ref('')
const loading = ref(false)
const showDocumentation = ref(false)

const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)

const formData = ref({
  ctrol_recolec: null,
  ejercicio_recolec: null,
  cve_recolec: '',
  descripcion: '',
  costo_unidad: null,
  costo_exed: null
})

const viewData = ref({})

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

const formatCurrency = (value) => {
  if (!value && value !== 0) return '0.00'
  return Number(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

const loadUnidades = async () => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_UNIDADES_LIST',
      'aseo_contratado',
      {
        p_page: currentPage.value,
        p_limit: itemsPerPage.value,
        p_search: searchQuery.value || null
      }
    )

    if (response && response.data) {
      unidades.value = response.data
      if (response.data.length > 0) {
        totalRecords.value = response.data[0].total_records || 0
      } else {
        totalRecords.value = 0
      }
    }
  } catch (error) {
    console.error('Error al cargar unidades:', error)
    showToast('Error al cargar las unidades', 'error')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadUnidades()
}

const clearSearch = () => {
  searchQuery.value = ''
  handleSearch()
}

const handleItemsPerPageChange = () => {
  currentPage.value = 1
  loadUnidades()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadUnidades()
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const openCreateModal = () => {
  formData.value = {
    ctrol_recolec: null,
    ejercicio_recolec: new Date().getFullYear(),
    cve_recolec: '',
    descripcion: '',
    costo_unidad: null,
    costo_exed: null
  }
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
}

const createUnidad = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_UNIDADES_CREATE',
      'aseo_contratado',
      {
        p_ejercicio_recolec: formData.value.ejercicio_recolec,
        p_cve_recolec: formData.value.cve_recolec?.trim(),
        p_descripcion: formData.value.descripcion.trim(),
        p_costo_unidad: formData.value.costo_unidad || 0,
        p_costo_exed: formData.value.costo_exed || 0
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Unidad creada exitosamente', 'success')
        closeCreateModal()
        loadUnidades()
      } else {
        showToast(result.message || 'Error al crear la unidad', 'error')
      }
    }
  } catch (error) {
    console.error('Error al crear unidad:', error)
    showToast('Error al crear la unidad', 'error')
  } finally {
    loading.value = false
  }
}

const openEditModal = (unidad) => {
  formData.value = {
    ctrol_recolec: unidad.ctrol_recolec,
    ejercicio_recolec: unidad.ejercicio_recolec,
    cve_recolec: unidad.cve_recolec || '',
    descripcion: unidad.descripcion || '',
    costo_unidad: unidad.costo_unidad,
    costo_exed: unidad.costo_exed
  }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const updateUnidad = async () => {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripción es requerida', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_UNIDADES_UPDATE',
      'aseo_contratado',
      {
        p_ctrol_recolec: formData.value.ctrol_recolec,
        p_ejercicio_recolec: formData.value.ejercicio_recolec,
        p_cve_recolec: formData.value.cve_recolec?.trim(),
        p_descripcion: formData.value.descripcion.trim(),
        p_costo_unidad: formData.value.costo_unidad || 0,
        p_costo_exed: formData.value.costo_exed || 0
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Unidad actualizada exitosamente', 'success')
        closeEditModal()
        loadUnidades()
      } else {
        showToast(result.message || 'Error al actualizar la unidad', 'error')
      }
    }
  } catch (error) {
    console.error('Error al actualizar unidad:', error)
    showToast('Error al actualizar la unidad', 'error')
  } finally {
    loading.value = false
  }
}

const openViewModal = (unidad) => {
  viewData.value = { ...unidad }
  showViewModal.value = true
}

const closeViewModal = () => {
  showViewModal.value = false
}

const editFromView = () => {
  closeViewModal()
  openEditModal(viewData.value)
}

const confirmDelete = async (unidad) => {
  const result = await Swal.fire({
    title: '¿Eliminar unidad?',
    html: `
      <p>¿Está seguro de eliminar la unidad:</p>
      <p><strong>${unidad.descripcion}</strong>?</p>
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
    await deleteUnidad(unidad.ctrol_recolec)
  }
}

const deleteUnidad = async (ctrol_recolec) => {
  loading.value = true
  try {
    const response = await execute(
      'SP_ASEO_UNIDADES_DELETE',
      'aseo_contratado',
      {
        p_ctrol_recolec: ctrol_recolec
      }
    )

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast(result.message || 'Unidad eliminada exitosamente', 'success')
        loadUnidades()
      } else {
        showToast(result.message || 'Error al eliminar la unidad', 'error')
      }
    }
  } catch (error) {
    console.error('Error al eliminar unidad:', error)
    showToast('Error al eliminar la unidad', 'error')
  } finally {
    loading.value = false
  }
}

const exportToExcel = () => {
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

onMounted(() => {
  loadUnidades()
})
</script>
