<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div><div class="module-view-info"><h1>Facturación</h1><p>Emisión de facturas por expediente</p></div>
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
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Facturación</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Módulo</label><input class="municipal-form-control" type="number" v-model.number="form.modulo" placeholder="Módulo"/></div><div class="form-group"><label class="municipal-form-label">Recaudadora</label><input class="municipal-form-control" type="number" v-model.number="form.recaudadora" placeholder="Recaudadora"/></div><div class="form-group"><label class="municipal-form-label">Folio Desde</label><input class="municipal-form-control" type="number" v-model.number="form.folioDesde" placeholder="0"/></div><div class="form-group"><label class="municipal-form-label">Folio Hasta</label><input class="municipal-form-control" type="number" v-model.number="form.folioHasta" placeholder="999999"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !form.modulo || !form.recaudadora" @click="emitir"><font-awesome-icon icon="file-invoice" /> Emitir Factura</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Facturacion"
    >
      <h3>Facturacion</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Facturacion'"
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
const OP_LIST = 'sp_facturacion_list'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const form=ref({modulo:1,recaudadora:1,folioDesde:0,folioHasta:999999})

const emitir = async () => {
  if (!form.value.modulo || !form.value.recaudadora) {
    showToast('error', 'Debe completar módulo y recaudadora')
    return
  }
  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar emisión de factura?',
    text: `Módulo: ${form.value.modulo}, Recaudadora: ${form.value.recaudadora}, Folios: ${form.value.folioDesde} a ${form.value.folioHasta}`,
    showCancelButton: true,
    confirmButtonText: 'Sí, emitir',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#198754'
  })
  if (!confirm.isConfirmed) return
  showLoading('Emitiendo factura...', 'Procesando información')
  const t0 = performance.now()
  try {
    const response = await execute(OP_LIST, BASE_DB, [
      { name: 'p_modulo', type: 'I', value: Number(form.value.modulo || 1) },
      { name: 'p_rec', type: 'I', value: Number(form.value.recaudadora || 1) },
      { name: 'p_fol1', type: 'I', value: Number(form.value.folioDesde || 0) },
      { name: 'p_fol2', type: 'I', value: Number(form.value.folioHasta || 999999) }
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
      title: 'Factura emitida',
      html: `<b>${data.length} registros encontrados</b><br>Procesado en ${txt}`,
      timer: 2000
    })
    limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiar = () => { form.value={modulo:1,recaudadora:1,folioDesde:0,folioHasta:999999} }

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
