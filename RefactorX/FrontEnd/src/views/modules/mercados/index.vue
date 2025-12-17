<template>
  <div class="main-layout" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
    <AppHeader />
    <AppSidebar />
    <main
      class="main-content"
      :style="{ marginLeft: sidebarCollapsed ? '0' : sidebarWidth + 'px' }"
    >
      <div class="content-wrapper">
        <div class="module-view">
          <div class="module-view-header">
            <div class="module-view-icon">
              <font-awesome-icon icon="store" />
            </div>
            <div class="module-view-info">
              <h1>Módulo de Mercados</h1>
              <p class="maintenance-message">
                <font-awesome-icon icon="tools" />
                En mantenimiento - Temporalmente deshabilitado
              </p>
            </div>
          </div>

          <div class="module-view-content">
            <div class="maintenance-card">
              <div class="maintenance-icon">
                <font-awesome-icon icon="wrench" size="3x" />
              </div>
              <h2>Sistema en Mantenimiento</h2>
              <p>El módulo de Mercados está temporalmente deshabilitado mientras se realizan mejoras y actualizaciones.</p>
              <p>Puede explorar las opciones disponibles en el menú lateral.</p>
              <div class="maintenance-info">
                <font-awesome-icon icon="info-circle" />
                <span>Por favor, contacte al administrador del sistema para más información.</span>
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
}

.module-view-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid var(--slate-200);
}

.module-view-icon {
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--gradient-municipal);
  border-radius: var(--radius-lg);
  color: white;
  font-size: 2rem;
  box-shadow: var(--shadow-md);
}

.module-view-info h1 {
  margin: 0;
  color: var(--municipal-primary);
  font-size: 2rem;
  font-weight: var(--font-weight-bold);
}

.maintenance-message {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--slate-600);
  font-size: 1.1rem;
  margin: 0.5rem 0 0 0;
}

.module-view-content {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 3rem 0;
}

.maintenance-card {
  background: white;
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-lg);
  padding: 3rem;
  max-width: 600px;
  text-align: center;
}

.maintenance-icon {
  color: var(--municipal-primary);
  margin-bottom: 1.5rem;
}

.maintenance-card h2 {
  color: var(--slate-800);
  font-size: 1.75rem;
  font-weight: var(--font-weight-bold);
  margin-bottom: 1rem;
}

.maintenance-card p {
  color: var(--slate-600);
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.maintenance-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  justify-content: center;
  margin-top: 2rem;
  padding: 1rem;
  background: rgba(234, 130, 21, 0.1);
  border-radius: var(--radius-md);
  color: var(--municipal-primary);
  font-weight: var(--font-weight-medium);
}
</style>
