<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percent" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Recargos</h1>
        <p>Aseo Contratado - Porcentajes de Recargos por Periodo</p>
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
          Nuevo Recargo
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtrar por Año</label>
              <select class="municipal-form-control" v-model="filters.year" @change="loadRecargos">
                <option :value="null">Todos los años</option>
                <option v-for="year in availableYears" :key="year" :value="year">{{ year }}</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-secondary"
              @click="loadRecargos"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarCSV"
              :disabled="loading || recargosFiltrados.length === 0"
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
            Recargos Registrados
            <span class="badge-info" v-if="recargosFiltrados.length > 0">{{ recargosFiltrados.length }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Periodo (Mes/Año)</th>
                  <th>% Recargo</th>
                  <th>% Multa</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="recargosPaginados.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="percent" size="2x" class="empty-icon" />
                    <p>No se encontraron recargos registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="recargo in recargosPaginados" :key="recargo.aso_mes_recargo" class="row-hover">
                  <td><strong class="text-primary">{{ formatPeriodo(recargo.aso_mes_recargo) }}</strong></td>
                  <td>
                    <span class="badge-secondary">{{ recargo.porc_recargo }}%</span>
                  </td>
                  <td>
                    <span class="badge-warning">{{ recargo.porc_multa }}%</span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editRecargo(recargo)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click="confirmDeleteRecargo(recargo)"
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
        <div class="pagination-container" v-if="recargosFiltrados.length > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, recargosFiltrados.length) }}
            de {{ recargosFiltrados.length }} registros
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
      title="Crear Nuevo Recargo"
      size="md"
      @close="closeCreateModal"
    >
      <form @submit.prevent="createRecargo">
        <div class="form-group">
          <label class="municipal-form-label">Periodo (Mes/Año): <span class="required">*</span></label>
          <input
            type="month"
            class="municipal-form-control"
            v-model="formData.periodo"
            required
          />
          <small class="form-hint">Seleccione el mes y año del recargo</small>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">% Recargo: <span class="required">*</span></label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.porc_recargo"
                step="0.01"
                min="0"
                max="100"
                required
                placeholder="0.00"
              />
              <span class="input-suffix">%</span>
            </div>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">% Multa: <span class="required">*</span></label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.porc_multa"
                step="0.01"
                min="0"
                max="100"
                required
                placeholder="0.00"
              />
              <span class="input-suffix">%</span>
            </div>
          </div>
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeCreateModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="createRecargo" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Crear Recargo' }}
        </button>
      </template>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Recargo: ${formatPeriodo(selectedRecargo?.aso_mes_recargo)}`"
      size="md"
      @close="closeEditModal"
    >
      <form @submit.prevent="updateRecargo">
        <div class="form-group">
          <label class="municipal-form-label">Periodo (Mes/Año):</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="formatPeriodo(formData.aso_mes_recargo)"
            disabled
          />
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">% Recargo: <span class="required">*</span></label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.porc_recargo"
                step="0.01"
                min="0"
                max="100"
                required
              />
              <span class="input-suffix">%</span>
            </div>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">% Multa: <span class="required">*</span></label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.porc_multa"
                step="0.01"
                min="0"
                max="100"
                required
              />
              <span class="input-suffix">%</span>
            </div>
          </div>
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeEditModal" :disabled="guardando">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="updateRecargo" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
        </button>
      </template>
    </Modal>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Recargos'"
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
const recargos = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const selectedRecargo = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const guardando = ref(false)

// Filtros
const filters = ref({
  year: null
})

// Años disponibles para filtro
const availableYears = computed(() => {
  const currentYear = new Date().getFullYear()
  const years = []
  for (let y = currentYear; y >= currentYear - 10; y--) {
    years.push(y)
  }
  return years
})

// Formulario
const formData = ref({
  periodo: '',
  aso_mes_recargo: null,
  porc_recargo: null,
  porc_multa: null
})

// Computed
const recargosFiltrados = computed(() => {
  return recargos.value
})

const totalPages = computed(() => {
  return Math.ceil(recargosFiltrados.value.length / itemsPerPage.value) || 1
})

const recargosPaginados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return recargosFiltrados.value.slice(start, end)
})

// Métodos
async function loadRecargos() {
  showLoading('Cargando recargos...', 'Obteniendo datos')
  try {
    const params = filters.value.year
      ? [{ nombre: 'p_year', valor: filters.value.year, tipo: 'integer' }]
      : []

    const response = await execute('sp_recargos_list', BASE_DB, params, '', null, SCHEMA)

    if (response?.result) {
      recargos.value = response.result
    } else {
      recargos.value = []
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
    recargos.value = []
  } finally {
    hideLoading()
  }
}

function formatPeriodo(fecha) {
  if (!fecha) return ''
  try {
    const date = new Date(fecha)
    const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
    return `${meses[date.getMonth()]} ${date.getFullYear()}`
  } catch {
    return fecha
  }
}

function openCreateModal() {
  formData.value = {
    periodo: '',
    aso_mes_recargo: null,
    porc_recargo: null,
    porc_multa: null
  }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function createRecargo() {
  // Validación
  if (!formData.value.periodo) {
    showToast('Seleccione el periodo', 'warning')
    return
  }
  if (formData.value.porc_recargo === null || formData.value.porc_recargo === '') {
    showToast('Ingrese el porcentaje de recargo', 'warning')
    return
  }
  if (formData.value.porc_multa === null || formData.value.porc_multa === '') {
    showToast('Ingrese el porcentaje de multa', 'warning')
    return
  }

  // Convertir periodo a fecha (primer día del mes)
  const periodoDate = `${formData.value.periodo}-01`

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Crear Recargo',
    html: `
      <p>¿Desea crear el recargo para <strong>${formatPeriodo(periodoDate)}</strong>?</p>
      <p>% Recargo: <strong>${formData.value.porc_recargo}%</strong></p>
      <p>% Multa: <strong>${formData.value.porc_multa}%</strong></p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Creando recargo...', 'Guardando datos')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_aso_mes_recargo', valor: periodoDate, tipo: 'timestamp' },
      { nombre: 'p_porc_recargo', valor: parseFloat(formData.value.porc_recargo), tipo: 'numeric' },
      { nombre: 'p_porc_multa', valor: parseFloat(formData.value.porc_multa), tipo: 'numeric' }
    ]

    const response = await execute('sp_recargos_create', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message, 'warning')
    } else {
      showToast('Recargo creado correctamente', 'success')
      closeCreateModal()
      await loadRecargos()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

function editRecargo(recargo) {
  selectedRecargo.value = recargo
  formData.value = {
    periodo: '',
    aso_mes_recargo: recargo.aso_mes_recargo,
    porc_recargo: recargo.porc_recargo,
    porc_multa: recargo.porc_multa
  }
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  selectedRecargo.value = null
}

async function updateRecargo() {
  // Validación
  if (formData.value.porc_recargo === null || formData.value.porc_recargo === '') {
    showToast('Ingrese el porcentaje de recargo', 'warning')
    return
  }
  if (formData.value.porc_multa === null || formData.value.porc_multa === '') {
    showToast('Ingrese el porcentaje de multa', 'warning')
    return
  }

  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Actualizar Recargo',
    html: `
      <p>¿Desea actualizar el recargo de <strong>${formatPeriodo(formData.value.aso_mes_recargo)}</strong>?</p>
      <p>% Recargo: <strong>${formData.value.porc_recargo}%</strong></p>
      <p>% Multa: <strong>${formData.value.porc_multa}%</strong></p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading
  showLoading('Actualizando recargo...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_aso_mes_recargo', valor: formData.value.aso_mes_recargo, tipo: 'timestamp' },
      { nombre: 'p_porc_recargo', valor: parseFloat(formData.value.porc_recargo), tipo: 'numeric' },
      { nombre: 'p_porc_multa', valor: parseFloat(formData.value.porc_multa), tipo: 'numeric' }
    ]

    const response = await execute('sp_recargos_update', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message, 'warning')
    } else {
      showToast('Recargo actualizado correctamente', 'success')
      closeEditModal()
      await loadRecargos()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function confirmDeleteRecargo(recargo) {
  // 1. SweetAlert2 confirmación
  const confirmResult = await Swal.fire({
    title: 'Eliminar Recargo',
    html: `
      <p>¿Está seguro de eliminar el recargo de</p>
      <p><strong>${formatPeriodo(recargo.aso_mes_recargo)}</strong>?</p>
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
  showLoading('Eliminando recargo...', 'Procesando')

  try {
    const params = [
      { nombre: 'p_aso_mes_recargo', valor: recargo.aso_mes_recargo, tipo: 'timestamp' }
    ]

    const response = await execute('sp_recargos_delete', BASE_DB, params, '', null, SCHEMA)

    if (response?.result?.[0]?.success === false) {
      showToast(response.result[0].message, 'warning')
    } else {
      showToast('Recargo eliminado correctamente', 'success')
      await loadRecargos()
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function exportarCSV() {
  if (recargosFiltrados.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['Periodo', '% Recargo', '% Multa']
  const rows = recargosFiltrados.value.map(r => [
    formatPeriodo(r.aso_mes_recargo),
    r.porc_recargo,
    r.porc_multa
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))
  ].join('\n')

  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `recargos_aseo_${new Date().toISOString().split('T')[0]}.csv`
  link.click()
  URL.revokeObjectURL(link.href)

  showToast(`${recargosFiltrados.value.length} registros exportados`, 'success')
}

// Lifecycle
onMounted(() => {
  loadRecargos()
})
</script>

