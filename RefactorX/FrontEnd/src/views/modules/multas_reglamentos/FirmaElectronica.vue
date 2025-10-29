<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="signature" /></div><div class="module-view-info"><h1>Firma Electrónica</h1><p>Gestión de firmas</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Datos</label><textarea class="municipal-form-control" rows="6" v-model="jsonPayload"></textarea></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="firmar"><font-awesome-icon icon="signature"/> Firmar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB='INFORMIX'
const OP_SIGN='RECAUDADORA_FIRMA_ELECTRONICA' // TODO confirmar
const { loading, execute } = useApi()
const jsonPayload=ref('')
async function firmar(){ try{ await execute(OP_SIGN, BASE_DB, [ { name:'datos', type:'C', value: jsonPayload.value } ]) }catch(e){} }
</script>

