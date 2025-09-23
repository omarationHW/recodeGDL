<template>
  <div class="app-layout">
    <!-- Sidebar -->
    <Sidebar @toggle="handleSidebarToggle" />
    
    <!-- Header -->
    <header class="app-header" :class="{ 'header-collapsed': sidebarCollapsed }">
      <div class="header-content">
        <!-- Left Section -->
        <div class="header-left">
          <div class="breadcrumb">
            <span class="breadcrumb-item">
              <i class="fas fa-home"></i>
              Sistema Municipal
            </span>
            <template v-for="(crumb, index) in breadcrumbs" :key="index">
              <i class="fas fa-chevron-right breadcrumb-sep"></i>
              <span class="breadcrumb-item" :class="{ 'active': index === breadcrumbs.length - 1 }">
                {{ crumb }}
              </span>
            </template>
          </div>
        </div>

        <!-- Center Section - Date/Time -->
        <div class="header-center">
          <div class="current-time">
            <i class="fas fa-clock me-2"></i>
            <span>{{ currentTime }}</span>
          </div>
        </div>
        
        <!-- Right Section -->
        <div class="header-right">
          <!-- Notifications -->
          <button class="notification-btn" title="Notificaciones">
            <i class="fas fa-bell"></i>
            <span class="notification-badge" v-if="notificationCount > 0">{{ notificationCount }}</span>
          </button>
          
          <!-- User Profile -->
          <div class="user-profile">
            <div class="user-avatar">
              <img src="@/assets/logo/Gdl Logo.png" alt="Usuario" class="avatar" />
            </div>
            <div class="user-info">
              <div class="user-name">ElChampion</div>
              <div class="user-role">Administrador</div>
            </div>
            <button class="profile-btn">
              <i class="fas fa-chevron-down"></i>
            </button>
          </div>
          
          <!-- Version -->
          <div class="version-tag">
            <i class="fas fa-code-branch"></i>
            v1.0.570
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="main-content" :class="{ 'main-collapsed': sidebarCollapsed }">
      <div class="content-wrapper">
        <slot />
      </div>
      <!-- Footer dentro del main-content pero con ancho completo -->
      <div class="footer-container">
        <Footer />
      </div>
    </main>
  </div>
</template>

<script>
import Sidebar from '../components/Sidebar.vue'
import Footer from '../components/Footer.vue'

export default {
  name: 'MainLayout',
  components: {
    Sidebar,
    Footer
  },
  data() {
    return {
      sidebarCollapsed: false,
      currentTime: '',
      notificationCount: 3
    }
  },
  computed: {
    breadcrumbs() {
      const route = this.$route
      const breadcrumbs = []

      // Agregar breadcrumbs basados en la ruta actual
      if (route.name === 'Dashboard') {
        breadcrumbs.push('Dashboard')
      } else if (route.path.includes('/modules/')) {
        breadcrumbs.push('Módulos')

        // Detectar el módulo específico
        if (route.path.includes('/licencias')) {
          breadcrumbs.push('Licencias')

          // Si hay un submódulo específico
          const submodule = route.params.submodule || route.query.submodule
          if (submodule) {
            breadcrumbs.push(this.formatModuleName(submodule))
          }
        } else if (route.path.includes('/aseo')) {
          breadcrumbs.push('Aseo')
        } else if (route.path.includes('/mercados')) {
          breadcrumbs.push('Mercados')
        } else if (route.path.includes('/cementerios')) {
          breadcrumbs.push('Cementerios')
        } else if (route.path.includes('/estacionamientos')) {
          breadcrumbs.push('Estacionamientos')
        } else if (route.path.includes('/convenios')) {
          breadcrumbs.push('Convenios')
        } else if (route.path.includes('/apremios')) {
          breadcrumbs.push('Apremios')
        } else if (route.path.includes('/tramite-trunk')) {
          breadcrumbs.push('Trámite Trunk')
        } else if (route.path.includes('/otras-oblig')) {
          breadcrumbs.push('Otras Obligaciones')
        } else if (route.path.includes('/recaudadora')) {
          breadcrumbs.push('Recaudadora')
        }
      }

      return breadcrumbs
    }
  },
  mounted() {
    this.updateTime()
    setInterval(this.updateTime, 60000) // Update every minute
  },
  methods: {
    handleSidebarToggle(collapsed) {
      this.sidebarCollapsed = collapsed
    },
    updateTime() {
      this.currentTime = new Date().toLocaleString('es-MX', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    formatModuleName(name) {
      // Convertir nombres de submódulos a formato legible
      return name
        .replace(/([A-Z])/g, ' $1')
        .replace(/^./, str => str.toUpperCase())
        .replace(/frm$/i, '')
        .trim()
    }
  }
}
</script>

<style scoped>
/* Simple App Layout */
.app-layout {
  display: flex;
  min-height: 100vh;
  background: #f8fafc;
  position: relative;
}

/* Header */
.app-header {
  position: fixed;
  top: 0;
  left: 280px;
  right: 0;
  height: 70px;
  background: white;
  border-bottom: 1px solid #e2e8f0;
  z-index: 100;
  transition: left 0.3s ease;
}

.header-collapsed {
  left: 80px;
}

.header-content {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 2rem;
  position: relative;
}

/* Header Left */
.header-left {
  display: flex;
  align-items: center;
  height: 100%;
  flex: 1;
}

/* Header Center */
.header-center {
  display: flex;
  align-items: center;
  justify-content: center;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  height: 100%;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--slate-600);
  font-size: 0.9rem;
  height: 100%;
  flex-wrap: wrap;
}

.breadcrumb-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  white-space: nowrap;
}

