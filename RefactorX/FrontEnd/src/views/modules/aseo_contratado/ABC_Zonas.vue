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
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
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
                v-model="filters.search"
                placeholder="Descripción, zona o sub-zona..."
                @keyup.enter="applyFilter"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="applyFilter"
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
              @click="loadZonas"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarCSV"
              :disabled="loading || filteredData.length === 0"
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
                <tr v-if="paginatedData.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron zonas</p>
                  </td>
                </tr>
                <tr v-else v-for="zona in paginatedData" :key="zona.ctrol_zona" class="row-hover">
                  <td><code>{{ String(zona.ctrol_zona).padStart(3, '0') }}</code></td>
                  <td class="text-center"><span class="badge badge-info">{{ zona.zona }}</span></td>
                  <td class="text-center"><span class="badge badge-secondary">{{ zona.sub_zona }}</span></td>
                  <td>{{ zona.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewZona(zona)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editZona(zona)"
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
    </div>

    <!-- Modal Crear -->
    <Modal
      :show="showCreateModal"
      @close="closeCreateModal"
      title="Nueva Zona de Recolección"
      size="lg"
      :showDefaultFooter="false"
    >
      <form @submit.prevent="createZona" class="modal-form">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Zona <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.zona"
              class="municipal-form-control"
              placeholder="Número de zona"
              required
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Sub-Zona <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.sub_zona"
              class="municipal-form-control"
              placeholder="Número de sub-zona"
              required
            />
          </div>
        </div>

        <div class="form-group">
          <label class="municipal-form-label">Descripción <span class="required">*</span></label>
          <input
            type="text"
            v-model="formData.descripcion"
            class="municipal-form-control"
            maxlength="100"
            placeholder="Descripción de la zona"
            required
          />
        </div>

        <div class="modal-actions">
          <button type="button" @click="closeCreateModal" class="btn-municipal-secondary" :disabled="guardando">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="submit" class="btn-municipal-primary" :disabled="guardando">
            <font-awesome-icon icon="save" />
            Crear Zona
          </button>
        </div>
      </form>
    </Modal>

    <!-- Modal Editar -->
    <Modal
      :show="showEditModal"
      @close="closeEditModal"
      title="Editar Zona de Recolección"
      size="lg"
      :showDefaultFooter="false"
    >
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
            <label class="municipal-form-label">Zona <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.zona"
              class="municipal-form-control"
              required
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Sub-Zona <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.sub_zona"
              class="municipal-form-control"
              required
            />
          </div>
        </div>

        <div class="form-group">
          <label class="municipal-form-label">Descripción <span class="required">*</span></label>
          <input
            type="text"
            v-model="formData.descripcion"
            class="municipal-form-control"
            maxlength="100"
            required
          />
        </div>

        <div class="modal-actions">
          <button type="button" @click="closeEditModal" class="btn-municipal-secondary" :disabled="guardando">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="submit" class="btn-municipal-primary" :disabled="guardando">
            <font-awesome-icon icon="save" />
            Guardar Cambios
          </button>
        </div>
      </form>
    </Modal>

    <!-- Modal Ver -->
    <Modal
      :show="showViewModal"
      @close="showViewModal = false"
      title="Detalle de la Zona"
      size="lg"
      :showDefaultFooter="false"
    >
      <div class="detail-grid" v-if="selectedZona">
        <div class="detail-item">
          <label class="detail-label">Control</label>
          <p class="detail-value"><code>{{ String(selectedZona.ctrol_zona).padStart(3, '0') }}</code></p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Zona</label>
          <p class="detail-value"><span class="badge badge-info">{{ selectedZona.zona }}</span></p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Sub-Zona</label>
          <p class="detail-value"><span class="badge badge-secondary">{{ selectedZona.sub_zona }}</span></p>
        </div>
        <div class="detail-item full-width">
          <label class="detail-label">Descripción</label>
          <p class="detail-value">{{ selectedZona.descripcion }}</p>
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" @click="showViewModal = false" class="btn-municipal-secondary">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
        <button type="button" @click="editZona(selectedZona); showViewModal = false" class="btn-municipal-primary">
          <font-awesome-icon icon="edit" />
          Editar
        </button>
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
    :componentName="'ABC_Zonas'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Constantes
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
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
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const zonas = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedZona = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const guardando = ref(false)

// Filtros
const filters = ref({
  search: ''
})

// Formulario
const formData = ref({
  ctrol_zona: null,
  zona: null,
  sub_zona: null,
  descripcion: ''
})

// Computed - Filtrado cliente
const filteredData = computed(() => {
  let data = [...zonas.value]

  if (filters.value.search) {
    const searchLower = filters.value.search.toLowerCase()
    data = data.filter(item =>
      item.descripcion?.toLowerCase().includes(searchLower) ||
      String(item.zona).includes(searchLower) ||
      String(item.sub_zona).includes(searchLower)
    )
  }

  return data
})

const totalRecords = computed(() => filteredData.value.length)

const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredData.value.slice(start, end)
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
async function loadZonas() {
  showLoading('Cargando zonas...', 'Consultando catálogo')

  try {
    const response = await execute('sp_zonas_list', BASE_DB, [], '', null, SCHEMA)

    if (response?.result) {
      zonas.value = response.result
      currentPage.value = 1
    } else {
      zonas.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    zonas.value = []
  } finally {
    hideLoading()
  }
}

function applyFilter() {
  currentPage.value = 1
}

function clearFilters() {
  filters.value = { search: '' }
  currentPage.value = 1
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function changePageSize() {
  currentPage.value = 1
}

function openCreateModal() {
  formData.value = {
    ctrol_zona: null,
    zona: null,
    sub_zona: null,
    descripcion: ''
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

function closeEditModal() {
  showEditModal.value = false
}

async function createZona() {
  // Validación
  if (!formData.value.zona) {
    showToast('Ingrese el número de zona', 'warning')
    return
  }
  if (!formData.value.sub_zona) {
    showToast('Ingrese el número de sub-zona', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Zona',
    html: `<p>¿Desea crear la zona <strong>${formData.value.zona}-${formData.value.sub_zona}</strong>?</p>
           <p>Descripción: ${formData.value.descripcion}</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Creando zona...', 'Guardando datos')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_zona', valor: formData.value.zona, tipo: 'integer' },
      { nombre: 'p_sub_zona', valor: formData.value.sub_zona, tipo: 'integer' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]

    const response = await execute('sp_zonas_create', BASE_DB, params, '', null, SCHEMA)

    if (response?.result && response.result.length > 0) {
      showToast('Zona creada correctamente', 'success')
      closeCreateModal()
      await loadZonas()
    } else {
      showToast('Error al crear la zona', 'warning')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editZona(zona) {
  selectedZona.value = zona
  formData.value = {
    ctrol_zona: zona.ctrol_zona,
    zona: zona.zona,
    sub_zona: zona.sub_zona,
    descripcion: zona.descripcion || ''
  }
  showEditModal.value = true
}

async function updateZona() {
  // Validación
  if (!formData.value.zona) {
    showToast('Ingrese el número de zona', 'warning')
    return
  }
  if (!formData.value.sub_zona) {
    showToast('Ingrese el número de sub-zona', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Zona',
    html: `<p>¿Desea actualizar la zona <strong>${formData.value.zona}-${formData.value.sub_zona}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando zona...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ctrol_zona', valor: formData.value.ctrol_zona, tipo: 'integer' },
      { nombre: 'p_zona', valor: formData.value.zona, tipo: 'integer' },
      { nombre: 'p_sub_zona', valor: formData.value.sub_zona, tipo: 'integer' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]

    const response = await execute('sp_zonas_update', BASE_DB, params, '', null, SCHEMA)

    if (response?.result) {
      showToast('Zona actualizada correctamente', 'success')
      closeEditModal()
      await loadZonas()
    } else {
      showToast('Error al actualizar la zona', 'warning')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function viewZona(zona) {
  selectedZona.value = zona
  showViewModal.value = true
}

async function confirmDelete(zona) {
  const result = await Swal.fire({
    title: '¿Eliminar zona?',
    html: `<p>¿Está seguro de eliminar la zona:</p>
           <p><strong>${zona.zona}-${zona.sub_zona}</strong> - ${zona.descripcion}?</p>
           <p class="text-danger">Esta acción no se puede deshacer</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteZona(zona)
  }
}

async function deleteZona(zona) {
  showLoading('Eliminando zona...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_ctrol_zona', valor: zona.ctrol_zona, tipo: 'integer' }
    ]

    const response = await execute('sp_zonas_delete', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.status === 'error') {
      showToast(response.result[0].message || 'Error al eliminar', 'warning')
    } else {
      showToast('Zona eliminada correctamente', 'success')
      await loadZonas()
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

function exportarCSV() {
  if (filteredData.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['Control', 'Zona', 'Sub-Zona', 'Descripción']
  const rows = filteredData.value.map(item => [
    item.ctrol_zona,
    item.zona,
    item.sub_zona,
    item.descripcion
  ])

  const csvContent = '\ufeff' + [headers.join(','), ...rows.map(r => r.map(c => `"${c || ''}"`).join(','))].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `zonas_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  showToast(`Exportados ${filteredData.value.length} registros`, 'success')
}

// Lifecycle
onMounted(() => {
  loadZonas()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
