<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="comment-dots" /></div>
      <div class="module-view-info">
        <h1>Mensaje del Sistema</h1>
        <p>Registro/visualización</p>
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

      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="enviar"><font-awesome-icon icon="paper-plane" /> Enviar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Tipo</label><input class="municipal-form-control" v-model="tipo" placeholder="info|warning|error" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Mensaje</label><input class="municipal-form-control" v-model="msg" /></div>
            <div class="form-group"><label class="municipal-form-label">Ícono</label><input class="municipal-form-control" v-model="icono" placeholder="info-circle" /></div>
          </div>
          <pre v-if="output" class="text-muted">{{ JSON.stringify(output, null, 2) }}</pre>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'MensajePublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Mensaje del Sistema'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const tipo = ref('info')
const msg = ref('')
const icono = ref('info-circle')
const output = ref(null)

async function enviar() {
  if (!msg.value.trim()) {
    showToast('warning', 'Ingrese el mensaje a mostrar')
    return
  }

  showLoading('Enviando...', 'Procesando mensaje')
  output.value = null
  try {
    const params = [
      { nombre: 'tipo', valor: tipo.value, tipo: 'string' },
      { nombre: 'msg', valor: msg.value, tipo: 'string' },
      { nombre: 'icono', valor: icono.value, tipo: 'string' }
    ]
    const resp = await execute('sp_mensaje_show', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    output.value = data

    showToast('success', 'El mensaje ha sido procesado')
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

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
</script>
