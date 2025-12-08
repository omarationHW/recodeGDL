<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="retweet" /></div><div class="module-view-info"><h1>Reasignación de Ejecutores</h1><p>Reasignar expedientes a diferentes ejecutores</p></div>
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
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Reasignación</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Folio Desde</label><input class="municipal-form-control" type="number" v-model.number="form.folio_desde" placeholder="Folio inicial"/></div><div class="form-group"><label class="municipal-form-label">Folio Hasta</label><input class="municipal-form-control" type="number" v-model.number="form.folio_hasta" placeholder="Folio final"/></div><div class="form-group"><label class="municipal-form-label">Ejecutor</label><input class="municipal-form-control" type="number" v-model.number="form.ejecutor" placeholder="Clave de ejecutor"/></div><div class="form-group"><label class="municipal-form-label">Recaudadora</label><input class="municipal-form-control" type="number" v-model.number="form.recaudadora" placeholder="ID Recaudadora (default: 1)"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !folioDesdeComputed || !folioHastaComputed || !ejecutorComputed" @click="reasignar"><font-awesome-icon icon="save" /> Reasignar</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Reasignacion"
    >
      <h3>Reasignacion</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Reasignacion'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_REASIGNAR = 'sp_reasignar_folio'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const form = ref({ folio_desde: null, folio_hasta: null, ejecutor: null, recaudadora: null })

const folioDesdeComputed = computed(() => form.value.folio_desde ?? null)
const folioHastaComputed = computed(() => form.value.folio_hasta ?? null)
const ejecutorComputed = computed(() => form.value.ejecutor ?? null)

const reasignar = async () => {
  if (!folioDesdeComputed.value || !ejecutorComputed.value) {
    showToast('error', 'Debe completar folio y ejecutor')
    return
  }
  const confirmResult = await Swal.fire({
    title: '¿Confirmar reasignación?',
    text: `Reasignar folio ${folioDesdeComputed.value} al ejecutor ${ejecutorComputed.value}`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, reasignar',
    cancelButtonText: 'Cancelar'
  })
  if (!confirmResult.isConfirmed) return

  showLoading('Reasignando folio...', 'Procesando cambio')
  const t0 = performance.now()
  try {
    const fechaActual = new Date().toISOString().split('T')[0]
    const response = await execute(OP_REASIGNAR, BASE_DB, [
      { name: 'p_id_control', type: 'I', value: Number(folioDesdeComputed.value) },
      { name: 'p_nuevo_ejecutor', type: 'I', value: Number(ejecutorComputed.value) },
      { name: 'p_fecha_entrega2', type: 'D', value: fechaActual },
      { name: 'p_usuario', type: 'I', value: 1 },
      { name: 'p_fecha_actualiz', type: 'D', value: fechaActual }
    ])
    const mensaje = typeof response === 'string' ? response : (response?.result || response?.data || 'Reasignación exitosa')
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
const limpiar = () => { form.value = { folio_desde: null, folio_hasta: null, ejecutor: null, recaudadora: null } }

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
