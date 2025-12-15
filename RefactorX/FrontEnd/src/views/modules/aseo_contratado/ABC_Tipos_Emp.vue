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
              @click="loadTiposEmp"
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
            Tipos de Empresa Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Tipo Empresa</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="paginatedData.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="building-user" size="2x" class="empty-icon" />
                    <p>No se encontraron tipos de empresa registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="tipo in paginatedData" :key="tipo.ctrol_emp" class="row-hover">
                  <td><code>{{ tipo.ctrol_emp }}</code></td>
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

    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Tipo de Empresa"
      size="lg"
      @close="closeCreateModal"
      :showDefaultFooter="false"
    >
      <form @submit.prevent="createTipoEmp">
        <div class="form-group full-width">
          <label class="municipal-form-label">Tipo Empresa: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.tipo_empresa"
            maxlength="10"
            placeholder="Código del tipo"
            required
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="100"
            placeholder="Descripción del tipo de empresa"
            required
          />
        </div>
        <div class="modal-actions">
          <button type="button" class="btn-municipal-secondary" @click="closeCreateModal" :disabled="guardando">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="submit" class="btn-municipal-primary" :disabled="guardando">
            <font-awesome-icon icon="save" />
            Crear Tipo
          </button>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Tipo de Empresa: ${selectedTipoEmp?.tipo_empresa || ''}`"
      size="lg"
      @close="closeEditModal"
      :showDefaultFooter="false"
    >
      <form @submit.prevent="updateTipoEmp">
        <div class="form-group full-width">
          <label class="municipal-form-label">Control:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="formData.ctrol_emp"
            disabled
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Tipo Empresa: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.tipo_empresa"
            maxlength="10"
            required
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="100"
            required
          />
        </div>
        <div class="modal-actions">
          <button type="button" class="btn-municipal-secondary" @click="closeEditModal" :disabled="guardando">
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

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Tipo de Empresa: ${selectedTipoEmp?.tipo_empresa || ''}`"
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
                <td class="label">Control:</td>
                <td><code>{{ selectedTipoEmp.ctrol_emp }}</code></td>
              </tr>
              <tr>
                <td class="label">Tipo Empresa:</td>
                <td><strong>{{ selectedTipoEmp.tipo_empresa }}</strong></td>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Constantes
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { isLoading: loading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Estado
const tiposEmp = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedTipoEmp = ref(null)
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
  ctrol_emp: null,
  tipo_empresa: '',
  descripcion: ''
})

// Computed - Filtrado cliente
const filteredData = computed(() => {
  let data = [...tiposEmp.value]

  if (filters.value.search) {
    const searchLower = filters.value.search.toLowerCase()
    data = data.filter(item =>
      item.tipo_empresa?.toLowerCase().includes(searchLower) ||
      item.descripcion?.toLowerCase().includes(searchLower) ||
      String(item.ctrol_emp).includes(searchLower)
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
async function loadTiposEmp() {
  showLoading('Cargando tipos de empresa...')

  try {
    const response = await execute('sp_tipos_emp_list', BASE_DB, [], '', null, SCHEMA)

    if (response?.result) {
      tiposEmp.value = response.result
      currentPage.value = 1
    } else {
      tiposEmp.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    tiposEmp.value = []
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
    ctrol_emp: null,
    tipo_empresa: '',
    descripcion: ''
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
  formData.value = { ctrol_emp: null, tipo_empresa: '', descripcion: '' }
}

function closeEditModal() {
  showEditModal.value = false
  formData.value = { ctrol_emp: null, tipo_empresa: '', descripcion: '' }
}

async function getNextCtrolEmp() {
  // Calcular siguiente control basado en datos existentes
  if (tiposEmp.value.length === 0) return 1
  const maxCtrol = Math.max(...tiposEmp.value.map(t => t.ctrol_emp || 0))
  return maxCtrol + 1
}

async function createTipoEmp() {
  // Validación
  if (!formData.value.tipo_empresa?.trim()) {
    showToast('Ingrese el tipo de empresa', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Tipo de Empresa',
    html: `<p>¿Desea crear el tipo <strong>${formData.value.tipo_empresa.toUpperCase()}</strong>?</p>
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
  showLoading('Creando tipo de empresa...', 'Guardando datos')
  guardando.value = true

  try {
    const nextCtrol = await getNextCtrolEmp()

    const params = [
      { nombre: 'p_ctrol_emp', valor: nextCtrol, tipo: 'integer' },
      { nombre: 'p_tipo_empresa', valor: formData.value.tipo_empresa.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]

    const response = await execute('sp_tipos_emp_create', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message || 'Error al crear', 'warning')
    } else {
      showToast('Tipo de empresa creado correctamente', 'success')
      closeCreateModal()
      await loadTiposEmp()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editTipoEmp(tipo) {
  selectedTipoEmp.value = tipo
  formData.value = {
    ctrol_emp: tipo.ctrol_emp,
    tipo_empresa: tipo.tipo_empresa,
    descripcion: tipo.descripcion
  }
  showEditModal.value = true
}

async function updateTipoEmp() {
  // Validación
  if (!formData.value.tipo_empresa?.trim()) {
    showToast('Ingrese el tipo de empresa', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Tipo de Empresa',
    html: `<p>¿Desea actualizar el tipo <strong>${formData.value.tipo_empresa.toUpperCase()}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando tipo de empresa...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ctrol_emp', valor: formData.value.ctrol_emp, tipo: 'integer' },
      { nombre: 'p_tipo_empresa', valor: formData.value.tipo_empresa.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]

    const response = await execute('sp_tipos_emp_update', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message || 'Error al actualizar', 'warning')
    } else {
      showToast('Tipo de empresa actualizado correctamente', 'success')
      closeEditModal()
      await loadTiposEmp()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function viewTipoEmp(tipo) {
  selectedTipoEmp.value = tipo
  showViewModal.value = true
}

async function confirmDeleteTipoEmp(tipo) {
  const result = await Swal.fire({
    title: '¿Eliminar tipo de empresa?',
    html: `<p>¿Está seguro de eliminar el tipo:</p>
           <p><strong>${tipo.tipo_empresa}</strong> - ${tipo.descripcion}?</p>
           <p class="text-danger">Esta acción no se puede deshacer</p>`,
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

async function deleteTipoEmp(tipo) {
  showLoading('Eliminando tipo de empresa...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_ctrol_emp', valor: tipo.ctrol_emp, tipo: 'integer' }
    ]

    const response = await execute('sp_tipos_emp_delete', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message || 'Error al eliminar', 'warning')
    } else {
      showToast('Tipo de empresa eliminado correctamente', 'success')
      await loadTiposEmp()
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

  const headers = ['Control', 'Tipo Empresa', 'Descripción']
  const rows = filteredData.value.map(item => [
    item.ctrol_emp,
    item.tipo_empresa,
    item.descripcion
  ])

  const csvContent = '\ufeff' + [headers.join(','), ...rows.map(r => r.map(c => `"${c || ''}"`).join(','))].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `tipos_empresa_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  showToast(`Exportados ${filteredData.value.length} registros`, 'success')
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
