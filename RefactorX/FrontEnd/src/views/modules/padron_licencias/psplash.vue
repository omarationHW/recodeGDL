<template>
  <div class="module-view splash-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
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
      'sp_psplash_get_user_info',
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
      'sp_psplash_get_announcements',
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
      'sp_psplash_get_stats',
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
    'INFORMATIVO': 'badge-purple',
    'IMPORTANTE': 'badge-warning',
    'URGENTE': 'badge-danger',
    'MANTENIMIENTO': 'badge-secondary'
  }
  return classes[tipo] || 'badge-purple'
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
  } catch {
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

