<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="users" /></div><div class="module-view-info"><h1>ABC Ejecutores</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row">
        <div class="form-group"><label class="municipal-form-label">Nombre</label><input class="municipal-form-control" v-model="filters.q" @keyup.enter="reload"/></div>
      </div>
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="reload">Buscar</button></div>
    </div></div>
    <div class="municipal-card"><div class="municipal-card-header"><h5>Ejecutores</h5></div>
      <div class="municipal-card-body table-container"><div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="c in cols" :key="c">{{ c }}</th></tr></thead><tbody><tr v-for="(r,i) in rows" :key="i"><td v-for="c in cols" :key="c">{{ r[c] }}</td></tr><tr v-if="rows.length===0"><td :colspan="cols.length" class="text-center text-muted">Sin resultados</td></tr></tbody></table></div></div>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi'
const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_EJECUTORES_CATALOGO'
const filters=ref({ q:'' }); const rows=ref([]); const cols=ref([])
async function reload(){ try{ const data=await execute(OP, BASE_DB, [ { name:'q', type:'C', value:String(filters.value.q||'') } ]); const arr=Array.isArray(data?.rows)?data.rows:Array.isArray(data)?data:[]; rows.value=arr; cols.value=arr.length?Object.keys(arr[0]):[] }catch(e){ rows.value=[]; cols.value=[] } }
reload()
</script>

