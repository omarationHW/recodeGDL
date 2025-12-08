<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="sliders" /></div><div class="module-view-info"><h1>Modificación Masiva</h1><p>Modificación masiva de registros</p></div>
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
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Modificación Masiva</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Folio Desde</label><input class="municipal-form-control" type="number" v-model.number="form.folio_desde" placeholder="Folio inicial"/></div><div class="form-group"><label class="municipal-form-label">Folio Hasta</label><input class="municipal-form-control" type="number" v-model.number="form.folio_hasta" placeholder="Folio final"/></div><div class="form-group"><label class="municipal-form-label">Módulo</label><input class="municipal-form-control" type="number" v-model.number="form.modulo" placeholder="28=Exclusivos, 24=Públicos"/></div><div class="form-group"><label class="municipal-form-label">Recaudadora</label><input class="municipal-form-control" type="number" v-model.number="form.recaudadora" placeholder="ID Recaudadora (default: 1)"/></div><div class="form-group full-width"><label class="municipal-form-label">Acción</label><input class="municipal-form-control" v-model="form.accion" placeholder="Tipo de modificación"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !folioDesdeComputed || !folioHastaComputed" @click="aplicar"><font-awesome-icon icon="save" /> Aplicar Cambios Masivos</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Modif_Masiva"
    >
      <h3>Modif_ Masiva</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Modif_Masiva'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_APLICAR = 'sp_modif_masiva_aplicar'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const form = ref({ folio_desde: null, folio_hasta: null, modulo: null, recaudadora: null, accion: null })

const folioDesdeComputed = computed(() => form.value.folio_desde ?? null)
const folioHastaComputed = computed(() => form.value.folio_hasta ?? null)
const accionComputed = computed(() => form.value.accion ?? null)

const aplicar = async () => {
  if (!folioDesdeComputed.value || !folioHastaComputed.value || !accionComputed.value) {
    showToast('error', 'Debe completar todos los campos incluyendo acción')
    return
  }
  const confirmResult = await Swal.fire({
    title: '¿Confirmar modificación masiva?',
    text: `Se modificarán los folios del ${folioDesdeComputed.value} al ${folioHastaComputed.value}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, continuar',
    cancelButtonText: 'Cancelar'
  })
  if (!confirmResult.isConfirmed) return

  showLoading('Aplicando modificación masiva...', 'Procesando cambios')
  const t0 = performance.now()
  try {
    const criterio = `id_control BETWEEN ${folioDesdeComputed.value} AND ${folioHastaComputed.value}`
    const response = await execute(OP_APLICAR, BASE_DB, [
      { name: 'p_criterio', type: 'C', value: criterio },
      { name: 'p_campo', type: 'C', value: String(form.value.accion || 'observaciones') },
      { name: 'p_valor', type: 'C', value: String(form.value.modulo || 'N/A') }
    ])
    let arr = {}
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data[0] || {} : response.data
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result[0] || {} : response.result
    }
    const mensaje = arr?.success ? `${arr?.message} (${arr?.rows_affected} registros)` : (arr?.message || 'Modificación masiva aplicada')
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    await Swal.fire({ title: arr?.success ? '¡Éxito!' : 'Advertencia', text: `${mensaje} (${txt})`, icon: arr?.success ? 'success' : 'warning', confirmButtonText: 'OK' })
    if (arr?.success) limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiar = () => { form.value = { folio_desde: null, folio_hasta: null, modulo: null, recaudadora: null, accion: null } }

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
