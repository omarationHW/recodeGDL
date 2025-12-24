<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Módulo DB</h1>
        <p>Gestión de conexiones y operaciones de base de datos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="server" />
            Información de Conexión
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>Base de Datos:</label>
              <span class="badge-info">estacionamiento_exclusivo</span>
            </div>
            <div class="info-item">
              <label>Servidor:</label>
              <span class="badge-info">192.168.6.146</span>
            </div>
            <div class="info-item">
              <label>Motor:</label>
              <span class="badge-success">PostgreSQL 16</span>
            </div>
            <div class="info-item">
              <label>Estado:</label>
              <span :class="connectionStatus ? 'badge-success' : 'badge-danger'">
                {{ connectionStatus ? 'Conectado' : 'Desconectado' }}
              </span>
            </div>
          </div>

          <div class="mt-3">
            <button class="btn-municipal-primary" @click="testConnection">
              <font-awesome-icon icon="plug" />
              Probar Conexión
            </button>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ModuloDb'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Módulo DB'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const BASE_DB = 'estacionamiento_exclusivo'

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const connectionStatus = ref(false)
const selectedRow = ref(null)
const hasSearched = ref(false)

const testConnection = async () => {
  showLoading('Probando conexión...', 'Verificando base de datos')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    // Intentar consulta simple para verificar conexión
    const result = await execute('SELECT 1 as test', BASE_DB, {})
    connectionStatus.value = true

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    toast.value.duration = durationText
    showToast('success', 'Conexión exitosa con la base de datos')
  } catch (e) {
    connectionStatus.value = false
    showToast('error', 'Error de conexión con la base de datos')
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
</script>



