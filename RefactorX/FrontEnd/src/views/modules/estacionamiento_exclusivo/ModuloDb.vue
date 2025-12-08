<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="database" /></div>
      <div class="module-view-info">
        <h1>Módulo DB</h1>
        <p>Gestión de conexiones y operaciones de base de datos</p>
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
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="server" /> Información de Conexión</h5>
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
            <button class="btn-municipal-primary" @click="testConnection" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'plug'" :spin="loading" />
              {{ loading ? 'Probando...' : 'Probar Conexión' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ModuloDb"
    >
      <h3>Modulo Db</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ModuloDb'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_exclusivo'

const { loading, execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const connectionStatus = ref(false)

const testConnection = async () => {
  try {
    // Intentar consulta simple para verificar conexión
    const result = await execute('SELECT 1 as test', BASE_DB, {})
    connectionStatus.value = true
    showToast('Conexión exitosa con la base de datos', 'success')
  } catch (e) {
    connectionStatus.value = false
    showToast('Error de conexión con la base de datos', 'error')
    handleApiError(e)
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>