.breadcrumb-item.active {
  color: var(--municipal-blue);
  font-weight: 600;
}

.breadcrumb-sep {
  font-size: 0.75rem;
  color: var(--slate-400);
  margin: 0 0.25rem;
}

.current-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--slate-600);
  font-size: 0.875rem;
  font-weight: 500;
  background: rgba(59, 130, 246, 0.1);
  padding: 0.5rem 1rem;
  border-radius: 8px;
  border: 1px solid rgba(59, 130, 246, 0.2);
}

/* Header Right */
.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
  height: 100%;
}

.notification-btn {
  position: relative;
  background: none;
  border: none;
  padding: 0.75rem;
  border-radius: 8px;
  color: var(--slate-600);
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  width: 44px;
  height: 44px;
}

.notification-btn:hover {
  background: rgba(59, 130, 246, 0.1);
  color: var(--municipal-blue);
  transform: scale(1.05);
}

.notification-btn:active {
  transform: scale(0.95);
}

.notification-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #ef4444;
  color: white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.7rem;
  font-weight: 700;
  border: 2px solid white;
  box-shadow: 0 2px 6px rgba(239, 68, 68, 0.3);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7);
  }
  70% {
    box-shadow: 0 0 0 6px rgba(239, 68, 68, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(239, 68, 68, 0);
  }
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.user-profile:hover {
  background: #f8fafc;
}

.user-avatar {
  position: relative;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e2e8f0;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--slate-800);
}

.user-role {
  font-size: 0.75rem;
  color: var(--slate-500);
}

.profile-btn {
  background: none;
  border: none;
  color: var(--slate-400);
  cursor: pointer;
  padding: 0.25rem;
}

.version-tag {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  background: var(--municipal-blue);
  color: white;
  padding: 0.375rem 0.75rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  height: fit-content;
  align-self: center;
}

/* Main Content */
.main-content {
  flex: 1;
  margin-left: 280px;
  margin-top: 70px;
  padding: 0;
  background: transparent;
  transition: margin-left 0.3s ease;
  display: flex;
  flex-direction: column;
  min-height: calc(100vh - 70px);
}

.content-wrapper {
  flex: 1;
}

.main-collapsed {
  margin-left: 80px;
}

/* Footer Container - Posición relativa que se extiende fuera del margen */
.footer-container {
  position: relative;
  margin-left: -280px;
  margin-right: 0;
  width: 100vw;
  z-index: 1100;
  transition: margin-left 0.3s ease;
}

.main-collapsed .footer-container {
  margin-left: -80px;
}

/* Responsive */
@media (max-width: 768px) {
  .app-header {
    left: 0;
  }

  .main-content {
    margin-left: 0;
  }

  .footer-container {
    margin-left: 0;
  }

  .header-content {
    padding: 0 1rem;
  }

  .header-center {
    position: static;
    transform: none;
    order: 2;
    flex: 1;
    justify-content: flex-end;
  }

  .header-center .current-time {
    display: none;
  }

  .header-left {
    flex: 1;
  }

  .header-right {
    gap: 0.5rem;
  }

  .user-info {
    display: none;
  }

  .breadcrumb {
    font-size: 0.8rem;
    gap: 0.25rem;
  }

  .breadcrumb-item {
    gap: 0.125rem;
  }
}
</style>