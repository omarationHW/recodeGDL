<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="badge-check" /></div><div class="module-view-info"><h1>Autoriza Descuentos</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="form.expediente"/></div><div class="form-group"><label class="municipal-form-label">% Descuento</label><input class="municipal-form-control" type="number" v-model.number="form.porcentaje"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading||!form.expediente||!form.porcentaje" @click="autorizar">Autorizar</button></div>
    </div></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi';
const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_AUTORIZADES';
const form=ref({ expediente:'', porcentaje:null });
async function autorizar(){ try{ await execute(OP, BASE_DB, [ { name:'expediente', type:'C', value:String(form.value.expediente||'') }, { name:'porcentaje', type:'I', value:Number(form.value.porcentaje||0) } ]) }catch(e){} }
</script>

