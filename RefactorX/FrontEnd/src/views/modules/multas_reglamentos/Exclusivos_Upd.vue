<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="id-badge" /></div><div class="module-view-info"><h1>Exclusivos Update</h1><p>Actualización de exclusivos</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">JSON</label><textarea class="municipal-form-control" rows="8" v-model="jsonPayload"></textarea></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="aplicar"><font-awesome-icon icon="check"/> Aplicar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB='INFORMIX'
const OP_UPD='RECAUDADORA_EXCLUSIVOS_UPD' // TODO confirmar
const { loading, execute } = useApi()
const jsonPayload=ref('')
async function aplicar(){ try{ await execute(OP_UPD, BASE_DB, [ { name:'datos', type:'C', value: jsonPayload.value } ]) }catch(e){} }
</script>

