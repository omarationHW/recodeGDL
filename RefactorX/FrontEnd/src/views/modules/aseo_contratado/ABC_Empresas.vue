<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Empresas</h1>
        <p>Aseo Contratado - Gestión de Empresas Prestadoras de Servicio</p>
      </div>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nueva Empresa
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar por Descripción</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.descripcion"
                placeholder="Nombre o descripción..."
                @keyup.enter="searchEmpresas"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Empresa</label>
              <select class="municipal-form-control" v-model="filters.ctrol_emp">
                <option :value="null">Todos</option>
                <option v-for="tipo in tiposEmpresa" :key="tipo.ctrol_emp" :value="tipo.ctrol_emp">
                  {{ tipo.tipo_empresa }}
                </option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchEmpresas"
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
              @click="loadEmpresas"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarCSV"
              :disabled="loading || empresasFiltradas.length === 0"
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
            Empresas Registradas
            <span class="badge-info" v-if="empresasFiltradas.length > 0">{{ empresasFiltradas.length }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No. Empresa</th>
                  <th>Ctrl. Tipo</th>
                  <th>Tipo</th>
                  <th>Descripción</th>
                  <th>Representante</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="empresasPaginadas.length === 0">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="building" size="2x" class="empty-icon" />
                    <p>No se encontraron empresas registradas</p>
                  </td>
                </tr>
                <tr v-else v-for="empresa in empresasPaginadas" :key="`${empresa.num_empresa}-${empresa.ctrol_emp}`" class="row-hover">
                  <td><strong class="text-primary">{{ empresa.num_empresa }}</strong></td>
                  <td><code class="text-muted">{{ empresa.ctrol_emp }}</code></td>
                  <td>
                    <span class="badge-secondary">{{ empresa.tipo_empresa || 'N/A' }}</span>
                  </td>
                  <td>{{ empresa.descripcion }}</td>
                  <td>{{ empresa.representante || 'N/A' }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editEmpresa(empresa)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click="confirmDeleteEmpresa(empresa)"
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
        <div class="pagination-container" v-if="empresasFiltradas.length > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, empresasFiltradas.length) }}
            de {{ empresasFiltradas.length }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model="itemsPerPage" @change="currentPage = 1">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="currentPage = 1"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="pagination-button"
                @click="currentPage--"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <span class="pagination-current">
                Página {{ currentPage }} de {{ totalPages }}
              </span>

              <button
                class="pagination-button"
                @click="currentPage++"
                :disabled="currentPage >= totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                class="pagination-button"
                @click="currentPage = totalPages"
                :disabled="currentPage >= totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Empresa"
      size="md"
      @close="closeCreateModal"
    >
      <form @submit.prevent="createEmpresa">
        <div class="form-group">
          <label class="municipal-form-label">Tipo de Empresa: <span class="required">*</span></label>
          <select class="municipal-form-control" v-model="formData.ctrol_emp" required>
            <option :value="null" disabled>Seleccionar tipo...</option>
            <option v-for="tipo in tiposEmpresa" :key="tipo.ctrol_emp" :value="tipo.ctrol_emp">
              {{ tipo.tipo_empresa }}
            </option>
          </select>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción / Nombre: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="80"
            required
            placeholder="Nombre de la empresa"
          />
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Representante:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.representante"
            maxlength="80"
            placeholder="Nombre del representante"
          />
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeCreateModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="createEmpresa" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Crear Empresa' }}
        </button>
      </template>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Empresa: ${selectedEmpresa?.descripcion || ''}`"
      size="md"
      @close="closeEditModal"
    >
      <form @submit.prevent="updateEmpresa">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">No. Empresa:</label>
            <input
              type="text"
              class="municipal-form-control"
              :value="formData.num_empresa"
              disabled
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo:</label>
            <input
              type="text"
              class="municipal-form-control"
              :value="getTipoNombre(formData.ctrol_emp)"
              disabled
            />
          </div>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción / Nombre: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="80"
            required
          />
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Representante:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.representante"
            maxlength="80"
          />
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeEditModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="updateEmpresa" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
        </button>
      </template>
    </Modal>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Empresas'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Constantes
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Composables
const { execute } = useApi()
const { isLoading: loading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estado
const empresas = ref([])
const tiposEmpresa = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedEmpresa = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const guardando = ref(false)

// Filtros
const filters = ref({
  descripcion: '',
  ctrol_emp: null
})

// Formulario
const formData = ref({
  num_empresa: null,
  ctrol_emp: null,
  descripcion: '',
  representante: ''
})

// Computed
const empresasFiltradas = computed(() => {
  let result = [...empresas.value]

  if (filters.value.descripcion) {
    const search = filters.value.descripcion.toLowerCase()
    result = result.filter(e =>
      e.descripcion?.toLowerCase().includes(search) ||
      e.representante?.toLowerCase().includes(search)
    )
  }

  if (filters.value.ctrol_emp !== null) {
    result = result.filter(e => e.ctrol_emp === filters.value.ctrol_emp)
  }

  return result
})

const totalPages = computed(() => {
  return Math.ceil(empresasFiltradas.value.length / itemsPerPage.value) || 1
})

const empresasPaginadas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return empresasFiltradas.value.slice(start, end)
})

// Métodos
async function loadTiposEmpresa() {
  try {
    const response = await execute('sp_tipos_emp_list', BASE_DB, [], '', null, SCHEMA)
    if (response?.result) {
      tiposEmpresa.value = response.result
    }
  } catch (e) {
    hideLoading()
    console.error('Error cargando tipos de empresa:', e)
  }
}

async function loadEmpresas() {
  showLoading('Cargando empresas...', 'Obteniendo datos')
  try {
    const response = await execute('sp_empresas_list', BASE_DB, [], '', null, SCHEMA)
    if (response?.result) {
      empresas.value = response.result
    } else {
      empresas.value = []
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
    empresas.value = []
  } finally {
    hideLoading()
  }
}

function searchEmpresas() {
  currentPage.value = 1
}

function clearFilters() {
  filters.value = {
    descripcion: '',
    ctrol_emp: null
  }
  currentPage.value = 1
}

function getTipoNombre(ctrol_emp) {
  const tipo = tiposEmpresa.value.find(t => t.ctrol_emp === ctrol_emp)
  return tipo?.tipo_empresa || 'N/A'
}

function openCreateModal() {
  formData.value = {
    num_empresa: null,
    ctrol_emp: null,
    descripcion: '',
    representante: ''
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function createEmpresa() {
  // Validación
  if (!formData.value.ctrol_emp) {
    showToast('Seleccione el tipo de empresa', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción de la empresa', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Empresa',
    html: `<p>¿Desea crear la empresa <strong>${formData.value.descripcion}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Creando empresa...', 'Guardando datos')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ctrol_emp', valor: formData.value.ctrol_emp, tipo: 'integer' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' },
      { nombre: 'p_representante', valor: formData.value.representante?.trim() || '', tipo: 'string' }
    ]

    const response = await execute('sp_empresas_create', BASE_DB, params, '', null, SCHEMA)

    if (response?.result) {
      showToast('Empresa creada correctamente', 'success')
      closeCreateModal()
      await loadEmpresas()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editEmpresa(empresa) {
  selectedEmpresa.value = empresa
  formData.value = {
    num_empresa: empresa.num_empresa,
    ctrol_emp: empresa.ctrol_emp,
    descripcion: empresa.descripcion || '',
    representante: empresa.representante || ''
  }
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  selectedEmpresa.value = null
}

async function updateEmpresa() {
  // Validación
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción de la empresa', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Empresa',
    html: `<p>¿Desea actualizar la empresa <strong>${formData.value.descripcion}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando empresa...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_num_empresa', valor: formData.value.num_empresa, tipo: 'integer' },
      { nombre: 'p_ctrol_emp', valor: formData.value.ctrol_emp, tipo: 'integer' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' },
      { nombre: 'p_representante', valor: formData.value.representante?.trim() || '', tipo: 'string' }
    ]

    const response = await execute('sp_empresas_update', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message || 'Error al actualizar', 'warning')
    } else {
      showToast('Empresa actualizada correctamente', 'success')
      closeEditModal()
      await loadEmpresas()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function confirmDeleteEmpresa(empresa) {
  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Eliminar Empresa',
    html: `
      <p>¿Está seguro de eliminar la empresa?</p>
      <p><strong>${empresa.descripcion}</strong></p>
      <p class="text-danger"><small>Esta acción no se puede deshacer</small></p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Eliminando empresa...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_num_empresa', valor: empresa.num_empresa, tipo: 'integer' },
      { nombre: 'p_ctrol_emp', valor: empresa.ctrol_emp, tipo: 'integer' }
    ]

    const response = await execute('sp_empresas_delete', BASE_DB, params, '', null, SCHEMA)

    // El SP retorna success/message
    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message || 'No se puede eliminar la empresa', 'warning')
    } else {
      showToast(response?.result?.[0]?.message || 'Empresa eliminada correctamente', 'success')
      await loadEmpresas()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function exportarCSV() {
  if (empresasFiltradas.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['No. Empresa', 'Ctrl. Tipo', 'Tipo', 'Descripción', 'Representante']
  const rows = empresasFiltradas.value.map(e => [
    e.num_empresa,
    e.ctrol_emp,
    e.tipo_empresa || '',
    e.descripcion || '',
    e.representante || ''
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))
  ].join('\n')

  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `empresas_aseo_${new Date().toISOString().split('T')[0]}.csv`
  link.click()
  URL.revokeObjectURL(link.href)

  showToast(`${empresasFiltradas.value.length} registros exportados`, 'success')
}

// Lifecycle
onMounted(async () => {
  await loadTiposEmpresa()
  await loadEmpresas()
})
</script>
