<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Estado de Cuenta — Estacionamientos Públicos</h1>
        <p>Búsqueda por número de estacionamiento</p>
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
      <!-- Sección de Búsqueda -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="search" /></div>
          <div class="section-title-group">
            <h3>Búsqueda de Estado de Cuenta</h3>
            <span class="section-subtitle">Ingrese el número de estacionamiento para consultar</span>
          </div>
        </div>
        <div class="section-body">
          <div class="search-row">
            <div class="form-field">
              <label class="municipal-form-label">Número de Estacionamiento</label>
              <div class="input-group search-group">
                <span class="input-icon"><font-awesome-icon icon="parking" /></span>
                <input
                  class="municipal-form-control"
                  type="number"
                  v-model.number="numesta"
                  placeholder="Ej: 12345"
                  @keyup.enter="consultar"
                />
                <button class="btn-municipal-primary" :disabled="loading" @click="consultar">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Consultar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sección de Resultados -->
      <div class="form-section" v-if="row || !row">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="id-card" /></div>
          <div class="section-title-group">
            <h3>Datos del Estacionamiento</h3>
            <span class="section-subtitle">
              <span v-if="row">Información encontrada</span>
              <span v-else>Esperando consulta</span>
            </span>
          </div>
          <div class="section-actions" v-if="loading">
            <div class="spinner-border spinner-border-sm" role="status"></div>
          </div>
        </div>
        <div class="section-body">
          <!-- Datos encontrados -->
          <div v-if="row" class="info-grid">
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="user" /> Identificación</div>
              <div class="info-card-body">
                <div class="info-row">
                  <span class="info-label">Nombre:</span>
                  <span class="info-value">{{ row.nombre || '—' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">Licencia:</span>
                  <span class="info-value"><code class="license-code">{{ row.numlicencia || '—' }}</code></span>
                </div>
                <div class="info-row">
                  <span class="info-label">RFC:</span>
                  <span class="info-value"><code>{{ row.rfc || '—' }}</code></span>
                </div>
              </div>
            </div>
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="map-marker-alt" /> Ubicación</div>
              <div class="info-card-body">
                <div class="info-row">
                  <span class="info-label">Sector:</span>
                  <span class="info-value">{{ row.sector || '—' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">Zona:</span>
                  <span class="info-value">{{ row.zona || '—' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">Subzona:</span>
                  <span class="info-value">{{ row.subzona || '—' }}</span>
                </div>
              </div>
            </div>
            <div class="info-card info-card-full">
              <div class="info-card-header"><font-awesome-icon icon="info-circle" /> Información Adicional</div>
              <div class="info-card-body">
                <div class="info-row">
                  <span class="info-label">Descripción:</span>
                  <span class="info-value">{{ row.descripcion || 'Sin descripción' }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Estado vacío -->
          <div v-else class="empty-state-panel">
            <div class="empty-icon-container">
              <font-awesome-icon icon="file-invoice-dollar" size="3x" />
            </div>
            <h4>Estado de Cuenta</h4>
            <p>Ingrese un número de estacionamiento para consultar su información</p>
            <div class="example-hint">
              <div class="example-box">
                <font-awesome-icon icon="lightbulb" class="example-bulb" />
                <div class="example-content">
                  <strong>Ejemplo:</strong> Ingrese <code>12345</code> y presione Consultar para ver los datos del estacionamiento
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - EdoCtaPublicos">
      <h3>Estado de Cuenta Públicos</h3>
      <p>Este módulo permite consultar el estado de cuenta de estacionamientos públicos.</p>
      <h4>Instrucciones:</h4>
      <ol>
        <li>Ingrese el número de estacionamiento</li>
        <li>Presione el botón Consultar o Enter</li>
        <li>Se mostrarán los datos del estacionamiento</li>
      </ol>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'EdoCtaPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const numesta = ref(null)
const row = ref(null)

async function consultar() {
  if (!numesta.value) {
    showToast('warning', 'Ingrese el número de estacionamiento')
    return
  }

  showLoading('Consultando...', 'Buscando estado de cuenta')
  row.value = null
  try {
    const params = [{ nombre: 'numesta', valor: numesta.value, tipo: 'integer' }]
    const resp = await execute('spubreports_edocta', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    row.value = Array.isArray(data) ? data[0] : data

    if (row.value) {
      showToast('success', `Estacionamiento ${numesta.value} encontrado`)
    } else {
      showToast('info', 'No se encontró información para este estacionamiento')
    }
  } catch (e) {
    handleApiError(e)
    row.value = null
  } finally {
    hideLoading()
  }
}

// Documentación y Ayuda
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

.section-actions {
  margin-left: auto;
}

.section-body {
  padding: 1.5rem;
}

/* Search row */
.search-row {
  max-width: 600px;
}

.form-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.input-group {
  position: relative;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.input-icon {
  position: absolute;
  left: 12px;
  color: #6c757d;
  z-index: 1;
}

.search-group .municipal-form-control {
  padding-left: 38px;
  flex: 1;
}

/* Info grid */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.info-card {
  background: #f8f9fa;
  border-radius: 8px;
  overflow: hidden;
}

.info-card-full {
  grid-column: 1 / -1;
}

.info-card-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.75rem 1rem;
  font-weight: 600;
}

.info-card-body {
  padding: 1rem;
}

.info-row {
  display: flex;
  padding: 0.5rem 0;
  border-bottom: 1px solid #e9ecef;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  flex: 0 0 120px;
  font-weight: 500;
  color: #6c757d;
}

.info-value {
  flex: 1;
  color: #212529;
}

.license-code {
  background: #e3f2fd;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
  color: #1976d2;
}

/* Empty state */
.empty-state-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  color: #6c757d;
}

.empty-icon-container {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.empty-state-panel h4 {
  margin: 0 0 0.5rem;
  color: #495057;
}

.empty-state-panel p {
  margin: 0 0 1.5rem;
}

.example-hint {
  max-width: 400px;
}

.example-box {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 8px;
  text-align: left;
}

.example-bulb {
  color: #856404;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.example-content {
  color: #856404;
  line-height: 1.5;
}

.example-content code {
  background: white;
  padding: 0.125rem 0.375rem;
  border-radius: 4px;
  font-weight: 600;
}
</style>
