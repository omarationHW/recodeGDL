<template>
  <div class="main-layout">
    <AppHeader />
    <AppSidebar />

    <main class="main-content" :style="{ marginLeft: sidebarCollapsed ? '0' : sidebarWidth + 'px' }">
      <div class="content-wrapper">
        <div class="module-view">
          <div class="module-view-header">
            <div class="module-view-icon">
              <font-awesome-icon icon="file-alt" />
            </div>
            <div class="module-view-info">
              <h1>Otras Obligaciones</h1>
              <p>Sistema de gestión de otras obligaciones fiscales</p>
            </div>
          </div>

          <div class="module-view-content">
            <div class="quick-access-grid">
              <div class="quick-access-card">
                <div class="card-icon gestion">
                  <font-awesome-icon icon="folder-open" />
                </div>
                <h3>Gestión</h3>
                <p>Operaciones de gestión de obligaciones</p>
                <div class="card-links">
                  <router-link to="/otras-obligaciones/g-nuevos">Nuevos</router-link>
                  <router-link to="/otras-obligaciones/g-consulta">Consulta</router-link>
                  <router-link to="/otras-obligaciones/g-actualiza">Actualizar</router-link>
                  <router-link to="/otras-obligaciones/g-baja">Baja</router-link>
                  <router-link to="/otras-obligaciones/g-adeudos">Adeudos</router-link>
                </div>
              </div>

              <div class="quick-access-card">
                <div class="card-icon recaudadora">
                  <font-awesome-icon icon="hand-holding-usd" />
                </div>
                <h3>Recaudadora</h3>
                <p>Operaciones de recaudadora</p>
                <div class="card-links">
                  <router-link to="/otras-obligaciones/r-nuevos">Nuevos</router-link>
                  <router-link to="/otras-obligaciones/r-consulta">Consulta</router-link>
                  <router-link to="/otras-obligaciones/r-actualiza">Actualizar</router-link>
                  <router-link to="/otras-obligaciones/r-baja">Baja</router-link>
                  <router-link to="/otras-obligaciones/r-adeudos">Adeudos</router-link>
                </div>
              </div>

              <div class="quick-access-card">
                <div class="card-icon reportes">
                  <font-awesome-icon icon="chart-bar" />
                </div>
                <h3>Reportes</h3>
                <p>Reportes y estadísticas</p>
                <div class="card-links">
                  <router-link to="/otras-obligaciones/g-rep-padron">Padrón Gestión</router-link>
                  <router-link to="/otras-obligaciones/r-rep-padron">Padrón Recaudadora</router-link>
                  <router-link to="/otras-obligaciones/aux-rep">Auxiliares</router-link>
                  <router-link to="/otras-obligaciones/etiquetas">Etiquetas</router-link>
                </div>
              </div>

              <div class="quick-access-card">
                <div class="card-icon config">
                  <font-awesome-icon icon="cog" />
                </div>
                <h3>Configuración</h3>
                <p>Catálogos y configuración</p>
                <div class="card-links">
                  <router-link to="/otras-obligaciones/rubros">Rubros</router-link>
                  <router-link to="/otras-obligaciones/carga-cartera">Carga Cartera</router-link>
                  <router-link to="/otras-obligaciones/carga-valores">Carga Valores</router-link>
                  <router-link to="/otras-obligaciones/apremios">Apremios</router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <AppFooter />
  </div>

  <!-- Modal de Documentacion Tecnica -->
  <TechnicalDocsModal
    :show="showTechDocs"
    :componentName="'index'"
    :moduleName="'otras_obligaciones'"
    @close="closeTechDocs"
  />

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    @close="closeDocumentation"
    title="Ayuda - index"
  >
    <h3>index</h3>
    <p>Documentacion del modulo otras_obligaciones.</p>
  </DocumentationModal>
</template>

<script setup>
import { ref } from 'vue'
import AppHeader from '@/components/layout/AppHeader.vue'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { useSidebar } from '@/composables/useSidebar'

const { sidebarCollapsed, sidebarWidth } = useSidebar()

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
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
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
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

.quick-access-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.quick-access-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.quick-access-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.card-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.75rem;
  color: white;
  margin-bottom: 1rem;
}

.card-icon.gestion {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.card-icon.recaudadora {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.card-icon.reportes {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
}

.card-icon.config {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
}

.quick-access-card h3 {
  font-size: 1.25rem;
  color: #111827;
  margin-bottom: 0.5rem;
}

.quick-access-card p {
  color: #6b7280;
  font-size: 0.875rem;
  margin-bottom: 1rem;
}

.card-links {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.card-links a {
  color: #f59e0b;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  transition: color 0.2s;
  padding: 0.375rem 0;
}

.card-links a:hover {
  color: #d97706;
  text-decoration: underline;
}
</style>
