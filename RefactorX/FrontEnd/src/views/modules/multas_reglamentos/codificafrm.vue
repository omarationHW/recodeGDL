<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="barcode" /></div><div class="module-view-info"><h1>Codificación</h1><p>codificafrm.vue</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Texto</label><input class="municipal-form-control" v-model="form.texto"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="codificar"><font-awesome-icon icon="wand-magic-sparkles"/> Codificar</button></div>
      </div></div>
      <div class="municipal-card" v-if="result"><div class="municipal-card-header"><h5>Resultado</h5></div>
        <div class="municipal-card-body"><pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(result, null, 2) }}</pre></div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'multas_reglamentos'
const OP_CODIF='RECAUDADORA_CODIFICAFRM' // TODO confirmar
const { loading, execute } = useApi()
const form=ref({ texto:'' })
const result=ref(null)
async function codificar() {
  try {
    const data = await execute(OP_CODIF, BASE_DB, [
      { nombre: 'p_texto', valor: String(form.value.texto || ''), tipo: 'string' }
    ])

    // Extraer solo el resultado limpio
    const arr = Array.isArray(data?.result) ? data.result : []
    result.value = arr.length > 0 ? arr[0] : { error: 'Sin resultados' }
  } catch (e) {
    result.value = { error: e?.message || 'Error' }
  }
}
</script>

