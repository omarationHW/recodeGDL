<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="signature" /></div><div class="module-view-info"><h1>Firma Electrónica</h1><p>Firma electrónica de documentos</p></div>
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
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Firma</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Módulo</label><input class="municipal-form-control" type="number" v-model.number="form.modulo" placeholder="1"/></div><div class="form-group"><label class="municipal-form-label">Fecha</label><input class="municipal-form-control" type="date" v-model="form.fecha"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !form.modulo || !form.fecha" @click="firmar"><font-awesome-icon icon="pen-nib" /> Listar Folios</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - FirmaElectronica"
    >
      <h3>Firma Electronica</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'FirmaElectronica'"
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
const OP_LISTAR = 'sp_firmaelectronica_listar_folios'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const form = ref({ modulo: 1, fecha: '' })

const firmar = async () => {
  if (!form.value.modulo || !form.value.fecha) {
    showToast('error', 'Debe completar módulo y fecha')
    return
  }
  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Listar folios para firma electrónica?',
    text: `Módulo: ${form.value.modulo}, Fecha: ${form.value.fecha}`,
    showCancelButton: true,
    confirmButtonText: 'Sí, listar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#198754'
  })
  if (!confirm.isConfirmed) return

  showLoading('Listando folios...', 'Procesando firma electrónica')
  const t0 = performance.now()
  try {
    const response = await execute(OP_LISTAR, BASE_DB, [
      { name: 'pmod', type: 'I', value: Number(form.value.modulo || 1) },
      { name: 'pfec', type: 'D', value: String(form.value.fecha || '') }
    ])
    let data = []
    if (response && response.data) {
      data = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      data = Array.isArray(response.result) ? response.result : []
    }
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    await Swal.fire({
      icon: 'success',
      title: 'Folios listados',
      html: `<b>${data.length} folios encontrados</b><br>Procesado en ${txt}`,
      timer: 2000
    })
    limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiar = () => { form.value = { modulo: 1, fecha: '' } }

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
