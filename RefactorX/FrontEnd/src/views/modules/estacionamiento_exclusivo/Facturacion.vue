<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div><div class="module-view-info"><h1>Facturación</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="form.expediente"/></div><div class="form-group"><label class="municipal-form-label">RFC</label><input class="municipal-form-control" v-model="form.rfc"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading||!form.expediente||!form.rfc" @click="emitir">Emitir</button></div>
    </div></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi';
const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_FACTURACION';
const form=ref({ expediente:'', rfc:'' });
async function emitir(){ try{ await execute(OP, BASE_DB, [ { name:'expediente', type:'C', value:String(form.value.expediente||'') }, { name:'rfc', type:'C', value:String(form.value.rfc||'') } ]) }catch(e){} }
</script>

