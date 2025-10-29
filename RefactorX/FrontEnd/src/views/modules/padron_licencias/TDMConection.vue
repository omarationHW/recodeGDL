<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="sync-alt" />
      </div>
      <div class="module-view-info">
        <h1>Conexión TDM</h1>
        <p>Padrón de Licencias - Conexión con Trámites Digitales México</p></div>
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
          @click="syncTramites"
          :disabled="loading || syncing"
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
            @click="loadLogs"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Sincronización -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Historial de Sincronización
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
              <tr v-for="log in logs" :key="log.id" class="row-hover">
                <td><strong class="text-primary">{{ log.id }}</strong></td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDateTime(log.fecha_hora) }}
                  </small>
                </td>
                <td>
                  <span class="badge-info">
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
                      @click="viewLog(log)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      v-if="log.estado === 'FALLIDO'"
                      class="btn-municipal-warning btn-sm"
                      @click="retrySync(log)"
                      title="Reintentar"
                      :disabled="syncing"
                    >
                      <font-awesome-icon icon="redo" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="logs.length === 0 && !loading">
                <td colspan="7" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron registros de sincronización</p>
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
    <div v-if="loading && logs.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando historial de sincronización...</p>
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
                  <span class="badge-info">{{ selectedLog.tramites_procesados || 0 }}</span>
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
      :componentName="'TDMConection'"
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
const logs = ref([])
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
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const loadConnectionStatus = async () => {
  try {
    const response = await execute(
      'TDMConection_sp_get_connection_status',
      'padron_licencias',
      [],
      'guadalajara'
    )

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
  setLoading(true, 'Cargando historial de sincronización...')

  try {
    const response = await execute(
      'TDMConection_sp_get_sync_log',
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

    if (response && response.result) {
      logs.value = response.result
      if (logs.value.length > 0) {
        totalRecords.value = parseInt(logs.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Historial cargado correctamente')
    } else {
      logs.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar historial')
    }
  } catch (error) {
    handleApiError(error)
    logs.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
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
  currentPage.value = 1
  loadLogs()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadLogs()
  }
}

const changePageSize = () => {
  currentPage.value = 1
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
    const response = await execute(
      'TDMConection_sp_sync_tramites',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Sincronización exitosa!',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p><strong>Trámites procesados:</strong> ${response.result[0].tramites_procesados || 0}</p>
            <p><strong>Duración:</strong> ${response.result[0].duracion_segundos || 0} segundos</p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

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

// Lifecycle
onMounted(() => {
  loadConnectionStatus()
  loadLogs()

  // Actualizar estado de conexión cada 30 segundos
  const statusInterval = setInterval(loadConnectionStatus, 30000)

  onBeforeUnmount(() => {
    clearInterval(statusInterval)
    showViewModal.value = false
  })
})
</script>

<style scoped>
.connection-status-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.connection-status-card {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  border-radius: 8px;
  border: 2px solid;
}

.connection-status-card.connected {
  background: #d4edda;
  border-color: #28a745;
  color: #155724;
}

.connection-status-card.disconnected {
  background: #f8d7da;
  border-color: #dc3545;
  color: #721c24;
}

.status-icon {
  font-size: 3rem;
  margin-right: 1.5rem;
}

.status-content h6 {
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: bold;
}

.status-content p {
  margin: 0 0 0.25rem 0;
}

.status-content small {
  opacity: 0.8;
}

.connection-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.stat-item {
  text-align: center;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stat-item svg {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 2rem;
  font-weight: bold;
  color: #333;
  margin: 0.5rem 0;
}

.stat-label {
  font-size: 0.875rem;
  color: #6c757d;
}

.log-message,
.error-details {
  margin-top: 1rem;
}

.log-message pre,
.error-text {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 0.875rem;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.error-text {
  background: #f8d7da;
  color: #721c24;
}
</style>
