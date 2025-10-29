<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="retweet" /></div><div class="module-view-info"><h1>Reasignación</h1></div></div>
  <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
    <div class="form-row"><div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="form.expediente"/></div><div class="form-group"><label class="municipal-form-label">Ejecutor</label><input class="municipal-form-control" v-model="form.ejecutor"/></div></div>
    <div class="button-group"><button class="btn-municipal-primary" :disabled="loading||!form.expediente||!form.ejecutor" @click="reasignar">Reasignar</button></div>
  </div></div></div>
  </div>
</template>
<script setup>import { ref } from 'vue'; import { useApi } from '@/composables/useApi'; const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_REASIGNACION'; const form=ref({ expediente:'', ejecutor:'' }); async function reasignar(){ try{ await execute(OP, BASE_DB, [ { name:'expediente', type:'C', value:String(form.value.expediente||'') }, { name:'ejecutor', type:'C', value:String(form.value.ejecutor||'') } ]) }catch(e){} }</script>

