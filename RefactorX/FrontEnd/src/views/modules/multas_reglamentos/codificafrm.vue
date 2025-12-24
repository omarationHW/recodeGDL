<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="barcode" /></div><div class="module-view-info"><h1>Codificación</h1><p>codificafrm.vue</p></div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Texto</label><input class="municipal-form-control" v-model="form.texto"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="codificar"><font-awesome-icon icon="wand-magic-sparkles"/> Codificar</button></div>
      </div></div>
      <div class="municipal-card" v-if="result"><div class="municipal-card-header"><h5>Resultado</h5></div>
        <div class="municipal-card-body"><pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(result, null, 2) }}</pre></div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'codificafrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Codificación'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'codificafrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Codificación'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP_CODIF='RECAUDADORA_CODIFICAFRM' // TODO confirmar
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const form=ref({ texto:'' })
const result=ref(null)
async function codificar() {
  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_CODIF, BASE_DB, [
      { nombre: 'p_texto', valor: String(form.value.texto || ''), tipo: 'string' }
    ], '', null, 'publico')

    // Extraer datos de la estructura correcta
    const data = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(data?.result) ? data.result : []
    result.value = arr.length > 0 ? arr[0] : { error: 'Sin resultados' }
  } catch (e) {
    result.value = { error: e?.message || 'Error' }
  } finally {
    hideLoading()
  }
}
</script>
