<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="envelope" /></div><div class="module-view-info"><h1>Carta Invitación</h1><p>Generación de cartas de invitación</p></div>
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
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" v-model="form.expediente" placeholder="Número de folio"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !form.expediente" @click="generar"><font-awesome-icon icon="file-pdf" /> Generar Carta</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - CartaInvitacion"
    >
      <h3>Carta Invitacion</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'CartaInvitacion'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'sp_carta_invitacion'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const form = ref({ expediente: '' })

const generar = async () => {
  if (!form.value.expediente) {
    showToast('error', 'Debe ingresar expediente')
    return
  }
  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Generar carta de invitación?',
    text: `Folio: ${form.value.expediente}`,
    showCancelButton: true,
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#198754'
  })
  if (!confirm.isConfirmed) return

  showLoading('Generando carta...', 'Procesando documento')
  const t0 = performance.now()
  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_folio', type: 'C', value: String(form.value.expediente || '') }
    ])
    let data = {}
    if (response && response.data) {
      data = Array.isArray(response.data) ? response.data[0] || {} : response.data
    } else if (response && response.result) {
      data = Array.isArray(response.result) ? response.result[0] || {} : response.result
    }
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    await Swal.fire({
      icon: 'success',
      title: 'Carta generada',
      html: `<b>Folio:</b> ${data.folio || 'N/A'}<br><b>Nombre:</b> ${data.nombre || 'N/A'}<br><b>Importe:</b> ${data.importe || 0}<br>Procesado en ${txt}`,
      timer: 3000
    })
    limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiar = () => { form.value = { expediente: '' } }

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
