<template>
  <div class="main-layout">
    <AppHeader />
    <AppSidebar />

    <main class="main-content" :style="{ marginLeft: sidebarCollapsed ? '0' : sidebarWidth + 'px' }">
      <div class="content-wrapper">
        <div class="module-view">
          <!-- Header del módulo -->
          <div class="module-view-header">
            <div class="module-view-icon">
              <font-awesome-icon icon="cross" />
            </div>
            <div class="module-view-info">
              <h1>Módulo de Cementerios</h1>
              <p>Sistema de Gestión de Cementerios Municipales</p>
            </div>
          </div>

          <div class="module-view-content">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5>Bienvenido al Sistema de Cementerios</h5>
              </div>
              <div class="municipal-card-body">
                <h3>Funciones Principales</h3>
                <p>Desde este módulo puede administrar:</p>
                <ul class="features-list">
                  <li>
                    <font-awesome-icon icon="building" class="feature-icon" />
                    <span>Catálogo de Cementerios</span>
                  </li>
                  <li>
                    <font-awesome-icon icon="cross" class="feature-icon" />
                    <span>Gestión de Fosas</span>
                  </li>
                  <li>
                    <font-awesome-icon icon="file-contract" class="feature-icon" />
                    <span>Registro de Títulos</span>
                  </li>
                  <li>
                    <font-awesome-icon icon="dollar-sign" class="feature-icon" />
                    <span>Control de Pagos</span>
                  </li>
                  <li>
                    <font-awesome-icon icon="chart-bar" class="feature-icon" />
                    <span>Reportes y Estadísticas</span>
                  </li>
                </ul>

                <div class="mt-4">
                  <h4>Acceso Rápido</h4>
                  <div class="quick-links">
                    <router-link to="/cementerios/abcementer" class="quick-link-card">
                      <font-awesome-icon icon="cross" />
                      <span>Catálogo de Cementerios</span>
                    </router-link>
                  </div>
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
  margin-top: 60px; /* Altura del header */
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
  background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
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
}

.municipal-card-body {
  padding: 2rem;
}

.municipal-card-body h3 {
  margin: 0 0 0.5rem 0;
  color: #1e293b;
  font-size: 1.25rem;
  font-weight: 600;
}

.municipal-card-body p {
  margin: 0 0 1rem 0;
  color: #475569;
  line-height: 1.6;
}

.features-list {
  list-style: none;
  padding: 0;
  margin: 1rem 0;
}

.features-list li {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 0;
  color: #475569;
  font-size: 1rem;
  border-bottom: 1px solid #f1f5f9;
}

.features-list li:last-child {
  border-bottom: none;
}

.feature-icon {
  color: #8b5cf6;
  font-size: 1.25rem;
  width: 24px;
}

.mt-4 {
  margin-top: 2rem;
}

.mt-4 h4 {
  margin: 0 0 1rem 0;
  color: #1e293b;
  font-size: 1.125rem;
  font-weight: 600;
}

.quick-links {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
}

.quick-link-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem 1.5rem;
  background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
  border-radius: 8px;
  color: white;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(139, 92, 246, 0.2);
}

.quick-link-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(139, 92, 246, 0.3);
}

.quick-link-card svg {
  font-size: 1.5rem;
}
</style>
