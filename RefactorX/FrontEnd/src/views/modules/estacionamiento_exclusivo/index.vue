<template>
  <div class="main-layout">
    <AppHeader />
    <AppSidebar />

    <main class="main-content" :style="{ marginLeft: sidebarCollapsed ? '0' : sidebarWidth + 'px' }">
      <div class="content-wrapper">
        <div class="module-view">
          <div class="module-view-header">
            <div class="module-view-icon">
              <font-awesome-icon icon="parking" />
            </div>
            <div class="module-view-info">
              <h1>Estacionamiento Exclusivo</h1>
              <p>Gestión de estacionamientos exclusivos y apremios</p>
            </div>
          </div>

          <div class="module-view-content">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="list" /> Operaciones Principales</h5>
              </div>
              <div class="municipal-card-body">
                <div class="button-grid">
                  <router-link :to="{ name: 'estacionamiento-exclusivo-expedientes' }" class="btn-municipal-primary">
                    <font-awesome-icon icon="folder-open" />
                    Expedientes
                  </router-link>
                  <router-link :to="{ name: 'estacionamiento-exclusivo-notificaciones' }" class="btn-municipal-primary">
                    <font-awesome-icon icon="bell" />
                    Notificaciones
                  </router-link>
                  <router-link :to="{ name: 'estacionamiento-exclusivo-actuaciones' }" class="btn-municipal-primary">
                    <font-awesome-icon icon="tasks" />
                    Actuaciones
                  </router-link>
                  <router-link :to="{ name: 'estacionamiento-exclusivo-pagos' }" class="btn-municipal-primary">
                    <font-awesome-icon icon="dollar-sign" />
                    Pagos
                  </router-link>
                  <router-link :to="{ name: 'estacionamiento-exclusivo-reportes' }" class="btn-municipal-primary">
                    <font-awesome-icon icon="chart-bar" />
                    Reportes
                  </router-link>
                  <router-link :to="{ name: 'estacionamiento-exclusivo-fases' }" class="btn-municipal-primary">
                    <font-awesome-icon icon="stream" />
                    Control de Fases
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <AppFooter />
  </div>
</template>

<script setup>
import AppHeader from '@/components/layout/AppHeader.vue'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
import { useSidebar } from '@/composables/useSidebar'

const { sidebarCollapsed, sidebarWidth } = useSidebar()
</script>

<style scoped>
.main-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
}

.main-content {
  flex: 1;
  width: 100%;
  margin: 0;
  padding: 0;
  transition: margin-left 0.3s ease;
  margin-top: 60px;
}

.content-wrapper {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
}

.sidebar-collapsed .main-content {
  margin-left: 0 !important;
}

.module-view {
  padding: 2rem;
  min-height: calc(100vh - 120px);
  background: #f5f7fa;
}

.module-view-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid #e2e8f0;
}

.module-view-icon {
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-radius: 12px;
  color: white;
  font-size: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.module-view-info h1 {
  margin: 0;
  color: #1e293b;
  font-size: 2rem;
  font-weight: 700;
}

.module-view-info p {
  margin: 0.5rem 0 0 0;
  color: #64748b;
  font-size: 1.1rem;
}

.module-view-content {
  padding: 1rem 0;
}

.municipal-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.municipal-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
  background: #f8fafc;
}

.municipal-card-header h5 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1e293b;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.municipal-card-body {
  padding: 2rem;
}

.button-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.btn-municipal-primary {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 500;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(59, 130, 246, 0.2);
}

.btn-municipal-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3);
}
</style>
