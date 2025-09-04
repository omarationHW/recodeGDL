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
      <slot />
    </main>
  </div>
</template>

<script>
import Sidebar from '../components/Sidebar.vue'

export default {
  name: 'MainLayout',
  components: {
    Sidebar
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
}

.main-collapsed {
  margin-left: 80px;
}

/* Responsive */
@media (max-width: 768px) {
  .app-header {
    left: 0;
  }
  
  .main-content {
    margin-left: 0;
  }
  
  .header-content {
    padding: 0 1rem;
  }
  
  .header-left .current-time {
    display: none;
  }
  
  .user-info {
    display: none;
  }
}
</style>