<template>
  <div class="module-view splash-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="rocket" />
      </div>
      <div class="module-view-info">
        <h1>Bienvenida</h1>
        <p>Padrón de Licencias - Pantalla de Bienvenida</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Splash screen principal -->
    <div class="splash-container">
      <div class="splash-header">
        <div class="splash-logo">
          <font-awesome-icon icon="building" size="4x" />
        </div>
        <h2 class="splash-title">Sistema de Padrón de Licencias</h2>
        <h3 class="splash-subtitle">Gobierno Municipal de Guadalajara</h3>
      </div>

      <div class="welcome-message">
        <h4>
          <font-awesome-icon icon="user" />
          ¡Bienvenido, {{ userInfo.nombre || 'Usuario' }}!
        </h4>
        <p class="user-role">{{ userInfo.rol || 'Acceso al Sistema' }}</p>
        <p class="current-date">
          <font-awesome-icon icon="calendar" />
          {{ formatCurrentDate() }}
        </p>
      </div>

      <!-- Estadísticas rápidas -->
      <div class="quick-stats">
        <div class="stat-card">
          <div class="stat-icon stat-primary">
            <font-awesome-icon icon="file-alt" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.licencias || 0 }}</div>
            <div class="stat-label">Licencias Activas</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon stat-info">
            <font-awesome-icon icon="sync-alt" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.procesos || 0 }}</div>
            <div class="stat-label">Procesos en Curso</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon stat-warning">
            <font-awesome-icon icon="clock" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.pendientes || 0 }}</div>
            <div class="stat-label">Trámites Pendientes</div>
          </div>
        </div>
      </div>

      <!-- Anuncios del sistema -->
      <div class="announcements-section" v-if="announcements.length > 0">
        <h5>
          <font-awesome-icon icon="bullhorn" />
          Anuncios del Sistema
        </h5>
        <div class="announcements-carousel">
          <div class="announcement-item" v-for="(announcement, index) in announcements" :key="index">
            <div class="announcement-header">
              <span class="announcement-badge" :class="getAnnouncementBadgeClass(announcement.tipo)">
                <font-awesome-icon :icon="getAnnouncementIcon(announcement.tipo)" />
                {{ announcement.tipo }}
              </span>
              <span class="announcement-date">
                <font-awesome-icon icon="calendar" />
                {{ formatDate(announcement.fecha) }}
              </span>
            </div>
            <h6 class="announcement-title">{{ announcement.titulo }}</h6>
            <p class="announcement-message">{{ announcement.mensaje }}</p>
          </div>
        </div>
      </div>

      <!-- Acciones rápidas -->
      <div class="quick-actions">
        <h5>
          <font-awesome-icon icon="bolt" />
          Acciones Rápidas
        </h5>
        <div class="action-buttons">
          <button class="action-btn action-primary" @click="goToConsulta">
            <font-awesome-icon icon="search" />
            <span>Consultar Licencias</span>
          </button>
          <button class="action-btn action-success" @click="goToNueva">
            <font-awesome-icon icon="plus" />
            <span>Nueva Licencia</span>
          </button>
          <button class="action-btn action-info" @click="goToReportes">
            <font-awesome-icon icon="chart-bar" />
            <span>Reportes</span>
          </button>
          <button class="action-btn action-warning" @click="goToConfiguracion">
            <font-awesome-icon icon="cog" />
            <span>Configuración</span>
          </button>
        </div>
      </div>

      <!-- Auto-redirect countdown -->
      <div class="auto-redirect" v-if="autoRedirect && countdown > 0">
        <p>
          <font-awesome-icon icon="info-circle" />
          Redirigiendo automáticamente en {{ countdown }} segundos...
        </p>
        <button class="btn-municipal-secondary btn-sm" @click="cancelAutoRedirect">
          Cancelar
        </button>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando información del sistema...</p>
      </div>
    </div>

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
      :componentName="'psplash'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useRouter } from 'vue-router'

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
const router = useRouter()

// Estado
const userInfo = ref({
  nombre: '',
  rol: '',
  usuario: ''
})
const stats = ref({
  licencias: 0,
  procesos: 0,
  pendientes: 0
})
const announcements = ref([])
const autoRedirect = ref(false)
const countdown = ref(5)
let countdownInterval = null

// Métodos
const loadUserInfo = async () => {
  try {
    const response = await execute(
      'psplash_sp_get_user_info',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      userInfo.value = response.result[0]
    }
  } catch (error) {
    handleApiError(error)
  }
}

const loadAnnouncements = async () => {
  try {
    const response = await execute(
      'psplash_sp_get_announcements',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      announcements.value = response.result
    }
  } catch (error) {
    handleApiError(error)
  }
}

