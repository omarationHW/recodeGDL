<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Administración de Contratos</h1>
        <p>Aseo Contratado - Alta, Baja y Modificación de Contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="nuevoContrato" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nuevo Contrato
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
                placeholder="Contrato, cuenta o contribuyente..."
                @keyup.enter="applyFilter"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona</label>
              <select class="municipal-form-control" v-model="filters.zona" @change="applyFilter">
                <option value="">Todas</option>
                <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                  Zona {{ z.zona }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo Aseo</label>
              <select class="municipal-form-control" v-model="filters.tipo" @change="applyFilter">
                <option value="">Todos</option>
                <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.tipo_aseo">
                  {{ t.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status</label>
              <select class="municipal-form-control" v-model="filters.status" @change="applyFilter">
                <option value="">Todos</option>
                <option value="V">Vigentes</option>
                <option value="C">Cancelados</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="applyFilter" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="clearFilters" :disabled="loading">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
            <button class="btn-municipal-secondary" @click="loadContratos" :disabled="loading">
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
            Contratos Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Zona</th>
                  <th>Tipo Aseo</th>
                  <th class="text-end">Monto</th>
                  <th>Status</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="paginatedData.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron contratos</p>
                  </td>
                </tr>
                <tr v-else v-for="contrato in paginatedData" :key="contrato.control_contrato" class="row-hover">
                  <td><code>{{ contrato.num_contrato }}</code></td>
                  <td>{{ contrato.empresa_descripcion || contrato.num_empresa }}</td>
                  <td class="text-center"><span class="badge badge-info">{{ contrato.zona_id }}</span></td>
                  <td>{{ contrato.tipo_aseo_descripcion || contrato.tipo_aseo_id }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.monto_mensual) }}</td>
                  <td class="text-center">
                    <span class="badge" :class="contrato.status_vigencia === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ contrato.status_vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewContrato(contrato)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editContrato(contrato)"
                        :disabled="contrato.status_vigencia !== 'V'"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDelete(contrato)"
                        :disabled="contrato.status_vigencia !== 'V'"
                        title="Cancelar"
                      >
                        <font-awesome-icon icon="ban" />
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

        <div class="municipal-card-body" v-if="loading">
          <div class="loading-state">
            <div class="spinner"></div>
            <p>Cargando contratos...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <Modal
      :show="showModal"
      @close="closeModal"
      :title="modoEdicion === 'nuevo' ? 'Nuevo Contrato' : 'Editar Contrato'"
      size="xl"
      :showDefaultFooter="false"
    >
      <form @submit.prevent="guardarContrato" class="modal-form">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número Contrato</label>
            <input
              type="number"
              v-model.number="formData.num_contrato"
              class="municipal-form-control"
              :disabled="modoEdicion === 'editar'"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Empresa <span class="required">*</span></label>
            <select v-model.number="formData.num_empresa" class="municipal-form-control" required>
              <option value="">Seleccione...</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.descripcion }}
              </option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Aseo <span class="required">*</span></label>
            <select v-model.number="formData.tipo_aseo_id" class="municipal-form-control" required>
              <option value="">Seleccione...</option>
              <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
                {{ t.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Zona <span class="required">*</span></label>
            <select v-model.number="formData.zona_id" class="municipal-form-control" required>
              <option value="">Seleccione...</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.ctrol_zona">
                Zona {{ z.zona }} - {{ z.descripcion || 'Sin descripción' }}
              </option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Monto Mensual <span class="required">*</span></label>
            <input
              type="number"
              v-model.number="formData.monto_mensual"
              class="municipal-form-control"
              step="0.01"
              min="0"
              required
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Unidades Recolección</label>
            <input
              type="number"
              v-model.number="formData.unidades_recoleccion"
              class="municipal-form-control"
              min="1"
            />
          </div>
        </div>

        <div class="form-group">
          <label class="municipal-form-label">Observaciones</label>
          <textarea
            v-model="formData.observaciones"
            class="municipal-form-control"
            rows="3"
          ></textarea>
        </div>

        <div class="modal-actions">
          <button type="button" @click="closeModal" class="btn-municipal-secondary" :disabled="guardando">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="submit" class="btn-municipal-primary" :disabled="guardando">
            <font-awesome-icon icon="save" />
            {{ modoEdicion === 'nuevo' ? 'Crear' : 'Guardar' }}
          </button>
        </div>
      </form>
    </Modal>

    <!-- Modal Ver Detalle -->
    <Modal
      :show="showViewModal"
      @close="showViewModal = false"
      title="Detalle del Contrato"
      size="lg"
      :showDefaultFooter="false"
    >
      <div class="detail-grid" v-if="selectedContrato">
        <div class="detail-item">
          <label class="detail-label">Número Contrato</label>
          <p class="detail-value"><code>{{ selectedContrato.num_contrato }}</code></p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Empresa</label>
          <p class="detail-value">{{ selectedContrato.empresa_descripcion || selectedContrato.num_empresa }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Tipo Aseo</label>
          <p class="detail-value">{{ selectedContrato.tipo_aseo_descripcion || selectedContrato.tipo_aseo_id }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Zona</label>
          <p class="detail-value">{{ selectedContrato.zona_id }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Monto Mensual</label>
          <p class="detail-value">${{ formatCurrency(selectedContrato.monto_mensual) }}</p>
        </div>
        <div class="detail-item">
          <label class="detail-label">Status</label>
          <p class="detail-value">
            <span class="badge" :class="selectedContrato.status_vigencia === 'V' ? 'badge-success' : 'badge-secondary'">
              {{ selectedContrato.status_vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
            </span>
          </p>
        </div>
        <div class="detail-item full-width" v-if="selectedContrato.observaciones">
          <label class="detail-label">Observaciones</label>
          <p class="detail-value">{{ selectedContrato.observaciones }}</p>
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" @click="showViewModal = false" class="btn-municipal-secondary">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
        <button
          type="button"
          @click="editContrato(selectedContrato); showViewModal = false"
          class="btn-municipal-primary"
          :disabled="selectedContrato?.status_vigencia !== 'V'"
        >
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
    :componentName="'Contratos'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
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

const contratos = ref([])
const zonas = ref([])
const empresas = ref([])
const tiposAseo = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(25)
const selectedContrato = ref(null)
const showModal = ref(false)
const showViewModal = ref(false)
const modoEdicion = ref('nuevo')
const guardando = ref(false)

// Filtros
const filters = ref({
  search: '',
  zona: '',
  tipo: '',
  status: 'V'
})

// Formulario
const formData = ref({
  control_contrato: null,
  num_contrato: null,
  num_empresa: '',
  tipo_aseo_id: '',
  zona_id: '',
  monto_mensual: 0,
  unidades_recoleccion: 1,
  observaciones: ''
})

// Computed - Filtrado cliente
const filteredData = computed(() => {
  let data = [...contratos.value]

  if (filters.value.search) {
    const searchLower = filters.value.search.toLowerCase()
    data = data.filter(item =>
      String(item.num_contrato).includes(searchLower) ||
      item.empresa_descripcion?.toLowerCase().includes(searchLower)
    )
  }

  if (filters.value.zona) {
    data = data.filter(item => item.zona_id == filters.value.zona)
  }

  if (filters.value.tipo) {
    data = data.filter(item => item.tipo_aseo_id == filters.value.tipo)
  }

  if (filters.value.status) {
    data = data.filter(item => item.status_vigencia === filters.value.status)
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
async function loadContratos() {
  showLoading('Cargando contratos...', 'Consultando base de datos')

  try {
    const params = [
      { nombre: 'p_limit', valor: 500, tipo: 'integer' },
      { nombre: 'p_offset', valor: 0, tipo: 'integer' }
    ]
    const response = await execute('sp_aseo_contratos_list', BASE_DB, params, '', null, SCHEMA)

    if (response?.result) {
      contratos.value = response.result
      currentPage.value = 1
    } else {
      contratos.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    contratos.value = []
  } finally {
    hideLoading()
  }
}

async function loadCatalogos() {
  try {
    const [respZonas, respEmpresas, respTipos] = await Promise.all([
      execute('sp_zonas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_empresas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)
    ])
    zonas.value = respZonas?.result || []
    empresas.value = respEmpresas?.result || []
    tiposAseo.value = respTipos?.result || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

function applyFilter() {
  currentPage.value = 1
}

function clearFilters() {
  filters.value = { search: '', zona: '', tipo: '', status: 'V' }
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

function nuevoContrato() {
  modoEdicion.value = 'nuevo'
  formData.value = {
    control_contrato: null,
    num_contrato: null,
    num_empresa: '',
    tipo_aseo_id: '',
    zona_id: '',
    monto_mensual: 0,
    unidades_recoleccion: 1,
    observaciones: ''
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
}

function editContrato(contrato) {
  modoEdicion.value = 'editar'
  selectedContrato.value = contrato
  formData.value = {
    control_contrato: contrato.control_contrato,
    num_contrato: contrato.num_contrato,
    num_empresa: contrato.num_empresa,
    tipo_aseo_id: contrato.tipo_aseo_id,
    zona_id: contrato.zona_id,
    monto_mensual: contrato.monto_mensual || 0,
    unidades_recoleccion: contrato.unidades_recoleccion || 1,
    observaciones: contrato.observaciones || ''
  }
  showModal.value = true
}

function viewContrato(contrato) {
  selectedContrato.value = contrato
  showViewModal.value = true
}

async function guardarContrato() {
  if (!formData.value.num_empresa || !formData.value.tipo_aseo_id || !formData.value.zona_id) {
    showToast('Complete los campos requeridos', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: modoEdicion.value === 'nuevo' ? 'Crear Contrato' : 'Actualizar Contrato',
    text: '¿Confirma la operación?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, confirmar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Guardando contrato...', 'Procesando')
  guardando.value = true

  try {
    if (modoEdicion.value === 'nuevo') {
      // sp_aseo_contratos_create(p_num_empresa, p_tipo_aseo_id, p_zona_id, p_unidades_recoleccion, p_monto_mensual, p_usuario_id, p_observaciones)
      const params = [
        { nombre: 'p_num_empresa', valor: formData.value.num_empresa, tipo: 'integer' },
        { nombre: 'p_tipo_aseo_id', valor: formData.value.tipo_aseo_id, tipo: 'integer' },
        { nombre: 'p_zona_id', valor: formData.value.zona_id, tipo: 'integer' },
        { nombre: 'p_unidades_recoleccion', valor: formData.value.unidades_recoleccion || 1, tipo: 'integer' },
        { nombre: 'p_monto_mensual', valor: formData.value.monto_mensual || 0, tipo: 'numeric' },
        { nombre: 'p_usuario_id', valor: 1, tipo: 'integer' },
        { nombre: 'p_observaciones', valor: formData.value.observaciones || '', tipo: 'string' }
      ]
      const response = await execute('sp_aseo_contratos_create', BASE_DB, params, '', null, SCHEMA)
      if (response?.result?.[0]?.r_success === false) {
        showToast(response.result[0].r_message || 'Error al crear contrato', 'error')
        return
      }
    } else {
      // sp_aseo_contratos_update(p_control_contrato, p_num_empresa, p_tipo_aseo_id, p_zona_id, p_unidades_recoleccion, p_monto_mensual, p_observaciones)
      const params = [
        { nombre: 'p_control_contrato', valor: formData.value.control_contrato, tipo: 'integer' },
        { nombre: 'p_num_empresa', valor: formData.value.num_empresa, tipo: 'integer' },
        { nombre: 'p_tipo_aseo_id', valor: formData.value.tipo_aseo_id, tipo: 'integer' },
        { nombre: 'p_zona_id', valor: formData.value.zona_id, tipo: 'integer' },
        { nombre: 'p_unidades_recoleccion', valor: formData.value.unidades_recoleccion || 1, tipo: 'integer' },
        { nombre: 'p_monto_mensual', valor: formData.value.monto_mensual || 0, tipo: 'numeric' },
        { nombre: 'p_observaciones', valor: formData.value.observaciones || '', tipo: 'string' }
      ]
      const response = await execute('sp_aseo_contratos_update', BASE_DB, params, '', null, SCHEMA)
      if (response?.result?.[0]?.success === false) {
        showToast(response.result[0].message || 'Error al actualizar contrato', 'error')
        return
      }
    }

    showToast('Contrato guardado correctamente', 'success')
    closeModal()
    await loadContratos()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function confirmDelete(contrato) {
  const result = await Swal.fire({
    title: '¿Cancelar contrato?',
    html: `<p>¿Está seguro de cancelar el contrato <strong>#${contrato.num_contrato}</strong>?</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    const { value: motivo } = await Swal.fire({
      title: 'Motivo de Cancelación',
      input: 'textarea',
      inputLabel: 'Ingrese el motivo',
      inputPlaceholder: 'Ej: Solicitud del cliente...',
      showCancelButton: true,
      confirmButtonText: 'Confirmar',
      cancelButtonText: 'Cancelar'
    })

    if (motivo) {
      await cancelarContrato(contrato, motivo)
    }
  }
}

async function cancelarContrato(contrato, motivo) {
  showLoading('Cancelando contrato...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_control_contrato', valor: contrato.control_contrato, tipo: 'integer' },
      { nombre: 'p_motivo_baja', valor: motivo, tipo: 'string' },
      { nombre: 'p_usuario_id', valor: 1, tipo: 'integer' }
    ]
    await execute('sp_aseo_cancelar_contrato', BASE_DB, params, '', null, SCHEMA)
    showToast('Contrato cancelado correctamente', 'success')
    await loadContratos()
  } catch (error) {
    hideLoading()
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

function exportarCSV() {
  if (filteredData.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['Contrato', 'Empresa', 'Zona', 'Tipo Aseo', 'Monto', 'Status']
  const rows = filteredData.value.map(item => [
    item.num_contrato,
    item.empresa_descripcion || item.num_empresa,
    item.zona_id,
    item.tipo_aseo_descripcion || item.tipo_aseo_id,
    item.monto_mensual,
    item.status_vigencia === 'V' ? 'Vigente' : 'Cancelado'
  ])

  const csvContent = '\ufeff' + [headers.join(','), ...rows.map(r => r.map(c => `"${c || ''}"`).join(','))].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `contratos_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  showToast(`Exportados ${filteredData.value.length} registros`, 'success')
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando módulo...', 'Iniciando')
  await loadCatalogos()
  hideLoading()
  await loadContratos()
})

onBeforeUnmount(() => {
  showModal.value = false
  showViewModal.value = false
})
</script>
