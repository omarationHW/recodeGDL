<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gears" /></div>
      <div class="module-view-info">
        <h1>Administracion — Estacionamientos Publicos</h1>
        <p>Configuracion y control del modulo</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Informacion -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="info-circle" /></div>
          <div class="section-title-group">
            <h3>Panel de Administracion</h3>
            <span class="section-subtitle">Configuracion general del modulo</span>
          </div>
        </div>
        <div class="section-body">
          <div class="admin-info-grid">
            <div class="admin-card">
              <div class="admin-card-icon"><font-awesome-icon icon="database" /></div>
              <div class="admin-card-content">
                <h4>Base de Datos</h4>
                <p>{{ BASE_DB }}</p>
              </div>
            </div>
            <div class="admin-card">
              <div class="admin-card-icon"><font-awesome-icon icon="layer-group" /></div>
              <div class="admin-card-content">
                <h4>Schema</h4>
                <p>{{ SCHEMA }}</p>
              </div>
            </div>
            <div class="admin-card">
              <div class="admin-card-icon"><font-awesome-icon icon="code-branch" /></div>
              <div class="admin-card-content">
                <h4>Version</h4>
                <p>Vue 3 + Composition API</p>
              </div>
            </div>
          </div>

          <div class="admin-notice">
            <font-awesome-icon icon="lightbulb" class="notice-icon" />
            <div class="notice-content">
              <strong>Proxima Integracion</strong>
              <p>Este panel se conectara con stored procedures de administracion para gestion de parametros, configuracion de recargos y mantenimiento general del modulo.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Acciones Rapidas -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="bolt" /></div>
          <div class="section-title-group">
            <h3>Acciones Rapidas</h3>
            <span class="section-subtitle">Operaciones de administracion</span>
          </div>
        </div>
        <div class="section-body">
          <div class="quick-actions-grid">
            <button class="quick-action-btn" @click="showToast('info', 'Funcion en desarrollo')">
              <font-awesome-icon icon="sync-alt" class="action-icon" />
              <span>Actualizar Cache</span>
            </button>
            <button class="quick-action-btn" @click="showToast('info', 'Funcion en desarrollo')">
              <font-awesome-icon icon="broom" class="action-icon" />
              <span>Limpiar Temporales</span>
            </button>
            <button class="quick-action-btn" @click="showToast('info', 'Funcion en desarrollo')">
              <font-awesome-icon icon="file-export" class="action-icon" />
              <span>Exportar Config</span>
            </button>
            <button class="quick-action-btn" @click="showToast('info', 'Funcion en desarrollo')">
              <font-awesome-icon icon="chart-line" class="action-icon" />
              <span>Ver Estadisticas</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - AdminPublicos">
      <h3>Panel de Administracion</h3>
      <p>Este modulo permite configurar parametros generales del sistema de estacionamientos publicos.</p>
      <h4>Funciones Disponibles:</h4>
      <ul>
        <li><strong>Actualizar Cache:</strong> Refresca datos almacenados en cache</li>
        <li><strong>Limpiar Temporales:</strong> Elimina archivos temporales del sistema</li>
        <li><strong>Exportar Config:</strong> Descarga la configuracion actual</li>
        <li><strong>Ver Estadisticas:</strong> Muestra metricas de uso del modulo</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'AdminPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { toast, showToast, hideToast, getToastIcon } = useLicenciasErrorHandler()

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

<style scoped>
/* Secciones */
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5rem;
  overflow: hidden;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.section-icon {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.section-title-group h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.section-subtitle {
  font-size: 0.85rem;
  opacity: 0.9;
}

.section-body {
  padding: 1.5rem;
}

/* Admin Info Grid */
.admin-info-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.admin-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #667eea;
}

.admin-card-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
}

.admin-card-content h4 {
  margin: 0 0 0.25rem;
  font-size: 0.85rem;
  color: #6c757d;
  font-weight: 500;
}

.admin-card-content p {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: #495057;
}

/* Admin Notice */
.admin-notice {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1.25rem;
  background: linear-gradient(135deg, #fff8e6 0%, #fff3cd 100%);
  border-radius: 8px;
  border: 1px solid #ffc107;
}

.notice-icon {
  font-size: 1.5rem;
  color: #d97706;
  flex-shrink: 0;
}

.notice-content strong {
  display: block;
  margin-bottom: 0.5rem;
  color: #92400e;
}

.notice-content p {
  margin: 0;
  color: #78350f;
  font-size: 0.9rem;
  line-height: 1.5;
}

/* Quick Actions Grid */
.quick-actions-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
}

.quick-action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  padding: 1.5rem 1rem;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.quick-action-btn:hover {
  background: #e8f4fc;
  border-color: #17a2b8;
  transform: translateY(-2px);
}

.quick-action-btn .action-icon {
  font-size: 1.75rem;
  color: #17a2b8;
}

.quick-action-btn span {
  font-size: 0.9rem;
  font-weight: 500;
  color: #495057;
}

/* Responsive */
@media (max-width: 992px) {
  .admin-info-grid { grid-template-columns: repeat(2, 1fr); }
  .quick-actions-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 576px) {
  .admin-info-grid { grid-template-columns: 1fr; }
  .quick-actions-grid { grid-template-columns: 1fr; }
}
</style>