const loadStats = async () => {
  setLoading(true, 'Cargando estadísticas...')

  try {
    const response = await execute(
      'psplash_sp_get_stats',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      stats.value = response.result[0]
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const loadAllData = async () => {
  await Promise.all([
    loadUserInfo(),
    loadAnnouncements(),
    loadStats()
  ])
}

const startAutoRedirect = () => {
  if (autoRedirect.value) {
    countdownInterval = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        clearInterval(countdownInterval)
        goToConsulta()
      }
    }, 1000)
  }
}

const cancelAutoRedirect = () => {
  autoRedirect.value = false
  if (countdownInterval) {
    clearInterval(countdownInterval)
  }
}

// Navegación
const goToConsulta = () => {
  showToast('info', 'Redirigiendo a Consulta de Licencias...')
  // router.push('/licencias/consulta')
}

const goToNueva = () => {
  showToast('info', 'Redirigiendo a Nueva Licencia...')
  // router.push('/licencias/nueva')
}

const goToReportes = () => {
  showToast('info', 'Redirigiendo a Reportes...')
  // router.push('/licencias/reportes')
}

const goToConfiguracion = () => {
  showToast('info', 'Redirigiendo a Configuración...')
  // router.push('/licencias/configuracion')
}

// Utilidades
const getAnnouncementBadgeClass = (tipo) => {
  const classes = {
    'INFORMATIVO': 'badge-info',
    'IMPORTANTE': 'badge-warning',
    'URGENTE': 'badge-danger',
    'MANTENIMIENTO': 'badge-secondary'
  }
  return classes[tipo] || 'badge-info'
}

const getAnnouncementIcon = (tipo) => {
  const icons = {
    'INFORMATIVO': 'info-circle',
    'IMPORTANTE': 'exclamation-circle',
    'URGENTE': 'exclamation-triangle',
    'MANTENIMIENTO': 'tools'
  }
  return icons[tipo] || 'info-circle'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatCurrentDate = () => {
  const date = new Date()
  return date.toLocaleDateString('es-ES', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Lifecycle
onMounted(() => {
  loadAllData()
  // Uncomment to enable auto-redirect
  // autoRedirect.value = true
  // startAutoRedirect()
})

onBeforeUnmount(() => {
  if (countdownInterval) {
    clearInterval(countdownInterval)
  }
})
</script>

<style scoped>
.splash-view {
  min-height: 100vh;
}

.splash-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.splash-header {
  text-align: center;
  padding: 3rem 0;
  background: linear-gradient(135deg, #ea8215 0%, #c46a0f 100%);
  color: white;
  border-radius: 12px;
  margin-bottom: 2rem;
  box-shadow: 0 4px 12px rgba(234, 130, 21, 0.3);
}

.splash-logo {
  margin-bottom: 1.5rem;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.splash-title {
  font-size: 2.5rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.splash-subtitle {
  font-size: 1.5rem;
  font-weight: 300;
  opacity: 0.95;
}

.welcome-message {
  text-align: center;
  padding: 2rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.welcome-message h4 {
  color: #ea8215;
  font-size: 1.75rem;
  margin-bottom: 0.5rem;
}

.user-role {
  color: #6c757d;
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
}

.current-date {
  color: #495057;
  font-size: 0.95rem;
}

.quick-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  font-size: 3rem;
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  margin-right: 1.5rem;
}

.stat-primary {
  background: linear-gradient(135deg, #ea8215 0%, #ff9933 100%);
  color: white;
}

.stat-info {
  background: linear-gradient(135deg, #17a2b8 0%, #20c0db 100%);
  color: white;
}

.stat-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ffcd38 100%);
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: bold;
  color: #333;
  line-height: 1;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.95rem;
  color: #6c757d;
}

.announcements-section {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.announcements-section h5 {
  color: #495057;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #ea8215;
}

.announcements-carousel {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.announcement-item {
  padding: 1rem;
  background: #f8f9fa;
  border-left: 4px solid #ea8215;
  border-radius: 4px;
}

.announcement-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.announcement-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: bold;
}

.announcement-date {
  font-size: 0.85rem;
  color: #6c757d;
}

.announcement-title {
  font-weight: bold;
  color: #333;
  margin-bottom: 0.5rem;
}

.announcement-message {
  color: #495057;
  margin: 0;
}

.quick-actions {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.quick-actions h5 {
  color: #495057;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #ea8215;
}

.action-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 1.5rem;
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.action-btn svg {
  font-size: 2rem;
}

.action-btn:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.25);
}

.action-primary {
  background: linear-gradient(135deg, #ea8215 0%, #ff9933 100%);
}

.action-success {
  background: linear-gradient(135deg, #28a745 0%, #34ce57 100%);
}

.action-info {
  background: linear-gradient(135deg, #17a2b8 0%, #20c0db 100%);
}

.action-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ffcd38 100%);
}

.auto-redirect {
  text-align: center;
  padding: 1rem;
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 8px;
  margin-top: 2rem;
}

.auto-redirect p {
  margin: 0 0 0.5rem 0;
  color: #856404;
  font-weight: 500;
}
</style>
