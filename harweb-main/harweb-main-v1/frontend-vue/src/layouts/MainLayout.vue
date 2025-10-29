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
            <i class="fas fa-chevron-right breadcrumb-sep"></i>
            <span class="breadcrumb-item">Dashboard</span>
          </div>
          <div class="current-time">
            <i class="fas fa-clock"></i>
            {{ currentTime }}
          </div>
        </div>

        <!-- Center Section - Empty (Search moved to Sidebar) -->
        <div class="header-center">
          <div class="header-spacer">
            <!-- La búsqueda ahora está en el Sidebar -->
          </div>
        </div>

        <!-- Right Section -->
        <div class="header-right">
          <!-- Notifications -->
          <button class="notification-btn">
            <i class="fas fa-bell"></i>
            <span class="notification-badge">3</span>
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
      currentTime: ''
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
  gap: 2rem;
}

/* Header Left */
.header-left {
  display: flex;
  align-items: center;
  gap: 2rem;
  height: 100%;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--slate-600);
  font-size: 0.9rem;
  height: 100%;
}

.breadcrumb-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.breadcrumb-sep {
  font-size: 0.75rem;
  color: var(--slate-400);
}

.current-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--slate-500);
  font-size: 0.875rem;
}

/* Header Center - Search */
.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
  max-width: 500px;
  margin: 0 auto;
}

.search-container {
  position: relative;
  width: 100%;
  max-width: 400px;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-input {
  width: 100%;
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  border: 2px solid #e2e8f0;
  border-radius: 25px;
  background: white;
  font-size: 0.875rem;
  outline: none;
  transition: all 0.3s ease;
}

.search-input:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
  background: #ffffff;
}

.search-active .search-input {
  border-radius: 12px 12px 0 0;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
}

.search-icon {
  position: absolute;
  left: 1rem;
  color: var(--slate-400);
  z-index: 2;
}

.search-input:focus + .search-icon {
  color: var(--municipal-primary);
}

.clear-search-btn {
  position: absolute;
  right: 0.75rem;
  background: none;
  border: none;
  color: var(--slate-400);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 50%;
  transition: all 0.2s ease;
  z-index: 2;
}

.clear-search-btn:hover {
  background: #f1f5f9;
  color: var(--slate-600);
}

/* Search Results Dropdown */
.search-results {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 2px solid var(--municipal-primary);
  border-top: none;
  border-radius: 0 0 12px 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-height: 400px;
  overflow-y: auto;
}

.no-results {
  padding: 2rem;
  text-align: center;
  color: var(--slate-500);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.no-results i {
  font-size: 2rem;
  color: var(--slate-400);
}

.results-header {
  padding: 0.75rem 1rem 0.5rem 1rem;
  border-bottom: 1px solid #e2e8f0;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--municipal-primary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.results-list {
  max-height: 320px;
  overflow-y: auto;
}

.search-result-item {
  display: flex;
  align-items: center;
  padding: 0.75rem 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border-bottom: 1px solid #f1f5f9;
}

.search-result-item:hover,
.search-result-item.highlighted {
  background: linear-gradient(135deg, #fef7ed 0%, #fed7aa 100%);
  border-left: 4px solid var(--municipal-primary);
  padding-left: calc(1rem - 4px);
}

.result-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--gov-primary-gold) 100%);
  color: white;
  border-radius: 8px;
  margin-right: 0.75rem;
  font-size: 0.875rem;
}

.result-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.result-title {
  font-weight: 600;
  color: var(--slate-800);
  font-size: 0.875rem;
  line-height: 1.2;
}

.result-subtitle {
  font-size: 0.75rem;
  color: var(--municipal-primary);
  margin-top: 0.125rem;
  font-weight: 500;
}

.result-path {
  font-size: 0.625rem;
  color: var(--slate-500);
  margin-top: 0.25rem;
  font-family: 'Courier New', monospace;
  background: #f8fafc;
  padding: 0.125rem 0.25rem;
  border-radius: 3px;
  display: inline-block;
}

.result-badge {
  margin-left: 0.5rem;
}

.new-badge {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
  font-size: 0.625rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.results-footer {
  padding: 0.75rem 1rem;
  text-align: center;
  font-size: 0.75rem;
  color: var(--slate-500);
  border-top: 1px solid #e2e8f0;
  background: #f8fafc;
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
  padding: 0.5rem;
  border-radius: 6px;
  color: var(--slate-600);
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
}

.notification-btn:hover {
  background: #f1f5f9;
}

.notification-badge {
  position: absolute;
  top: 0;
  right: 0;
  background: var(--gdl-red);
  color: white;
  border-radius: 10px;
  padding: 0.125rem 0.375rem;
  font-size: 0.75rem;
  font-weight: 600;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
    gap: 1rem;
  }

  .header-left .current-time {
    display: none;
  }

  .header-left {
    min-width: 120px;
  }

  .header-center {
    max-width: 200px;
    margin: 0;
  }

  .search-container {
    max-width: 200px;
  }

  .search-input {
    padding: 0.5rem 0.75rem 0.5rem 2rem;
    font-size: 0.8rem;
  }

  .search-icon {
    left: 0.75rem;
  }

  .clear-search-btn {
    right: 0.5rem;
  }

  .user-info {
    display: none;
  }

  .version-tag {
    display: none;
  }

  .breadcrumb-item span {
    display: none;
  }

  .breadcrumb-item i {
    margin-right: 0;
  }
}

@media (max-width: 480px) {
  .header-content {
    gap: 0.5rem;
  }

  .header-left {
    min-width: 60px;
  }

  .breadcrumb {
    font-size: 0.8rem;
  }

  .search-container {
    max-width: 150px;
  }

  .search-input {
    padding: 0.375rem 0.5rem 0.375rem 1.75rem;
    font-size: 0.75rem;
  }

  .search-icon {
    left: 0.5rem;
    font-size: 0.875rem;
  }
}
</style>