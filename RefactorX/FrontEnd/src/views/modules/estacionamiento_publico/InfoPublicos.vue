<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="circle-info" /></div>
      <div class="module-view-info">
        <h1>Información — Estacionamientos Públicos</h1>
        <p>Resumen y métricas</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="loadInfo"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-bar" class="me-2" />Resumen del Sistema</h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-2 text-muted">Cargando información...</p>
          </div>

          <div v-else-if="info.error" class="empty-state">
            <div class="empty-state-icon" style="color: var(--danger);">
              <font-awesome-icon icon="exclamation-triangle" />
            </div>
            <h4 class="empty-state-title">Error al cargar</h4>
            <p class="empty-state-text">{{ info.error }}</p>
          </div>

          <div v-else class="data-grid">
            <div class="data-item">
              <font-awesome-icon icon="database" class="data-icon" />
              <span class="data-label">Total Registros</span>
              <span class="data-value highlight">{{ info.registros || 0 }}</span>
            </div>
            <div class="data-item">
              <font-awesome-icon icon="clock" class="data-icon" />
              <span class="data-label">Última Actualización</span>
              <span class="data-value">{{ info.ultimaActualizacion || 'N/A' }}</span>
            </div>
            <div class="data-item">
              <font-awesome-icon icon="server" class="data-icon" />
              <span class="data-label">Base de Datos</span>
              <span class="data-value">estacionamiento_publico</span>
            </div>
            <div class="data-item">
              <font-awesome-icon icon="check-circle" class="data-icon" />
              <span class="data-label">Estado</span>
              <span class="data-value" style="color: var(--success);">Conectado</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - InfoPublicos"
    >
      <h3>Info Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'InfoPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const info = ref({})

async function loadInfo() {
  showLoading('Cargando...', 'Obteniendo información')
  try {
    const resp = await execute('sp_get_public_parking_list', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const result = Array.isArray(data) ? data : []
    info.value = {
      registros: result.length,
      ultimaActualizacion: new Date().toLocaleString('es-MX')
    }
    showToast('success', 'Información actualizada correctamente')
  } catch (e) {
    handleApiError(e)
    info.value = { error: e.message || 'Error al cargar' }
  } finally {
    hideLoading()
  }
}

onMounted(loadInfo)

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

