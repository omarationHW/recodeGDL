<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="bell" /></div><div class="module-view-info"><h1>Notificaciones por mes</h1></div></div>
  <div class="module-view-content">
    <div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Mes</label><input class="municipal-form-control" v-model="mes"/></div><div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="anio"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary" @click="load">Consultar</button></div>
    </div></div>
    <div class="municipal-card"><div class="municipal-card-body table-container"><div class="table-responsive">
      <table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="c in cols" :key="c">{{ c }}</th></tr></thead><tbody><tr v-for="(r,i) in rows" :key="i"><td v-for="c in cols" :key="c">{{ r[c] }}</td></tr><tr v-if="rows.length===0"><td :colspan="cols.length" class="text-center text-muted">Sin datos</td></tr></tbody></table>
    </div></div></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import { useApi } from '@/composables/useApi'; const { execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_NOTIFICACIONES_MES'; const mes=ref(''); const anio=ref(new Date().getFullYear()); const rows=ref([]); const cols=ref([]);
async function load(){ try{ const data=await execute(OP, BASE_DB, [ { name:'mes', type:'C', value:String(mes.value||'') }, { name:'anio', type:'I', value:Number(anio.value||0) } ]); const arr=Array.isArray(data?.rows)?data.rows:Array.isArray(data)?data:[]; rows.value=arr; cols.value=arr.length?Object.keys(arr[0]):[] }catch(e){ rows.value=[]; cols.value=[] } }
</script>

