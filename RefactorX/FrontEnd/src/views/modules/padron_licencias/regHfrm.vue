<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="history" />
      </div>
      <div class="module-view-info">
        <h1>Registro Histórico</h1>
        <p>Padrón de Licencias - Registro Histórico de Trámites</p></div>
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
          Nuevo Registro
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Fecha Inicio</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaInicio"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Fin</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaFin"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Trámite</label>
            <select class="municipal-form-control" v-model="filters.tipo">
              <option value="">Todos los tipos</option>
              <option value="ALTA">Alta</option>
              <option value="MODIFICACION">Modificación</option>
              <option value="REFRENDO">Refrendo</option>
              <option value="CANCELACION">Cancelación</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Búsqueda</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.search"
              placeholder="Buscar en registros..."
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchRecords"
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
            @click="loadRecords"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Registros Históricos
          <span class="badge-purple" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
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
                <th>ID</th>
                <th>Fecha</th>
                <th>Tipo Trámite</th>
                <th>Folio</th>
                <th>Descripción</th>
                <th>Usuario</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="record in records" :key="record.id" class="clickable-row">
                <td><strong class="text-primary">{{ record.id }}</strong></td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(record.fecha) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(record.tipo)">
                    {{ record.tipo || 'N/A' }}
                  </span>
                </td>
                <td><code class="text-muted">{{ record.folio || 'N/A' }}</code></td>
                <td>{{ record.descripcion?.substring(0, 50) || 'N/A' }}{{ record.descripcion?.length > 50 ? '...' : '' }}</td>
                <td>{{ record.usuario?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(record.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(record.estado)" />
                    {{ record.estado || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewRecord(record)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmDeleteRecord(record)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="records.length === 0 && !loading">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron registros históricos con los criterios especificados</p>
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
    <div v-if="loading && records.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando registros históricos...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Registro Histórico"
      size="xl"
      @close="showCreateModal = false"
      @confirm="createRecord"
      :loading="creatingRecord"
      confirmText="Crear Registro"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createRecord">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Trámite: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newRecord.tipo" required>
              <option value="">Seleccionar...</option>
              <option value="ALTA">Alta</option>
              <option value="MODIFICACION">Modificación</option>
              <option value="REFRENDO">Refrendo</option>
              <option value="CANCELACION">Cancelación</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newRecord.folio"
              maxlength="50"
              required
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción: <span class="required">*</span></label>
          <textarea
            class="municipal-form-control"
            v-model="newRecord.descripcion"
            rows="4"
            maxlength="500"
            required
          ></textarea>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Fecha: <span class="required">*</span></label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="newRecord.fecha"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado:</label>
            <select class="municipal-form-control" v-model="newRecord.estado">
              <option value="PENDIENTE">Pendiente</option>
              <option value="PROCESADO">Procesado</option>
              <option value="COMPLETADO">Completado</option>
              <option value="CANCELADO">Cancelado</option>
            </select>
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Registro: ${selectedRecord?.id}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedRecord" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información del Registro
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedRecord.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Tipo Trámite:</td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(selectedRecord.tipo)">
                    {{ selectedRecord.tipo || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td>{{ selectedRecord.folio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Fecha:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-info" />
                  {{ formatDate(selectedRecord.fecha) }}
                </td>
              </tr>
              <tr>
                <td class="label">Usuario:</td>
                <td>{{ selectedRecord.usuario?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(selectedRecord.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(selectedRecord.estado)" />
                    {{ selectedRecord.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section full-width">
            <h6 class="section-title">
              <font-awesome-icon icon="file-alt" />
              Descripción
            </h6>
            <p class="description-text">{{ selectedRecord.descripcion || 'Sin descripción' }}</p>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notification -->
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
      :componentName="'regHfrm'"
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
const records = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedRecord = ref(null)
const showCreateModal = ref(false)
const showViewModal = ref(false)
const creatingRecord = ref(false)

// Filtros
const filters = ref({
  fechaInicio: '',
  fechaFin: '',
  tipo: '',
  search: ''
})

// Formularios
const newRecord = ref({
  tipo: '',
  folio: '',
  descripcion: '',
  fecha: new Date().toISOString().split('T')[0],
  estado: 'PENDIENTE'
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
const loadRecords = async () => {
  setLoading(true, 'Cargando registros históricos...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'reghfrm_sp_get_historic_records',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' },
        { nombre: 'p_tipo', valor: filters.value.tipo || null, tipo: 'string' },
        { nombre: 'p_search', valor: filters.value.search || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      records.value = response.result
      if (records.value.length > 0) {
        totalRecords.value = parseInt(records.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Registros cargados correctamente')
      toast.value.duration = durationText
    } else {
      records.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar registros')
    }
  } catch (error) {
    handleApiError(error)
    records.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchRecords = () => {
  currentPage.value = 1
  loadRecords()
}

const clearFilters = () => {
  filters.value = {
    fechaInicio: '',
    fechaFin: '',
    tipo: '',
    search: ''
  }
  currentPage.value = 1
  loadRecords()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadRecords()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadRecords()
}

const openCreateModal = () => {
  newRecord.value = {
    tipo: '',
    folio: '',
    descripcion: '',
    fecha: new Date().toISOString().split('T')[0],
    estado: 'PENDIENTE'
  }
  showCreateModal.value = true
}

const createRecord = async () => {
  if (!newRecord.value.tipo || !newRecord.value.folio || !newRecord.value.descripcion || !newRecord.value.fecha) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de registro?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo registro histórico:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${newRecord.value.tipo}</li>
          <li style="margin: 5px 0;"><strong>Folio:</strong> ${newRecord.value.folio}</li>
          <li style="margin: 5px 0;"><strong>Fecha:</strong> ${newRecord.value.fecha}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear registro',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingRecord.value = true
  const startTime = performance.now()

  try {
    const usuario = localStorage.getItem('usuario') || 'sistema'
    const response = await execute(
      'reghfrm_sp_create_historic_record',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: newRecord.value.tipo, tipo: 'string' },
        { nombre: 'p_folio', valor: newRecord.value.folio, tipo: 'string' },
        { nombre: 'p_descripcion', valor: newRecord.value.descripcion, tipo: 'string' },
        { nombre: 'p_fecha', valor: newRecord.value.fecha, tipo: 'date' },
        { nombre: 'p_estado', valor: newRecord.value.estado, tipo: 'string' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadRecords()

      await Swal.fire({
        icon: 'success',
        title: '¡Registro creado!',
        text: 'El registro histórico ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Registro creado exitosamente')
      toast.value.duration = durationText
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear registro',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear el registro',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingRecord.value = false
  }
}

const viewRecord = async (record) => {
  setLoading(true, 'Cargando detalles del registro...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'reghfrm_sp_get_historic_record',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: record.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]) {
      selectedRecord.value = response.result[0]
      showViewModal.value = true
      toast.value.duration = durationText
    } else {
      showToast('error', 'No se pudieron cargar los detalles')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const confirmDeleteRecord = async (record) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: `¿Está seguro de eliminar el registro #${record.id}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteRecord(record)
  }
}

const deleteRecord = async (record) => {
  const startTime = performance.now()
  try {
    const response = await execute(
      'reghfrm_sp_delete_historic_record',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: record.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      loadRecords()

      await Swal.fire({
        icon: 'success',
        title: '¡Registro eliminado!',
        text: 'El registro ha sido eliminado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Registro eliminado exitosamente')
      toast.value.duration = durationText
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const getTipoBadgeClass = (tipo) => {
  const classes = {
    'ALTA': 'badge-success',
    'MODIFICACION': 'badge-info',
    'REFRENDO': 'badge-warning',
    'CANCELACION': 'badge-danger'
  }
  return classes[tipo] || 'badge-secondary'
}

const getEstadoBadgeClass = (estado) => {
  const classes = {
    'PENDIENTE': 'badge-warning',
    'PROCESADO': 'badge-info',
    'COMPLETADO': 'badge-success',
    'CANCELADO': 'badge-danger'
  }
  return classes[estado] || 'badge-secondary'
}

const getEstadoIcon = (estado) => {
  const icons = {
    'PENDIENTE': 'clock',
    'PROCESADO': 'spinner',
    'COMPLETADO': 'check-circle',
    'CANCELADO': 'times-circle'
  }
  return icons[estado] || 'info-circle'
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

// Lifecycle
onMounted(() => {
  loadRecords()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showViewModal.value = false
})
</script>
