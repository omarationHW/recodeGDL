<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="plug" /></div><div class="module-view-info"><h1>Conexión TDM</h1><p>Pruebas de conexión/servicios</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="probar"><font-awesome-icon icon="vial" /> Probar Conexión</button></div>
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
const OP_TEST='RECAUDADORA_TDM_CONECTION' // TODO confirmar
const { loading, execute } = useApi()
const result=ref(null)
async function probar(){ try{ result.value = await execute(OP_TEST, BASE_DB, []) }catch(e){ result.value={ error: e?.message || 'Error' } } }
</script>

