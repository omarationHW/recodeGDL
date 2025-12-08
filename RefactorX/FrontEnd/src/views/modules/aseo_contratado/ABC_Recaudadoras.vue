<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-check-alt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Empresas Recaudadoras</h1>
        <p>Aseo Contratado - Administración de Recaudadoras</p>
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
                v-model="filters.search"
                placeholder="Descripción o número..."
                @keyup.enter="searchRecaudadoras"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchRecaudadoras"
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
              @click="loadRecaudadoras"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarCSV"
              :disabled="loading || recaudadorasFiltradas.length === 0"
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
            <span class="badge-info" v-if="recaudadorasFiltradas.length > 0">{{ recaudadorasFiltradas.length }} registros</span>
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
                <tr v-if="recaudadorasPaginadas.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="money-check-alt" size="2x" class="empty-icon" />
                    <p>No se encontraron recaudadoras registradas</p>
                  </td>
                </tr>
                <tr v-else v-for="recaudadora in recaudadorasPaginadas" :key="recaudadora.num_rec" class="row-hover">
                  <td><strong class="text-primary">{{ recaudadora.num_rec }}</strong></td>
                  <td>{{ recaudadora.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editRecaudadora(recaudadora)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click="confirmDeleteRecaudadora(recaudadora)"
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
        <div class="pagination-container" v-if="recaudadorasFiltradas.length > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, recaudadorasFiltradas.length) }}
            de {{ recaudadorasFiltradas.length }} registros
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
      title="Nueva Empresa Recaudadora"
      size="md"
      @close="closeCreateModal"
    >
      <form @submit.prevent="createRecaudadora">
        <div class="form-group">
          <label class="municipal-form-label">Número: <span class="required">*</span></label>
          <input
            type="number"
            class="municipal-form-control"
            v-model="formData.num_rec"
            min="1"
            required
            placeholder="Número de recaudadora"
          />
          <small class="form-hint">Siguiente disponible: {{ nextNumRec }}</small>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="100"
            required
            placeholder="Nombre de la empresa recaudadora"
          />
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeCreateModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="createRecaudadora" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Crear Recaudadora' }}
        </button>
      </template>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Recaudadora: ${selectedRecaudadora?.descripcion || ''}`"
      size="md"
      @close="closeEditModal"
    >
      <form @submit.prevent="updateRecaudadora">
        <div class="form-group">
          <label class="municipal-form-label">Número:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="formData.num_rec"
            disabled
          />
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formData.descripcion"
            maxlength="100"
            required
          />
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeEditModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="updateRecaudadora" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
        </button>
      </template>
    </Modal>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Recaudadoras'"
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
const SCHEMA = 'public'

// Composables
const { execute } = useApi()
const { isLoading: loading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estado
const recaudadoras = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedRecaudadora = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const guardando = ref(false)
const nextNumRec = ref(1)

// Filtros
const filters = ref({
  search: ''
})

// Formulario
const formData = ref({
  num_rec: null,
  descripcion: ''
})

// Computed
const recaudadorasFiltradas = computed(() => {
  let result = [...recaudadoras.value]

  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    result = result.filter(r =>
      r.descripcion?.toLowerCase().includes(search) ||
      String(r.num_rec).includes(search)
    )
  }

  return result
})

const totalPages = computed(() => {
  return Math.ceil(recaudadorasFiltradas.value.length / itemsPerPage.value) || 1
})

const recaudadorasPaginadas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return recaudadorasFiltradas.value.slice(start, end)
})

// Métodos
async function loadRecaudadoras() {
  showLoading('Cargando recaudadoras...', 'Obteniendo datos')
  try {
    const response = await execute('sp_list_recaudadoras', BASE_DB, [], '', null, SCHEMA)

    if (response?.result) {
      recaudadoras.value = response.result
    } else {
      recaudadoras.value = []
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
    recaudadoras.value = []
  } finally {
    hideLoading()
  }
}

async function loadNextNumRec() {
  try {
    const response = await execute('sp_get_next_num_recaudadora', BASE_DB, [], '', null, SCHEMA)
    if (response?.result?.[0]?.next_num) {
      nextNumRec.value = response.result[0].next_num
    }
  } catch (e) {
    hideLoading()
    console.error('Error obteniendo siguiente número:', e)
  }
}

function searchRecaudadoras() {
  currentPage.value = 1
}

function clearFilters() {
  filters.value = {
    search: ''
  }
  currentPage.value = 1
}

function openCreateModal() {
  loadNextNumRec()
  formData.value = {
    num_rec: nextNumRec.value,
    descripcion: ''
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function createRecaudadora() {
  // Validación
  if (!formData.value.num_rec) {
    showToast('Ingrese el número de recaudadora', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Recaudadora',
    html: `<p>¿Desea crear la recaudadora <strong>${formData.value.descripcion}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Creando recaudadora...', 'Guardando datos')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_num_rec', valor: parseInt(formData.value.num_rec), tipo: 'integer' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]

    const response = await execute('sp_insert_recaudadora', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message, 'warning')
    } else {
      showToast('Recaudadora creada correctamente', 'success')
      closeCreateModal()
      await loadRecaudadoras()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editRecaudadora(recaudadora) {
  selectedRecaudadora.value = recaudadora
  formData.value = {
    num_rec: recaudadora.num_rec,
    descripcion: recaudadora.descripcion || ''
  }
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  selectedRecaudadora.value = null
}

async function updateRecaudadora() {
  // Validación
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Recaudadora',
    html: `<p>¿Desea actualizar la recaudadora <strong>${formData.value.descripcion}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando recaudadora...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_num_rec', valor: parseInt(formData.value.num_rec), tipo: 'integer' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]

    const response = await execute('sp_update_recaudadora', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message, 'warning')
    } else {
      showToast('Recaudadora actualizada correctamente', 'success')
      closeEditModal()
      await loadRecaudadoras()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function confirmDeleteRecaudadora(recaudadora) {
  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Eliminar Recaudadora',
    html: `
      <p>¿Está seguro de eliminar la recaudadora</p>
      <p><strong>${recaudadora.descripcion}</strong>?</p>
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
  showLoading('Eliminando recaudadora...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_num_rec', valor: parseInt(recaudadora.num_rec), tipo: 'integer' }
    ]

    const response = await execute('sp_delete_recaudadora', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message, 'warning')
    } else {
      showToast('Recaudadora eliminada correctamente', 'success')
      await loadRecaudadoras()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function exportarCSV() {
  if (recaudadorasFiltradas.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['Número', 'Descripción']
  const rows = recaudadorasFiltradas.value.map(r => [
    r.num_rec,
    r.descripcion || ''
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))
  ].join('\n')

  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `recaudadoras_aseo_${new Date().toISOString().split('T')[0]}.csv`
  link.click()
  URL.revokeObjectURL(link.href)

  showToast(`${recaudadorasFiltradas.value.length} registros exportados`, 'success')
}

// Lifecycle
onMounted(async () => {
  await loadRecaudadoras()
  await loadNextNumRec()
})
</script>

