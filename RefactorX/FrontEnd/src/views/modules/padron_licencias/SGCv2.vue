<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Sistema de Gestión de Calidad</h1>
        <p>Padrón de Licencias - SGC v2.0 Indicadores y Procesos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Proceso
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Indicadores de Calidad -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="tachometer-alt" />
          Indicadores de Calidad (KPIs)
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="kpi-grid">
          <div class="kpi-card" v-for="kpi in indicators" :key="kpi.nombre">
            <div class="kpi-icon" :class="getKpiColorClass(kpi.valor, kpi.meta)">
              <font-awesome-icon :icon="kpi.icono" />
            </div>
            <div class="kpi-content">
              <h6 class="kpi-label">{{ kpi.nombre }}</h6>
              <div class="kpi-value">{{ kpi.valor }}{{ kpi.unidad }}</div>
              <div class="kpi-meta">Meta: {{ kpi.meta }}{{ kpi.unidad }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Nombre del Proceso</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre"
              placeholder="Buscar proceso..."
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Categoría</label>
            <select class="municipal-form-control" v-model="filters.categoria">
              <option value="">Todas las categorías</option>
              <option value="OPERATIVO">Operativo</option>
              <option value="ESTRATEGICO">Estratégico</option>
              <option value="SOPORTE">Soporte</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filters.estado">
              <option value="">Todos los estados</option>
              <option value="ACTIVO">Activo</option>
              <option value="EN_REVISION">En Revisión</option>
              <option value="PAUSADO">Pausado</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchProcesses"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadProcesses"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de procesos -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Procesos de Calidad
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="processes.length > 0">
            {{ processes.length }} procesos
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="processes.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="chart-line" size="3x" />
          </div>
          <h4>Sistema de Gestión de Calidad</h4>
          <p>Utilice los filtros de búsqueda para consultar procesos o cree un nuevo proceso de calidad</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="processes.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron procesos con los criterios especificados</p>
        </div>

        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Nombre Proceso</th>
                <th>Categoría</th>
                <th>Responsable</th>
                <th>Indicador (%)</th>
                <th>Estado</th>
                <th>Última Revisión</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="process in processes"
                :key="process.id"
                @click="selectedRow = process"
                :class="{ 'table-row-selected': selectedRow === process }"
                class="row-hover"
              >
                <td><strong class="text-primary">{{ process.id }}</strong></td>
                <td>{{ process.nombre || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getCategoryBadgeClass(process.categoria)">
                    {{ process.categoria || 'N/A' }}
                  </span>
                </td>
                <td>{{ process.responsable?.trim() || 'N/A' }}</td>
                <td>
                  <div class="progress-container">
                    <div class="progress">
                      <div
                        class="progress-bar"
                        :class="getProgressBarClass(process.indicador)"
                        :style="{ width: process.indicador + '%' }"
                      >
                        {{ process.indicador }}%
                      </div>
                    </div>
                  </div>
                </td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(process.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(process.estado)" />
                    {{ process.estado || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(process.ultima_revision) }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewProcess(process)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="editProcess(process)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div v-if="processes.length > 0" class="pagination-controls">
        <div class="pagination-info">
          <span class="text-muted">
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
            de {{ formatNumber(totalRecords) }} registros
          </span>
        </div>

        <div class="pagination-size">
          <label class="municipal-form-label me-2">Registros por página:</label>
          <select
            class="municipal-form-control form-control-sm"
            :value="itemsPerPage"
            @change="changePageSize"
            style="width: auto; display: inline-block;"
          >
            <option value="5">5</option>
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100">100</option>
          </select>
        </div>

        <div class="pagination-buttons">
          <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
            <font-awesome-icon icon="angle-double-left" />
          </button>
          <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
            <font-awesome-icon icon="angle-left" />
          </button>
          <button
            v-for="page in visiblePages"
            :key="page"
            class="btn-sm"
            :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
            @click="goToPage(page)"
          >
            {{ page }}
          </button>
          <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
            <font-awesome-icon icon="angle-right" />
          </button>
          <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
            <font-awesome-icon icon="angle-double-right" />
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de creación/edición -->
    <Modal
      :show="showCreateModal"
      :title="editMode ? 'Editar Proceso' : 'Crear Nuevo Proceso'"
      size="xl"
      @close="showCreateModal = false"
      @confirm="saveProcess"
      :loading="savingProcess"
      :confirmText="editMode ? 'Guardar Cambios' : 'Crear Proceso'"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="saveProcess">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Nombre del Proceso: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="processForm.nombre"
              maxlength="100"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Categoría: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="processForm.categoria" required>
              <option value="">Seleccionar...</option>
              <option value="OPERATIVO">Operativo</option>
              <option value="ESTRATEGICO">Estratégico</option>
              <option value="SOPORTE">Soporte</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Responsable: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="processForm.responsable"
              maxlength="100"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Indicador (%): <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="processForm.indicador"
              min="0"
              max="100"
              required
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción:</label>
          <textarea
            class="municipal-form-control"
            v-model="processForm.descripcion"
            rows="4"
            maxlength="500"
          ></textarea>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Estado:</label>
            <select class="municipal-form-control" v-model="processForm.estado">
              <option value="ACTIVO">Activo</option>
              <option value="EN_REVISION">En Revisión</option>
              <option value="PAUSADO">Pausado</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Última Revisión:</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="processForm.ultima_revision"
            >
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Proceso: ${selectedProcess?.nombre}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedProcess" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información del Proceso
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedProcess.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Nombre:</td>
                <td>{{ selectedProcess.nombre || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Categoría:</td>
                <td>
                  <span class="badge" :class="getCategoryBadgeClass(selectedProcess.categoria)">
                    {{ selectedProcess.categoria || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Responsable:</td>
                <td>{{ selectedProcess.responsable?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Indicador:</td>
                <td>
                  <div class="progress">
                    <div
                      class="progress-bar"
                      :class="getProgressBarClass(selectedProcess.indicador)"
                      :style="{ width: selectedProcess.indicador + '%' }"
                    >
                      {{ selectedProcess.indicador }}%
                    </div>
                  </div>
                </td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(selectedProcess.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(selectedProcess.estado)" />
                    {{ selectedProcess.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Última Revisión:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-info" />
                  {{ formatDate(selectedProcess.ultima_revision) }}
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section full-width" v-if="selectedProcess.descripcion">
            <h6 class="section-title">
              <font-awesome-icon icon="file-alt" />
              Descripción
            </h6>
            <p class="description-text">{{ selectedProcess.descripcion }}</p>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editProcess(selectedProcess); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Proceso
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'SGCv2'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Sistema de Gestión de Calidad'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const processes = ref([])
const indicators = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedProcess = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
const showCreateModal = ref(false)
const showViewModal = ref(false)
const savingProcess = ref(false)
const editMode = ref(false)

// Filtros
const filters = ref({
  nombre: '',
  categoria: '',
  estado: ''
})

// Formularios
const processForm = ref({
  id: null,
  nombre: '',
  categoria: '',
  responsable: '',
  indicador: 0,
  descripcion: '',
  estado: 'ACTIVO',
  ultima_revision: new Date().toISOString().split('T')[0]
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
const loadIndicators = async () => {
  try {
    const startTime = performance.now()

    const response = await execute(
      'sgcv2_sp_get_quality_indicators',
      'padron_licencias',
      [],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      indicators.value = response.result
      toast.value.duration = durationText
    }
  } catch (error) {
    handleApiError(error)
  }
}

const loadProcesses = async () => {
  showLoading('Cargando procesos de calidad...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const startTime = performance.now()

    const response = await execute(
      'sgcv2_sp_get_processes',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_nombre', valor: filters.value.nombre || null, tipo: 'string' },
        { nombre: 'p_categoria', valor: filters.value.categoria || null, tipo: 'string' },
        { nombre: 'p_estado', valor: filters.value.estado || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      processes.value = response.result
      if (processes.value.length > 0) {
        totalRecords.value = parseInt(processes.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      toast.value.duration = durationText
      showToast('success', 'Procesos cargados correctamente')
    } else {
      processes.value = []
      totalRecords.value = 0
      toast.value.duration = durationText
      showToast('error', 'Error al cargar procesos')
    }
  } catch (error) {
    handleApiError(error)
    processes.value = []
    totalRecords.value = 0
  } finally {
    hideLoading()
  }
}

const searchProcesses = () => {
  currentPage.value = 1
  loadProcesses()
}

const clearFilters = () => {
  filters.value = {
    nombre: '',
    categoria: '',
    estado: ''
  }
  processes.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    selectedRow.value = null
    loadProcesses()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  selectedRow.value = null
  loadProcesses()
}

const openCreateModal = () => {
  editMode.value = false
  processForm.value = {
    id: null,
    nombre: '',
    categoria: '',
    responsable: '',
    indicador: 0,
    descripcion: '',
    estado: 'ACTIVO',
    ultima_revision: new Date().toISOString().split('T')[0]
  }
  showCreateModal.value = true
}

const editProcess = (process) => {
  editMode.value = true
  selectedProcess.value = process
  processForm.value = {
    id: process.id,
    nombre: process.nombre || '',
    categoria: process.categoria || '',
    responsable: process.responsable?.trim() || '',
    indicador: process.indicador || 0,
    descripcion: process.descripcion || '',
    estado: process.estado || 'ACTIVO',
    ultima_revision: process.ultima_revision ? process.ultima_revision.split('T')[0] : new Date().toISOString().split('T')[0]
  }
  showCreateModal.value = true
}

const saveProcess = async () => {
  if (!processForm.value.nombre || !processForm.value.categoria || !processForm.value.responsable) {
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
    title: editMode.value ? '¿Confirmar actualización?' : '¿Confirmar creación?',
    html: `
      <div class="swal-confirmation-text">
        <p>${editMode.value ? 'Se actualizará el proceso:' : 'Se creará un nuevo proceso:'}</p>
        <ul class="swal-selection-list">
          <li><strong>Nombre:</strong> ${processForm.value.nombre}</li>
          <li><strong>Categoría:</strong> ${processForm.value.categoria}</li>
          <li><strong>Responsable:</strong> ${processForm.value.responsable}</li>
          <li><strong>Indicador:</strong> ${processForm.value.indicador}%</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: editMode.value ? 'Sí, guardar cambios' : 'Sí, crear proceso',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  savingProcess.value = true

  try {
    const startTime = performance.now()

    const params = [
      { nombre: 'p_id', valor: processForm.value.id, tipo: 'integer' },
      { nombre: 'p_nombre', valor: processForm.value.nombre, tipo: 'string' },
      { nombre: 'p_categoria', valor: processForm.value.categoria, tipo: 'string' },
      { nombre: 'p_responsable', valor: processForm.value.responsable, tipo: 'string' },
      { nombre: 'p_indicador', valor: processForm.value.indicador, tipo: 'integer' },
      { nombre: 'p_descripcion', valor: processForm.value.descripcion || '', tipo: 'string' },
      { nombre: 'p_estado', valor: processForm.value.estado, tipo: 'string' },
      { nombre: 'p_ultima_revision', valor: processForm.value.ultima_revision, tipo: 'date' }
    ]

    const response = await execute(
      'sgcv2_sp_save_process',
      'padron_licencias',
      params,
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadProcesses()
      loadIndicators()

      await Swal.fire({
        icon: 'success',
        title: editMode.value ? '¡Proceso actualizado!' : '¡Proceso creado!',
        text: editMode.value ? 'El proceso ha sido actualizado exitosamente' : 'El proceso ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      toast.value.duration = durationText
      showToast('success', editMode.value ? 'Proceso actualizado exitosamente' : 'Proceso creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al guardar proceso',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo guardar el proceso',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    savingProcess.value = false
  }
}

const viewProcess = (process) => {
  selectedProcess.value = process
  showViewModal.value = true
}

// Utilidades
const getKpiColorClass = (valor, meta) => {
  const percentage = (valor / meta) * 100
  if (percentage >= 100) return 'kpi-success'
  if (percentage >= 80) return 'kpi-warning'
  return 'kpi-danger'
}

const getCategoryBadgeClass = (categoria) => {
  const classes = {
    'OPERATIVO': 'badge-purple',
    'ESTRATEGICO': 'badge-warning',
    'SOPORTE': 'badge-secondary'
  }
  return classes[categoria] || 'badge-secondary'
}

const getEstadoBadgeClass = (estado) => {
  const classes = {
    'ACTIVO': 'badge-success',
    'EN_REVISION': 'badge-warning',
    'PAUSADO': 'badge-danger'
  }
  return classes[estado] || 'badge-secondary'
}

const getEstadoIcon = (estado) => {
  const icons = {
    'ACTIVO': 'check-circle',
    'EN_REVISION': 'clock',
    'PAUSADO': 'pause-circle'
  }
  return icons[estado] || 'info-circle'
}

const getProgressBarClass = (indicador) => {
  if (indicador >= 80) return 'bg-success'
  if (indicador >= 50) return 'bg-warning'
  return 'bg-danger'
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

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Lifecycle
onMounted(() => {
  loadIndicators()
  loadProcesses()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showViewModal.value = false
})
</script>

