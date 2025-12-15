<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="map" /></div>
      <div class="module-view-info">
        <h1>Predio Cartográfico</h1>
        <p>URL del visor por clave catastral</p>
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
            <h3>Consulta de Predio</h3>
            <span class="section-subtitle">Ingrese la clave catastral para obtener la URL del visor</span>
          </div>
        </div>
        <div class="section-body">
          <div class="search-container">
            <div class="form-field">
              <label class="municipal-form-label">Clave Catastral</label>
              <div class="input-group search-group">
                <span class="input-icon"><font-awesome-icon icon="key" /></span>
                <input
                  class="municipal-form-control"
                  v-model="clave"
                  @keyup.enter="consultar"
                  placeholder="Ingrese la clave catastral"
                />
                <button class="btn-municipal-primary" :disabled="loading" @click="consultar">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'link'" :spin="loading" /> Obtener URL
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sección de Resultado -->
      <div class="form-section" v-if="url || message">
        <div class="section-header" :class="url ? 'section-header-success' : 'section-header-warning'">
          <div class="section-icon"><font-awesome-icon :icon="url ? 'check-circle' : 'info-circle'" /></div>
          <div class="section-title-group">
            <h3>{{ url ? 'URL Encontrada' : 'Sin Resultados' }}</h3>
            <span class="section-subtitle">{{ url ? 'Visor cartográfico disponible' : 'No se encontró información' }}</span>
          </div>
        </div>
        <div class="section-body">
          <div v-if="url" class="result-content">
            <div class="url-display">
              <font-awesome-icon icon="globe" class="url-icon" />
              <code class="url-text">{{ url }}</code>
            </div>
            <div class="action-buttons">
              <a class="btn-municipal-primary btn-lg" :href="url" target="_blank">
                <font-awesome-icon icon="external-link-alt" /> Abrir Visor Cartográfico
              </a>
              <button class="btn-municipal-secondary" @click="copiarUrl">
                <font-awesome-icon icon="copy" /> Copiar URL
              </button>
            </div>
          </div>
          <div v-else class="empty-result">
            <font-awesome-icon icon="map-marked-alt" size="2x" class="empty-icon" />
            <p>{{ message }}</p>
          </div>
        </div>
      </div>

      <!-- Información -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="info-circle" /></div>
          <div class="section-title-group">
            <h3>Información</h3>
            <span class="section-subtitle">Sobre el visor cartográfico</span>
          </div>
        </div>
        <div class="section-body">
          <div class="info-list">
            <div class="info-item">
              <font-awesome-icon icon="map-marker-alt" class="info-icon text-primary" />
              <span>El visor muestra la ubicación geográfica del predio en el mapa</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="key" class="info-icon text-warning" />
              <span>La clave catastral es el identificador único del predio</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="external-link-alt" class="info-icon text-success" />
              <span>El visor se abrirá en una nueva pestaña del navegador</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - PredioCartoPublicos">
      <h3>Predio Cartográfico</h3>
      <p>Este módulo permite obtener la URL del visor cartográfico para un predio específico.</p>
      <h4>Instrucciones:</h4>
      <ol>
        <li>Ingrese la clave catastral del predio</li>
        <li>Presione el botón "Obtener URL" o Enter</li>
        <li>Si se encuentra la URL, podrá abrir el visor en una nueva pestaña</li>
      </ol>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'PredioCartoPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const clave = ref('')
const url = ref('')
const message = ref('')

async function consultar() {
  if (!clave.value.trim()) {
    showToast('warning', 'Ingrese la clave catastral')
    return
  }

  showLoading('Consultando...', 'Obteniendo URL del predio')
  url.value = ''
  message.value = ''

  try {
    const params = [
      { nombre: 'p_cvecatastro', valor: clave.value, tipo: 'string' }
    ]

    const resp = await execute('sp_get_predio_carto_url', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const v = Array.isArray(data) ? data[0] : data
    url.value = v?.url || v || ''

    if (url.value) {
      showToast('success', 'URL del visor cartográfico obtenida correctamente')
    } else {
      message.value = 'No se encontró URL para esta clave catastral'
      showToast('info', 'No se encontró información para esta clave')
    }
  } catch (e) {
    handleApiError(e)
    message.value = e.message || 'Error al consultar'
  } finally {
    hideLoading()
  }
}

function copiarUrl() {
  if (url.value) {
    navigator.clipboard.writeText(url.value).then(() => {
      showToast('success', 'URL copiada al portapapeles')
    }).catch(() => {
      showToast('error', 'No se pudo copiar la URL')
    })
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

.section-header-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.section-header-warning {
  background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
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

/* Search */
.search-container {
  max-width: 700px;
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

/* Result */
.result-content {
  text-align: center;
}

.url-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

.url-icon {
  font-size: 2rem;
  color: #28a745;
}

.url-text {
  font-size: 0.9rem;
  background: #e9ecef;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  max-width: 500px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.btn-lg {
  padding: 0.75rem 2rem;
  font-size: 1.1rem;
}

.empty-result {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
}

.empty-icon {
  margin-bottom: 1rem;
  opacity: 0.5;
}

/* Info list */
.info-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.info-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.text-primary { color: #667eea; }
.text-success { color: #28a745; }
.text-warning { color: #ffc107; }
</style>
