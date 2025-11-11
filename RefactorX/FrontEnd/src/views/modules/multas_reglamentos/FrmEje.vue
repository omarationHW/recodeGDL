<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="gears" /></div><div class="module-view-info"><h1>FrmEje</h1><p>Ejecución de procesos</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Parámetros (JSON)</label><textarea class="municipal-form-control" rows="8" v-model="jsonPayload"></textarea></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="ejecutar"><font-awesome-icon icon="play" /> Ejecutar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP='RECAUDADORA_FRMEJE'
const jsonPayload=ref('')
async function ejecutar(){ try{ await execute(OP, BASE_DB, [ { name:'params', type:'C', value: jsonPayload.value } ]) }catch(e){} }
</script>

