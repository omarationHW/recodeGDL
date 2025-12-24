<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="sync-alt" />
      </div>
      <div class="module-view-info">
        <h1>Conexión TDM</h1>
        <p>Padrón de Licencias - Conexión con Trámites Digitales México</p>
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
          @click="syncTramites"
          :disabled="syncing"
        >
          <font-awesome-icon :icon="syncing ? 'spinner' : 'sync-alt'" :spin="syncing" />
          {{ syncing ? 'Sincronizando...' : 'Sincronizar Ahora' }}
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Estado de Conexión -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="plug" />
          Estado de Conexión
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="connection-status-container">
          <div class="connection-status-card" :class="connectionStatus.connected ? 'connected' : 'disconnected'">
            <div class="status-icon">
              <font-awesome-icon :icon="connectionStatus.connected ? 'check-circle' : 'times-circle'" />
            </div>
            <div class="status-content">
              <h6>{{ connectionStatus.connected ? 'Conectado' : 'Desconectado' }}</h6>
              <p>{{ connectionStatus.message }}</p>
              <small>Última verificación: {{ formatDateTime(connectionStatus.last_check) }}</small>
            </div>
          </div>

          <div class="connection-stats">
            <div class="stat-item">
              <font-awesome-icon icon="check" class="text-success" />
              <div class="stat-value">{{ connectionStats.exitosos || 0 }}</div>
              <div class="stat-label">Sincronizaciones Exitosas</div>
            </div>
            <div class="stat-item">
              <font-awesome-icon icon="times" class="text-danger" />
              <div class="stat-value">{{ connectionStats.fallidos || 0 }}</div>
              <div class="stat-label">Sincronizaciones Fallidas</div>
            </div>
            <div class="stat-item">
              <font-awesome-icon icon="clock" class="text-warning" />
              <div class="stat-value">{{ connectionStats.pendientes || 0 }}</div>
              <div class="stat-label">Pendientes</div>
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
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filters.estado">
              <option value="">Todos los estados</option>
              <option value="EXITOSO">Exitoso</option>
              <option value="FALLIDO">Fallido</option>
              <option value="PENDIENTE">Pendiente</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLogs"
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
            @click="loadLogs"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Sincronización -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Historial de Sincronización
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="logs.length > 0">
            {{ logs.length }} registros
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="logs.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="sync-alt" size="3x" />
          </div>
          <h4>Historial de Sincronización TDM</h4>
          <p>Haga clic en "Actualizar" para cargar el historial de sincronizaciones con el sistema TDM</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="logs.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron registros de sincronización con los criterios especificados</p>
        </div>

        <!-- Tabla de resultados -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Fecha/Hora</th>
                <th>Trámites Procesados</th>
                <th>Estado</th>
                <th>Duración</th>
                <th>Mensaje</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="log in logs"
                :key="log.id"
                @click="selectedRow = log"
                :class="{ 'table-row-selected': selectedRow === log }"
                class="row-hover"
              >
                <td><strong class="text-primary">{{ log.id }}</strong></td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDateTime(log.fecha_hora) }}
                  </small>
                </td>
                <td>
                  <span class="badge-purple">
                    {{ log.tramites_procesados || 0 }} trámites
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(log.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(log.estado)" />
                    {{ log.estado || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ log.duracion_segundos ? `${log.duracion_segundos}s` : 'N/A' }}
                  </small>
                </td>
                <td>{{ log.mensaje?.substring(0, 50) || 'N/A' }}{{ log.mensaje?.length > 50 ? '...' : '' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewLog(log)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      v-if="log.estado === 'FALLIDO'"
                      class="btn-municipal-warning btn-sm"
                      @click.stop="retrySync(log)"
                      title="Reintentar"
                      :disabled="syncing"
                    >
                      <font-awesome-icon icon="redo" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div v-if="logs.length > 0" class="pagination-controls">
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
            @change="changePageSize($event.target.value)"
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

    <!-- Modal de visualización de log -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de Sincronización #${selectedLog?.id}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedLog" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información de Sincronización
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedLog.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Fecha y Hora:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-info" />
                  {{ formatDateTime(selectedLog.fecha_hora) }}
                </td>
              </tr>
              <tr>
                <td class="label">Trámites Procesados:</td>
                <td>
                  <span class="badge-purple">{{ selectedLog.tramites_procesados || 0 }}</span>
                </td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(selectedLog.estado)">
                    <font-awesome-icon :icon="getEstadoIcon(selectedLog.estado)" />
                    {{ selectedLog.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Duración:</td>
                <td>{{ selectedLog.duracion_segundos ? `${selectedLog.duracion_segundos} segundos` : 'N/A' }}</td>
              </tr>
            </table>
          </div>
          <div class="detail-section full-width">
            <h6 class="section-title">
              <font-awesome-icon icon="file-alt" />
              Mensaje / Detalles
            </h6>
            <div class="log-message">
              <pre>{{ selectedLog.mensaje || 'Sin mensaje' }}</pre>
            </div>
            <div v-if="selectedLog.error_detalle" class="error-details">
              <h6 class="section-title text-danger">
                <font-awesome-icon icon="exclamation-triangle" />
                Detalles del Error
              </h6>
              <pre class="error-text">{{ selectedLog.error_detalle }}</pre>
            </div>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button
            v-if="selectedLog.estado === 'FALLIDO'"
            class="btn-municipal-warning"
            @click="retrySync(selectedLog); showViewModal = false"
            :disabled="syncing"
          >
            <font-awesome-icon icon="redo" />
            Reintentar Sincronización
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
      :componentName="'TDMConection'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Conexión TDM'"
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
const logs = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedLog = ref(null)
const showViewModal = ref(false)
const syncing = ref(false)
const connectionStatus = ref({
  connected: false,
  message: 'Verificando conexión...',
  last_check: null
})
const connectionStats = ref({
  exitosos: 0,
  fallidos: 0,
  pendientes: 0
})

// Filtros
const filters = ref({
  fechaInicio: '',
  fechaFin: '',
  estado: ''
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Métodos
const loadConnectionStatus = async () => {
  try {
    const startTime = performance.now()

    const response = await execute(
      'tdmconection_sp_get_connection_status',
      'padron_licencias',
      [],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]) {
      const status = response.result[0]
      connectionStatus.value = {
        connected: status.connected || false,
        message: status.message || 'Estado desconocido',
        last_check: status.last_check || new Date().toISOString()
      }

      if (status.stats) {
        connectionStats.value = status.stats
      }
      toast.value.duration = durationText
    }
  } catch (error) {
    connectionStatus.value = {
      connected: false,
      message: 'Error al verificar conexión',
      last_check: new Date().toISOString()
    }
  }
}

const loadLogs = async () => {
  showLoading('Cargando historial de sincronización...')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const startTime = performance.now()

    const response = await execute(
      'tdmconection_sp_get_sync_log',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' },
        { nombre: 'p_estado', valor: filters.value.estado || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      logs.value = response.result
      if (logs.value.length > 0) {
        totalRecords.value = parseInt(logs.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      toast.value.duration = durationText
      showToast('success', 'Historial cargado correctamente')
    } else {
      logs.value = []
      totalRecords.value = 0
      toast.value.duration = durationText
      showToast('error', 'Error al cargar historial')
    }
  } catch (error) {
    handleApiError(error)
    logs.value = []
    totalRecords.value = 0
  } finally {
    hideLoading()
  }
}

const searchLogs = () => {
  currentPage.value = 1
  loadLogs()
}

const clearFilters = () => {
  filters.value = {
    fechaInicio: '',
    fechaFin: '',
    estado: ''
  }
  logs.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    selectedRow.value = null
    loadLogs()
  }
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
  loadLogs()
}

const syncTramites = async () => {
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Iniciar sincronización?',
    text: 'Se sincronizarán los trámites con el sistema TDM',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, sincronizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  syncing.value = true
  showToast('info', 'Iniciando sincronización...')

  try {
    const startTime = performance.now()

    const response = await execute(
      'tdmconection_sp_sync_tramites',
      'padron_licencias',
      [],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Sincronización exitosa!',
        html: `
          <div class="swal-confirmation-text">
            <p><strong>Trámites procesados:</strong> ${response.result[0].tramites_procesados || 0}</p>
            <p><strong>Duración:</strong> ${response.result[0].duracion_segundos || 0} segundos</p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      toast.value.duration = durationText
      showToast('success', 'Sincronización completada exitosamente')
      loadLogs()
      loadConnectionStatus()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error en la sincronización',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo completar la sincronización',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    syncing.value = false
  }
}

const retrySync = async (log) => {
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Reintentar sincronización?',
    text: `Se reintentará la sincronización #${log.id}`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, reintentar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  await syncTramites()
}

const viewLog = (log) => {
  selectedLog.value = log
  showViewModal.value = true
}

// Utilidades
const getEstadoBadgeClass = (estado) => {
  const classes = {
    'EXITOSO': 'badge-success',
    'FALLIDO': 'badge-danger',
    'PENDIENTE': 'badge-warning'
  }
  return classes[estado] || 'badge-secondary'
}

const getEstadoIcon = (estado) => {
  const icons = {
    'EXITOSO': 'check-circle',
    'FALLIDO': 'times-circle',
    'PENDIENTE': 'clock'
  }
  return icons[estado] || 'info-circle'
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
      minute: '2-digit',
      second: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Referencia para el interval
let statusInterval = null

// Lifecycle
onMounted(() => {
  loadConnectionStatus()
  loadLogs()

  // Actualizar estado de conexión cada 30 segundos
  statusInterval = setInterval(loadConnectionStatus, 30000)
})

onBeforeUnmount(() => {
  if (statusInterval) {
    clearInterval(statusInterval)
  }
  showViewModal.value = false
})
</script>

