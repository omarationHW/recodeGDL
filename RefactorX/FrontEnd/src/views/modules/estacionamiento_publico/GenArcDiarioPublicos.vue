<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calendar-day" /></div>
      <div class="module-view-info">
        <h1>Generación Diaria — Remesas</h1>
        <p>sp14_remesa (diario)</p>
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
        <button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="play" /> Generar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><input type="number" class="municipal-form-control" v-model.number="opc" placeholder="1" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="fecha" /></div>
          </div>
          <div v-if="loading" class="spinner-border" role="status"></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - GenArcDiarioPublicos"
    >
      <h3>Gen Arc Diario Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'GenArcDiarioPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />
  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const opc = ref(1)
const axo = ref(new Date().getFullYear())
const fecha = ref(new Date().toISOString().substring(0, 10))
const message = ref('')

async function generar() {
  if (!fecha.value) {
    showToast('warning', 'Seleccione una fecha para generar')
    return
  }

  // Confirmación con SweetAlert2
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Generación',
    html: `<p>¿Generar remesa diaria?</p>
      <ul class="swal-list-left">
        <li><strong>Fecha:</strong> ${fecha.value}</li>
        <li><strong>Año:</strong> ${axo.value}</li>
        <li><strong>Opción:</strong> ${opc.value}</li>
      </ul>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Generando...', 'Creando remesa diaria')
  message.value = ''
  try {
    const params = [
      { nombre: 'p_Opc', valor: opc.value, tipo: 'integer' },
      { nombre: 'p_Axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_Fec_Ini', valor: fecha.value, tipo: 'date' },
      { nombre: 'p_Fec_Fin', valor: fecha.value, tipo: 'date' },
      { nombre: 'p_Fec_A_Fin', valor: fecha.value, tipo: 'date' }
    ]
    const resp = await execute('sp14_remesa', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data

    if (r && resp?.success !== false) {
      message.value = `${r.obs || 'Generado'} (remesa: ${r.remesa || 'N/A'})`

      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'success',
        title: 'Generación Exitosa',
        html: `<p>${r.obs || 'Remesa generada correctamente'}</p>
          <p><strong>Remesa:</strong> ${r.remesa || 'N/A'}</p>`,
        timer: 3000,
        timerProgressBar: true,
        showConfirmButton: false
      })
    } else {
      message.value = 'Sin respuesta del servidor'
      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'warning',
        title: 'Sin Respuesta',
        text: 'El servidor no devolvió información',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (e) {
    handleApiError(e)
    message.value = e.message || 'Error al generar'
    hideLoading()
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

