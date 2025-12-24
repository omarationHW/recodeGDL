<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="receipt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Gastos</h1>
        <p>Aseo Contratado - Gestión de Gastos</p>
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
          Nuevo Gasto
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
                placeholder="ID, descripción o monto..."
                @keyup.enter="searchGastos"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchGastos"
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
              @click="loadGastos"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarExcel"
              :disabled="loading || gastos.length === 0"
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
            Gastos Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Descripción</th>
                  <th>Monto</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="gastos.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="receipt" size="2x" class="empty-icon" />
                    <p>No se encontraron gastos registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="gasto in gastos" :key="gasto.id_gasto" class="row-hover">
                  <td><strong class="text-primary">{{ gasto.id_gasto }}</strong></td>
                  <td>{{ gasto.descripcion }}</td>
                  <td><code class="text-success">${{ formatMonto(gasto.monto) }}</code></td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewGasto(gasto)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editGasto(gasto)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDeleteGasto(gasto)"
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
      <div v-if="loading && gastos.length === 0" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando gastos...</p>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Gasto"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createGasto"
      :loading="creatingGasto"
      confirmText="Crear Gasto"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createGasto">
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newGasto.descripcion"
            maxlength="100"
            required
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Monto: <span class="required">*</span></label>
          <input
            type="number"
            class="municipal-form-control"
            v-model="newGasto.monto"
            step="0.01"
            min="0.01"
            required
          />
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Gasto: ${selectedGasto?.descripcion}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateGasto"
      :loading="updatingGasto"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateGasto">
        <div class="form-group full-width">
          <label class="municipal-form-label">ID Gasto:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="editForm.id_gasto"
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
          <label class="municipal-form-label">Monto: <span class="required">*</span></label>
          <input
            type="number"
            class="municipal-form-control"
            v-model="editForm.monto"
            step="0.01"
            min="0.01"
            required
          />
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Gasto: ${selectedGasto?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedGasto" class="empresa-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información del Gasto
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Gasto:</td>
                <td><code>{{ selectedGasto.id_gasto }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedGasto.descripcion }}</td>
              </tr>
              <tr>
                <td class="label">Monto:</td>
                <td>
                  <span class="badge-success">
                    <font-awesome-icon icon="dollar-sign" />
                    ${{ formatMonto(selectedGasto.monto) }}
                  </span>
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
          <button class="btn-municipal-primary" @click="editGasto(selectedGasto); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Gasto
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
    :componentName="'ABC_Gastos'"
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
const gastos = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedGasto = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingGasto = ref(false)
const updatingGasto = ref(false)

// Filtros
const filters = ref({
  search: ''
})

// Formularios
const newGasto = ref({
  descripcion: '',
  monto: null
})

const editForm = ref({
  id_gasto: null,
  descripcion: '',
  monto: null
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
const loadGastos = async () => {
  setLoading(true, 'Cargando gastos...')

  try {
    const response = await execute(
      'SP_ASEO_GASTOS_LIST',
      'aseo_contratado',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_search', valor: filters.value.search || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      gastos.value = response.result
      if (gastos.value.length > 0) {
        totalRecords.value = parseInt(gastos.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Gastos cargados correctamente')
    } else {
      gastos.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar gastos')
    }
  } catch (error) {
    handleApiError(error)
    gastos.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchGastos = () => {
  currentPage.value = 1
  loadGastos()
}

const clearFilters = () => {
  filters.value = {
    search: ''
  }
  currentPage.value = 1
  loadGastos()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadGastos()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadGastos()
}

const openCreateModal = () => {
  newGasto.value = {
    descripcion: '',
    monto: null
  }
  showCreateModal.value = true
}

const createGasto = async () => {
  if (!newGasto.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!newGasto.value.monto || newGasto.value.monto <= 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El monto debe ser mayor a cero',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de gasto?',
    html: `
      <p>Se creará un nuevo gasto con los siguientes datos:</p>
      <ul class="list-unstyled-left">
        <li><strong>Descripción:</strong> ${newGasto.value.descripcion}</li>
        <li><strong>Monto:</strong> $${formatMonto(newGasto.value.monto)}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear gasto',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  creatingGasto.value = true

  try {
    const response = await execute(
      'SP_ASEO_GASTOS_CREATE',
      'aseo_contratado',
      [
        { nombre: 'p_descripcion', valor: newGasto.value.descripcion },
        { nombre: 'p_monto', valor: newGasto.value.monto },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadGastos()

      await Swal.fire({
        icon: 'success',
        title: '¡Gasto creado!',
        text: 'El gasto ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Gasto creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear gasto',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingGasto.value = false
  }
}

const editGasto = (gasto) => {
  selectedGasto.value = gasto
  editForm.value = {
    id_gasto: gasto.id_gasto,
    descripcion: gasto.descripcion,
    monto: gasto.monto
  }
  showEditModal.value = true
}

const updateGasto = async () => {
  if (!editForm.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!editForm.value.monto || editForm.value.monto <= 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El monto debe ser mayor a cero',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <p>Se actualizarán los datos del gasto:</p>
      <ul class="list-unstyled-left">
        <li><strong>ID Gasto:</strong> ${editForm.value.id_gasto}</li>
        <li><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
        <li><strong>Monto:</strong> $${formatMonto(editForm.value.monto)}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  updatingGasto.value = true

  try {
    const response = await execute(
      'SP_ASEO_GASTOS_UPDATE',
      'aseo_contratado',
      [
        { nombre: 'p_id_gasto', valor: editForm.value.id_gasto },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion },
        { nombre: 'p_monto', valor: editForm.value.monto },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadGastos()

      await Swal.fire({
        icon: 'success',
        title: '¡Gasto actualizado!',
        text: 'Los datos han sido actualizados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Gasto actualizado exitosamente')
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
    updatingGasto.value = false
  }
}

const viewGasto = (gasto) => {
  selectedGasto.value = gasto
  showViewModal.value = true
}

const confirmDeleteGasto = async (gasto) => {
  const result = await Swal.fire({
    title: '¿Eliminar gasto?',
    html: `
      <p>¿Está seguro de eliminar el gasto:</p>
      <p><strong>${gasto.descripcion}</strong>?</p>
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
    await deleteGasto(gasto)
  }
}

const deleteGasto = async (gasto) => {
  try {
    const response = await execute(
      'SP_ASEO_GASTOS_DELETE',
      'aseo_contratado',
      [
        { nombre: 'p_id_gasto', valor: gasto.id_gasto },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadGastos()

      await Swal.fire({
        icon: 'success',
        title: '¡Gasto eliminado!',
        text: 'El gasto ha sido eliminado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Gasto eliminado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'Error al eliminar el gasto',
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

// Utilidades
const formatMonto = (monto) => {
  if (!monto) return '0.00'
  return parseFloat(monto).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

// Lifecycle
onMounted(() => {
  loadGastos()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
