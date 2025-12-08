<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="edit" /></div><div class="module-view-info"><h1>Modificar Registro</h1><p>Modificación de registro individual</p></div>
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
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Modificación</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Registro (JSON)</label><textarea class="municipal-form-control" rows="10" v-model="jsonPayload" placeholder='{"expediente":"123","campo":"valor"}'></textarea></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="guardar"><font-awesome-icon icon="save" /> Guardar Cambios</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Modifcar"
    >
      <h3>Modifcar</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Modifcar'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_MODIFICAR = 'sp_modificar_apremio'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const form = ref({ folio: null, modulo: null, recaudadora: null })
const jsonPayload = ref('')

const guardar = async () => {
  if (!jsonPayload.value) {
    showToast('error', 'Debe ingresar datos JSON')
    return
  }
  const confirmResult = await Swal.fire({
    title: '¿Confirmar modificación?',
    text: 'Se modificará el registro con los datos JSON proporcionados',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, modificar',
    cancelButtonText: 'Cancelar'
  })
  if (!confirmResult.isConfirmed) return

  showLoading('Guardando cambios...', 'Procesando modificación')
  const t0 = performance.now()
  try {
    const response = await execute(OP_MODIFICAR, BASE_DB, [
      { name: 'datos', type: 'C', value: jsonPayload.value }
    ])
    let arr = {}
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data[0] || {} : response.data
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result[0] || {} : response.result
    }
    const mensaje = arr?.result || arr?.mensaje || 'Registro modificado'
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    await Swal.fire({ title: '¡Éxito!', text: `${mensaje} (${txt})`, icon: 'success', confirmButtonText: 'OK' })
    limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiar = () => { form.value = { folio: null, modulo: null, recaudadora: null }; jsonPayload.value = '' }

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
