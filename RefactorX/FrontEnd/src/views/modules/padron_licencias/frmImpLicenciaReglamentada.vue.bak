<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="print" />
      </div>
      <div class="module-view-info">
        <h1>Impresión de Licencias Reglamentadas</h1>
        <p>Padrón de Licencias - Impresión de Licencias con Formato Oficial</p></div>
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
          Nueva Licencia
        </button>
        <button
          class="btn-municipal-secondary"
          @click="printSelected"
          :disabled="loading || selectedLicencias.length === 0"
        >
          <font-awesome-icon icon="print" />
          Imprimir Seleccionadas ({{ selectedLicencias.length }})
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de licencias -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.numeroLicencia"
              placeholder="Ingrese número de licencia"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Propietario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filters.estado">
              <option value="">Todos</option>
              <option value="PENDIENTE">Pendiente</option>
              <option value="IMPRESO">Impreso</option>
              <option value="ENTREGADO">Entregado</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencias"
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
            @click="loadLicencias"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de licencias -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Licencias Reglamentadas
          <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
        </h5>
        <div v-if="loading" class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th width="50">
                  <input
                    type="checkbox"
                    @change="toggleSelectAll"
                    :checked="isAllSelected"
                  >
                </th>
                <th>Número Licencia</th>
                <th>Propietario</th>
                <th>Giro</th>
                <th>Domicilio</th>
                <th>Estado</th>
                <th>Fecha Impresión</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="licencia in licencias" :key="licencia.id" class="row-hover">
                <td>
                  <input
                    type="checkbox"
                    :value="licencia.id"
                    v-model="selectedLicencias"
                  >
                </td>
                <td><strong class="text-primary">{{ licencia.numero_licencia?.trim() || 'N/A' }}</strong></td>
                <td>{{ licencia.propietario?.trim() || 'N/A' }}</td>
                <td>
                  <small>{{ truncateText(licencia.giro, 30) }}</small>
                </td>
                <td>
                  <small>{{ truncateText(licencia.domicilio, 40) }}</small>
                </td>
                <td>
                  <span class="badge" :class="getEstadoClass(licencia.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(licencia.estado)" />
                    {{ licencia.estado?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ formatDateTime(licencia.fecha_impresion) }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="previewLicencia(licencia)"
                      title="Vista previa"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editLicencia(licencia)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-success btn-sm"
                      @click="printSingle(licencia)"
                      title="Imprimir"
                    >
                      <font-awesome-icon icon="print" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmDeleteLicencia(licencia)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="licencias.length === 0 && !loading">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron licencias reglamentadas</p>
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
    <div v-if="loading && licencias.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando licencias reglamentadas...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Registro de Impresión"
      size="xl"
      @close="showCreateModal = false"
      @confirm="createLicencia"
      :loading="creatingLicencia"
      confirmText="Crear Registro"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createLicencia">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newLicencia.numeroLicencia"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newLicencia.estado" required>
              <option value="">Seleccionar...</option>
              <option value="PENDIENTE">Pendiente</option>
              <option value="IMPRESO">Impreso</option>
              <option value="ENTREGADO">Entregado</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="newLicencia.observaciones"
            rows="3"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Licencia: ${selectedLicencia?.numero_licencia}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="updateLicencia"
      :loading="updatingLicencia"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateLicencia">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia:</label>
            <input
              type="text"
              class="municipal-form-control"
              :value="editForm.numeroLicencia"
              disabled
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="editForm.estado" required>
              <option value="PENDIENTE">Pendiente</option>
              <option value="IMPRESO">Impreso</option>
              <option value="ENTREGADO">Entregado</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="editForm.observaciones"
            rows="3"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de vista previa -->
    <Modal
      :show="showPreviewModal"
      :title="`Vista Previa - Licencia ${selectedLicencia?.numero_licencia}`"
      size="xl"
      @close="showPreviewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedLicencia" class="license-preview">
        <div class="preview-header">
          <h3>GOBIERNO MUNICIPAL DE GUADALAJARA</h3>
          <h4>LICENCIA MUNICIPAL REGLAMENTADA</h4>
        </div>
        <div class="preview-body">
          <div class="preview-row">
            <div class="preview-field">
              <label>Número de Licencia:</label>
              <strong>{{ selectedLicencia.numero_licencia }}</strong>
            </div>
            <div class="preview-field">
              <label>Fecha de Expedición:</label>
              <strong>{{ formatDate(selectedLicencia.fecha_expedicion) }}</strong>
            </div>
          </div>
          <div class="preview-row">
            <div class="preview-field full">
              <label>Propietario:</label>
              <strong>{{ selectedLicencia.propietario }}</strong>
            </div>
          </div>
          <div class="preview-row">
            <div class="preview-field full">
              <label>Giro:</label>
              <strong>{{ selectedLicencia.giro }}</strong>
            </div>
          </div>
          <div class="preview-row">
            <div class="preview-field full">
              <label>Domicilio del Establecimiento:</label>
              <strong>{{ selectedLicencia.domicilio }}</strong>
            </div>
          </div>
          <div class="preview-row">
            <div class="preview-field">
              <label>Superficie:</label>
              <strong>{{ selectedLicencia.superficie }} m²</strong>
            </div>
            <div class="preview-field">
              <label>Vigencia:</label>
              <strong>{{ selectedLicencia.vigencia }}</strong>
            </div>
          </div>
        </div>
        <div class="preview-footer">
          <p>Esta licencia fue impresa el {{ formatDateTime(new Date()) }}</p>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showPreviewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="printSingle(selectedLicencia); showPreviewModal = false">
            <font-awesome-icon icon="print" />
            Imprimir
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'frmImpLicenciaReglamentada'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
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
const licencias = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedLicencia = ref(null)
const selectedLicencias = ref([])
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showPreviewModal = ref(false)
const creatingLicencia = ref(false)
const updatingLicencia = ref(false)

// Filtros
const filters = ref({
  numeroLicencia: '',
  propietario: '',
  estado: ''
})

// Formularios
const newLicencia = ref({
  numeroLicencia: '',
  estado: '',
  observaciones: ''
})

const editForm = ref({
  id: null,
  numeroLicencia: '',
  estado: '',
  observaciones: ''
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

const isAllSelected = computed(() => {
  return licencias.value.length > 0 && selectedLicencias.value.length === licencias.value.length
})

// Métodos
const loadLicencias = async () => {
  setLoading(true, 'Cargando licencias...')

  try {
    const response = await execute(
      'frmImpLicenciaReglamentada_sp_get_licencias_reglamentadas',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      licencias.value = response.result
      if (licencias.value.length > 0) {
        totalRecords.value = parseInt(licencias.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Licencias cargadas correctamente')
    } else {
      licencias.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar licencias')
    }
  } catch (error) {
    handleApiError(error)
    licencias.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchLicencias = () => {
  currentPage.value = 1
  loadLicencias()
}

const clearFilters = () => {
  filters.value = {
    numeroLicencia: '',
    propietario: '',
    estado: ''
  }
  currentPage.value = 1
  loadLicencias()
}

const openCreateModal = () => {
  newLicencia.value = {
    numeroLicencia: '',
    estado: '',
    observaciones: ''
  }
  showCreateModal.value = true
}

const createLicencia = async () => {
  if (!newLicencia.value.numeroLicencia || !newLicencia.value.estado) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  creatingLicencia.value = true

  try {
    const response = await execute(
      'frmImpLicenciaReglamentada_sp_create_licencia_reglamentada',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: newLicencia.value.numeroLicencia, tipo: 'string' },
        { nombre: 'p_estado', valor: newLicencia.value.estado, tipo: 'string' },
        { nombre: 'p_observaciones', valor: newLicencia.value.observaciones || '', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadLicencias()

      await Swal.fire({
        icon: 'success',
        title: 'Licencia creada',
        text: 'El registro de impresión ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Licencia creada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingLicencia.value = false
  }
}

const editLicencia = async (licencia) => {
  setLoading(true, 'Cargando datos de la licencia...')

  try {
    const response = await execute(
      'frmImpLicenciaReglamentada_sp_get_licencia_reglamentada_by_id',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: licencia.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      selectedLicencia.value = response.result[0]
      editForm.value = {
        id: selectedLicencia.value.id,
        numeroLicencia: selectedLicencia.value.numero_licencia?.trim(),
        estado: selectedLicencia.value.estado?.trim(),
        observaciones: selectedLicencia.value.observaciones?.trim() || ''
      }
      showEditModal.value = true
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const updateLicencia = async () => {
  if (!editForm.value.estado) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El estado es obligatorio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  updatingLicencia.value = true

  try {
    const response = await execute(
      'frmImpLicenciaReglamentada_sp_update_licencia_reglamentada',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_estado', valor: editForm.value.estado, tipo: 'string' },
        { nombre: 'p_observaciones', valor: editForm.value.observaciones || '', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadLicencias()

      await Swal.fire({
        icon: 'success',
        title: 'Licencia actualizada',
        text: 'Los datos han sido actualizados exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Licencia actualizada exitosamente')
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
    updatingLicencia.value = false
  }
}

const confirmDeleteLicencia = async (licencia) => {
  const result = await Swal.fire({
    title: 'Eliminar registro',
    text: `¿Está seguro de eliminar el registro de la licencia "${licencia.numero_licencia}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteLicencia(licencia)
  }
}

const deleteLicencia = async (licencia) => {
  setLoading(true, 'Eliminando registro...')

  try {
    const response = await execute(
      'frmImpLicenciaReglamentada_sp_delete_licencia_reglamentada',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: licencia.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadLicencias()

      await Swal.fire({
        icon: 'success',
        title: 'Registro eliminado',
        text: 'El registro ha sido eliminado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Registro eliminado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const previewLicencia = async (licencia) => {
  setLoading(true, 'Cargando vista previa...')

  try {
    const response = await execute(
      'frmImpLicenciaReglamentada_sp_get_licencia_reglamentada_by_id',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: licencia.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      selectedLicencia.value = response.result[0]
      showPreviewModal.value = true
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const printSingle = async (licencia) => {
  const result = await Swal.fire({
    title: 'Imprimir Licencia',
    text: `¿Desea imprimir la licencia ${licencia.numero_licencia}?`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    showToast('info', 'Enviando a impresora...')
    // Aquí iría la lógica de impresión real
    setTimeout(() => {
      showToast('success', 'Licencia enviada a impresora')
    }, 1000)
  }
}

const printSelected = async () => {
  const result = await Swal.fire({
    title: 'Imprimir Licencias',
    text: `¿Desea imprimir ${selectedLicencias.value.length} licencias seleccionadas?`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    showToast('info', 'Enviando licencias a impresora...')
    // Aquí iría la lógica de impresión por lotes
    setTimeout(() => {
      showToast('success', `${selectedLicencias.value.length} licencias enviadas a impresora`)
      selectedLicencias.value = []
    }, 1500)
  }
}

const toggleSelectAll = () => {
  if (isAllSelected.value) {
    selectedLicencias.value = []
  } else {
    selectedLicencias.value = licencias.value.map(l => l.id)
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadLicencias()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadLicencias()
}

// Utilidades
const getEstadoClass = (estado) => {
  const classes = {
    'PENDIENTE': 'badge-warning',
    'IMPRESO': 'badge-info',
    'ENTREGADO': 'badge-success'
  }
  return classes[estado] || 'badge-secondary'
}

const getEstadoIcon = (estado) => {
  const icons = {
    'PENDIENTE': 'clock',
    'IMPRESO': 'print',
    'ENTREGADO': 'check-circle'
  }
  return icons[estado] || 'question-circle'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatDateTime = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const truncateText = (text, length) => {
  if (!text) return 'N/A'
  return text.length > length ? text.substring(0, length) + '...' : text
}

// Lifecycle
onMounted(() => {
  loadLicencias()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showPreviewModal.value = false
})
</script>

<style scoped>
.license-preview {
  border: 2px solid #2c3e50;
  padding: 2rem;
  background: white;
}

.preview-header {
  text-align: center;
  border-bottom: 3px solid #ea8215;
  padding-bottom: 1rem;
  margin-bottom: 2rem;
}

.preview-header h3 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 0.5rem 0;
}

.preview-header h4 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #ea8215;
  margin: 0;
}

.preview-body {
  padding: 1rem 0;
}

.preview-row {
  display: flex;
  gap: 2rem;
  margin-bottom: 1.5rem;
}

.preview-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.preview-field.full {
  flex: 1 1 100%;
}

.preview-field label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 600;
  text-transform: uppercase;
}

.preview-field strong {
  font-size: 1rem;
  color: #2c3e50;
  padding: 0.5rem;
  background: #f8f9fa;
  border-left: 3px solid #ea8215;
}

.preview-footer {
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 2px solid #dee2e6;
  text-align: center;
}

.preview-footer p {
  margin: 0;
  color: #6c757d;
  font-size: 0.875rem;
  font-style: italic;
}
</style>
