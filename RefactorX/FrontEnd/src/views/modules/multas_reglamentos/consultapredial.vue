<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="house" /></div><div class="module-view-info"><h1>Consulta Predial</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Clave Catastral</label><input class="municipal-form-control" v-model="filters.cvecat"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search"/> Buscar</button></div>
    </div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5>Predial</h5></div><div class="municipal-card-body"><pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(data,null,2) }}</pre></div></div>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi'
const { loading, execute } = useApi(); const BASE_DB = 'multas_reglamentos'; const OP='RECAUDADORA_CONSULTAPREDIAL'; const filters=ref({ cvecat:'' }); const data=ref(null)
async function consultar(){ try{ data.value=await execute(OP, BASE_DB, [ { name:'cvecat', type:'C', value:String(filters.value.cvecat||'') } ]) }catch(e){ data.value=null } }
</script>

