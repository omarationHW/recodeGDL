<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-check" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Tipos de Aseo</h1>
        <p>Aseo Contratado - Tipos de Servicio</p>
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
                placeholder="Descripción, tipo o control..."
                @keyup.enter="searchTipos"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchTipos"
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
              @click="loadTipos"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarCSV"
              :disabled="loading || tiposFiltrados.length === 0"
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
            <span class="badge-info" v-if="tiposFiltrados.length > 0">{{ tiposFiltrados.length }} registros</span>
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
                <tr v-if="tiposPaginados.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="list-check" size="2x" class="empty-icon" />
                    <p>No se encontraron tipos de aseo registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="tipo in tiposPaginados" :key="tipo.ctrol_aseo" class="row-hover">
                  <td><strong class="text-primary">{{ String(tipo.ctrol_aseo).padStart(3, '0') }}</strong></td>
                  <td>
                    <span class="badge-secondary">{{ tipo.tipo_aseo || 'N/A' }}</span>
                  </td>
                  <td>{{ tipo.descripcion }}</td>
                  <td class="text-center">
                    <span v-if="tipo.cta_aplicacion">{{ tipo.cta_aplicacion }}</span>
                    <span v-else class="text-muted">-</span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editTipo(tipo)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click="confirmDeleteTipo(tipo)"
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
        <div class="pagination-container" v-if="tiposFiltrados.length > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, tiposFiltrados.length) }}
            de {{ tiposFiltrados.length }} registros
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
      title="Nuevo Tipo de Aseo"
      size="md"
      @close="closeCreateModal"
    >
      <form @submit.prevent="createTipo">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.tipo_aseo"
              maxlength="1"
              required
              placeholder="Ej: A, B, C..."
              style="text-transform: uppercase;"
            />
            <small class="form-hint">Un solo carácter</small>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Cta. Aplicación:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formData.cta_aplicacion"
              placeholder="Número de cuenta"
            />
          </div>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="80"
            required
            placeholder="Descripción del tipo de aseo"
          />
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeCreateModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="createTipo" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Crear Tipo' }}
        </button>
      </template>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Tipo: ${selectedTipo?.descripcion || ''}`"
      size="md"
      @close="closeEditModal"
    >
      <form @submit.prevent="updateTipo">
        <div class="form-group">
          <label class="municipal-form-label">Control:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="String(formData.ctrol_aseo).padStart(3, '0')"
            disabled
          />
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.tipo_aseo"
              maxlength="1"
              required
              style="text-transform: uppercase;"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Cta. Aplicación:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formData.cta_aplicacion"
            />
          </div>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="80"
            required
          />
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeEditModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="updateTipo" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
        </button>
      </template>
    </Modal>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Tipos_Aseo'"
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
const tipos = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedTipo = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const guardando = ref(false)

// Filtros
const filters = ref({
  search: ''
})

// Formulario
const formData = ref({
  ctrol_aseo: null,
  tipo_aseo: '',
  descripcion: '',
  cta_aplicacion: null
})

// Computed
const tiposFiltrados = computed(() => {
  let result = [...tipos.value]

  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    result = result.filter(t =>
      t.descripcion?.toLowerCase().includes(search) ||
      t.tipo_aseo?.toLowerCase().includes(search) ||
      String(t.ctrol_aseo).includes(search)
    )
  }

  return result
})

const totalPages = computed(() => {
  return Math.ceil(tiposFiltrados.value.length / itemsPerPage.value) || 1
})

const tiposPaginados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return tiposFiltrados.value.slice(start, end)
})

// Métodos
async function loadTipos() {
  showLoading('Cargando tipos de aseo...')
  try {
    const response = await execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)

    if (response?.result) {
      tipos.value = response.result
    } else {
      tipos.value = []
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
    tipos.value = []
  } finally {
    hideLoading()
  }
}

function searchTipos() {
  currentPage.value = 1
}

function clearFilters() {
  filters.value = {
    search: ''
  }
  currentPage.value = 1
}

function openCreateModal() {
  formData.value = {
    ctrol_aseo: null,
    tipo_aseo: '',
    descripcion: '',
    cta_aplicacion: null
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function createTipo() {
  // Validación
  if (!formData.value.tipo_aseo?.trim()) {
    showToast('Ingrese el tipo de aseo', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Tipo de Aseo',
    html: `<p>¿Desea crear el tipo <strong>${formData.value.tipo_aseo.toUpperCase()}</strong> - ${formData.value.descripcion}?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Creando tipo de aseo...', 'Guardando datos')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_tipo_aseo', valor: formData.value.tipo_aseo.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' },
      { nombre: 'p_cta_aplicacion', valor: formData.value.cta_aplicacion || null, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 0, tipo: 'integer' }
    ]

    const response = await execute('sp_tipos_aseo_create', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].msg, 'warning')
    } else {
      showToast('Tipo de aseo creado correctamente', 'success')
      closeCreateModal()
      await loadTipos()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editTipo(tipo) {
  selectedTipo.value = tipo
  formData.value = {
    ctrol_aseo: tipo.ctrol_aseo,
    tipo_aseo: tipo.tipo_aseo || '',
    descripcion: tipo.descripcion || '',
    cta_aplicacion: tipo.cta_aplicacion || null
  }
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  selectedTipo.value = null
}

async function updateTipo() {
  // Validación
  if (!formData.value.tipo_aseo?.trim()) {
    showToast('Ingrese el tipo de aseo', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Tipo de Aseo',
    html: `<p>¿Desea actualizar el tipo <strong>${formData.value.tipo_aseo.toUpperCase()}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando tipo de aseo...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ctrol_aseo', valor: formData.value.ctrol_aseo, tipo: 'integer' },
      { nombre: 'p_tipo_aseo', valor: formData.value.tipo_aseo.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' },
      { nombre: 'p_cta_aplicacion', valor: formData.value.cta_aplicacion || null, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 0, tipo: 'integer' }
    ]

    const response = await execute('sp_tipos_aseo_update', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].msg, 'warning')
    } else {
      showToast('Tipo de aseo actualizado correctamente', 'success')
      closeEditModal()
      await loadTipos()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function confirmDeleteTipo(tipo) {
  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Eliminar Tipo de Aseo',
    html: `
      <p>¿Está seguro de eliminar el tipo</p>
      <p><strong>${tipo.tipo_aseo} - ${tipo.descripcion}</strong>?</p>
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
  showLoading('Eliminando tipo de aseo...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_ctrol_aseo', valor: tipo.ctrol_aseo, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 0, tipo: 'integer' }
    ]

    const response = await execute('sp_tipos_aseo_delete', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].msg, 'warning')
    } else {
      showToast('Tipo de aseo eliminado correctamente', 'success')
      await loadTipos()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function exportarCSV() {
  if (tiposFiltrados.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['Control', 'Tipo', 'Descripción', 'Cta. Aplicación']
  const rows = tiposFiltrados.value.map(t => [
    String(t.ctrol_aseo).padStart(3, '0'),
    t.tipo_aseo || '',
    t.descripcion || '',
    t.cta_aplicacion || ''
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))
  ].join('\n')

  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `tipos_aseo_${new Date().toISOString().split('T')[0]}.csv`
  link.click()
  URL.revokeObjectURL(link.href)

  showToast(`${tiposFiltrados.value.length} registros exportados`, 'success')
}

// Lifecycle
onMounted(() => {
  loadTipos()
})
</script>
