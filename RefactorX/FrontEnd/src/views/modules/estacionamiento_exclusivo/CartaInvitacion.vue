<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="envelope" /></div><div class="module-view-info"><h1>Carta Invitación</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="filters.expediente"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="generar">Generar</button></div>
    </div></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi'
const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_CARTA_INVITACION'
const filters=ref({ expediente:'' })
async function generar(){ try{ await execute(OP, BASE_DB, [ { name:'expediente', type:'C', value:String(filters.value.expediente||'') } ]) }catch(e){} }
</script>

