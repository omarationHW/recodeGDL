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
              <label class="municipal-form-label">Ejercicio</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filters.ejercicio"
                :placeholder="new Date().getFullYear().toString()"
                @keyup.enter="loadUnidades"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.search"
                placeholder="Descripción o clave..."
                @keyup.enter="applyFilter"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="loadUnidades"
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
              @click="loadUnidades"
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
                <tr v-if="paginatedData.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron unidades para el ejercicio {{ filters.ejercicio }}</p>
                  </td>
                </tr>
                <tr v-else v-for="unidad in paginatedData" :key="unidad.ctrol_recolec" class="row-hover">
                  <td><code>{{ String(unidad.ctrol_recolec).padStart(3, '0') }}</code></td>
                  <td class="text-center">{{ unidad.ejercicio_recolec }}</td>
                  <td><span class="badge badge-primary">{{ unidad.cve_recolec }}</span></td>
                  <td>{{ unidad.descripcion }}</td>
                  <td class="text-end">${{ formatCurrency(unidad.costo_unidad) }}</td>
                  <td class="text-end">${{ formatCurrency(unidad.costo_exed) }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewUnidad(unidad)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editUnidad(unidad)"
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
      title="Nueva Unidad de Recolección"
      size="lg"
      :showDefaultFooter="false"
    >
      <form @submit.prevent="createUnidad" class="modal-form">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Ejercicio <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.ejercicio_recolec"
              class="municipal-form-control"
              placeholder="Año"
              required
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave <span class="required">*</span></label>
            <input
              type="text"
              v-model="formData.cve_recolec"
              class="municipal-form-control"
              maxlength="1"
              placeholder="A-Z"
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
            maxlength="80"
            placeholder="Descripción de la unidad"
            required
          />
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Costo Unidad</label>
            <input
              type="number"
              v-model.number="formData.costo_unidad"
              class="municipal-form-control"
              step="0.01"
              placeholder="0.00"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Costo Excedente</label>
            <input
              type="number"
              v-model.number="formData.costo_exed"
              class="municipal-form-control"
              step="0.01"
              placeholder="0.00"
            />
          </div>
        </div>

        <div class="modal-actions">
          <button type="button" @click="closeCreateModal" class="btn-municipal-secondary" :disabled="guardando">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="submit" class="btn-municipal-primary" :disabled="guardando">
            <font-awesome-icon icon="save" />
            Crear Unidad
          </button>
        </div>
      </form>
    </Modal>

    <!-- Modal Editar -->
    <Modal
      :show="showEditModal"
      @close="closeEditModal"
      title="Editar Unidad de Recolección"
      size="lg"
      :showDefaultFooter="false"
    >
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
            <label class="municipal-form-label">Ejercicio <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.ejercicio_recolec"
              class="municipal-form-control"
              required
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave <span class="required">*</span></label>
            <input
              type="text"
              v-model="formData.cve_recolec"
              class="municipal-form-control"
              maxlength="1"
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
            maxlength="80"
            required
          />
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Costo Unidad</label>
            <input
              type="number"
              v-model.number="formData.costo_unidad"
              class="municipal-form-control"
              step="0.01"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Costo Excedente</label>
            <input
              type="number"
              v-model.number="formData.costo_exed"
              class="municipal-form-control"
              step="0.01"
            />
          </div>
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
      title="Detalle de la Unidad"
      size="lg"
      :showDefaultFooter="false"
    >
      <div class="detail-grid" v-if="selectedUnidad">
        <div class="detail-item">
          <label class="detail-label">Control</label>
          <p class="detail-value"><code>{{ String(selectedUnidad.ctrol_recolec).padStart(3, '0') }}</code></p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Ejercicio</label>
          <p class="detail-value">{{ selectedUnidad.ejercicio_recolec }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Clave</label>
          <p class="detail-value"><span class="badge badge-primary">{{ selectedUnidad.cve_recolec }}</span></p>
        </div>
        <div class="detail-item full-width">
          <label class="detail-label">Descripción</label>
          <p class="detail-value">{{ selectedUnidad.descripcion }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Costo Unidad</label>
          <p class="detail-value">${{ formatCurrency(selectedUnidad.costo_unidad) }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Costo Excedente</label>
          <p class="detail-value">${{ formatCurrency(selectedUnidad.costo_exed) }}</p>
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" @click="showViewModal = false" class="btn-municipal-secondary">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
        <button type="button" @click="editUnidad(selectedUnidad); showViewModal = false" class="btn-municipal-primary">
          <font-awesome-icon icon="edit" />
          Editar
        </button>
      </div>
    </Modal>

  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Und_Recolec'"
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
const { execute } = useApi()
const { isLoading: loading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Estado
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const unidades = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedUnidad = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const guardando = ref(false)

// Filtros
const filters = ref({
  ejercicio: new Date().getFullYear(),
  search: ''
})

// Formulario
const formData = ref({
  ctrol_recolec: null,
  ejercicio_recolec: new Date().getFullYear(),
  cve_recolec: '',
  descripcion: '',
  costo_unidad: 0,
  costo_exed: 0
})

// Computed - Filtrado cliente
const filteredData = computed(() => {
  let data = [...unidades.value]

  if (filters.value.search) {
    const searchLower = filters.value.search.toLowerCase()
    data = data.filter(item =>
      item.descripcion?.toLowerCase().includes(searchLower) ||
      item.cve_recolec?.toLowerCase().includes(searchLower)
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
const formatCurrency = (value) => {
  if (!value && value !== 0) return '0.00'
  return Number(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

async function loadUnidades() {
  showLoading('Cargando unidades...')

  try {
    const params = [
      { nombre: 'p_ejercicio', valor: filters.value.ejercicio || new Date().getFullYear(), tipo: 'integer' }
    ]

    const response = await execute('sp_unidades_recoleccion_list', BASE_DB, params, '', null, SCHEMA)

    if (response?.result) {
      unidades.value = response.result
      currentPage.value = 1
    } else {
      unidades.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    unidades.value = []
  } finally {
    hideLoading()
  }
}

function applyFilter() {
  currentPage.value = 1
}

function clearFilters() {
  filters.value = {
    ejercicio: new Date().getFullYear(),
    search: ''
  }
  currentPage.value = 1
  loadUnidades()
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
    ctrol_recolec: null,
    ejercicio_recolec: filters.value.ejercicio || new Date().getFullYear(),
    cve_recolec: '',
    descripcion: '',
    costo_unidad: 0,
    costo_exed: 0
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

function closeEditModal() {
  showEditModal.value = false
}

async function createUnidad() {
  // Validación
  if (!formData.value.ejercicio_recolec) {
    showToast('Ingrese el ejercicio', 'warning')
    return
  }
  if (!formData.value.cve_recolec?.trim()) {
    showToast('Ingrese la clave', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Unidad de Recolección',
    html: `<p>¿Desea crear la unidad <strong>${formData.value.cve_recolec.toUpperCase()}</strong>?</p>
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
  showLoading('Creando unidad...', 'Guardando datos')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ejercicio', valor: formData.value.ejercicio_recolec, tipo: 'smallint' },
      { nombre: 'p_cve', valor: formData.value.cve_recolec.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' },
      { nombre: 'p_costo_unidad', valor: formData.value.costo_unidad || 0, tipo: 'numeric' },
      { nombre: 'p_costo_exed', valor: formData.value.costo_exed || 0, tipo: 'numeric' },
      { nombre: 'p_usuario_id', valor: 0, tipo: 'integer' }
    ]

    const response = await execute('sp_unidades_recoleccion_create', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.status?.startsWith('error')) {
      showToast(response.result[0].status.replace('error: ', '', 'warning'))
    } else {
      showToast('Unidad creada correctamente', 'success')
      closeCreateModal()
      await loadUnidades()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editUnidad(unidad) {
  selectedUnidad.value = unidad
  formData.value = {
    ctrol_recolec: unidad.ctrol_recolec,
    ejercicio_recolec: unidad.ejercicio_recolec,
    cve_recolec: unidad.cve_recolec || '',
    descripcion: unidad.descripcion || '',
    costo_unidad: unidad.costo_unidad || 0,
    costo_exed: unidad.costo_exed || 0
  }
  showEditModal.value = true
}

async function updateUnidad() {
  // Validación
  if (!formData.value.ejercicio_recolec) {
    showToast('Ingrese el ejercicio', 'warning')
    return
  }
  if (!formData.value.cve_recolec?.trim()) {
    showToast('Ingrese la clave', 'warning')
    return
  }
  if (!formData.value.descripcion?.trim()) {
    showToast('Ingrese la descripción', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Unidad',
    html: `<p>¿Desea actualizar la unidad <strong>${formData.value.cve_recolec.toUpperCase()}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando unidad...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ctrol', valor: formData.value.ctrol_recolec, tipo: 'integer' },
      { nombre: 'p_ejercicio', valor: formData.value.ejercicio_recolec, tipo: 'smallint' },
      { nombre: 'p_cve', valor: formData.value.cve_recolec.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' },
      { nombre: 'p_costo_unidad', valor: formData.value.costo_unidad || 0, tipo: 'numeric' },
      { nombre: 'p_costo_exed', valor: formData.value.costo_exed || 0, tipo: 'numeric' },
      { nombre: 'p_usuario_id', valor: 0, tipo: 'integer' }
    ]

    const response = await execute('sp_unidades_recoleccion_update', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.status?.startsWith('error')) {
      showToast(response.result[0].status.replace('error: ', '', 'warning'))
    } else {
      showToast('Unidad actualizada correctamente', 'success')
      closeEditModal()
      await loadUnidades()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function viewUnidad(unidad) {
  selectedUnidad.value = unidad
  showViewModal.value = true
}

async function confirmDelete(unidad) {
  const result = await Swal.fire({
    title: '¿Eliminar unidad?',
    html: `<p>¿Está seguro de eliminar la unidad:</p>
           <p><strong>${unidad.cve_recolec}</strong> - ${unidad.descripcion}?</p>
           <p class="text-danger">Esta acción no se puede deshacer</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteUnidad(unidad)
  }
}

async function deleteUnidad(unidad) {
  showLoading('Eliminando unidad...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_ctrol', valor: unidad.ctrol_recolec, tipo: 'integer' }
    ]

    const response = await execute('sp_unidades_recoleccion_delete', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.status?.startsWith('error')) {
      showToast(response.result[0].status.replace('error: ', '', 'warning'))
    } else {
      showToast('Unidad eliminada correctamente', 'success')
      await loadUnidades()
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

  const headers = ['Control', 'Ejercicio', 'Clave', 'Descripción', 'Costo Unidad', 'Costo Excedente']
  const rows = filteredData.value.map(item => [
    item.ctrol_recolec,
    item.ejercicio_recolec,
    item.cve_recolec,
    item.descripcion,
    item.costo_unidad,
    item.costo_exed
  ])

  const csvContent = '\ufeff' + [headers.join(','), ...rows.map(r => r.map(c => `"${c || ''}"`).join(','))].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `unidades_recoleccion_${filters.value.ejercicio}_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  showToast(`Exportados ${filteredData.value.length} registros`, 'success')
}

// Lifecycle
onMounted(() => {
  loadUnidades()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
