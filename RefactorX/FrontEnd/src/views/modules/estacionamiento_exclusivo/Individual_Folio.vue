<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file" /></div><div class="module-view-info"><h1>Requerimiento por Folio</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" v-model="filters.folio"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="consultar">Consultar</button></div>
    </div></div>
    <div class="municipal-card"><div class="municipal-card-header"><h5>Detalle</h5></div><div class="municipal-card-body"><pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(data,null,2) }}</pre></div></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi'; const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_REQUERIMIENTOS_INDIVIDUAL';
const filters=ref({ folio:'' }); const data=ref(null); async function consultar(){ try{ data.value=await execute(OP, BASE_DB, [ { name:'folio', type:'C', value:String(filters.value.folio||'') } ]) }catch(e){ data.value=null } }
</script>

