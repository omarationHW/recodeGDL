<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="barcode" /></div><div class="module-view-info"><h1>Codificación</h1><p>codificafrm.vue</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Texto</label><input class="municipal-form-control" v-model="form.texto"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="codificar"><font-awesome-icon icon="wand-magic-sparkles"/> Codificar</button></div>
      </div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5>Resultado</h5></div>
        <div class="municipal-card-body"><pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(result, null, 2) }}</pre></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB='INFORMIX'
const OP_CODIF='RECAUDADORA_CODIFICAFRM' // TODO confirmar
const { loading, execute } = useApi()
const form=ref({ texto:'' })
const result=ref(null)
async function codificar(){ try{ result.value = await execute(OP_CODIF, BASE_DB, [ { name:'texto', type:'C', value:String(form.value.texto||'') } ]) }catch(e){ result.value={ error:e?.message||'Error' } } }
</script>

