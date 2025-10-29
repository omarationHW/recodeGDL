<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div><div class="module-view-info"><h1>Requerimiento</h1><p>Consulta y gestión</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload" /></div><div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" @keyup.enter="reload" /></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button></div>
      </div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading"><div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="col in columns" :key="col">{{ col }}</th></tr></thead><tbody><tr v-for="(r, idx) in rows" :key="idx" class="row-hover"><td v-for="col in columns" :key="col">{{ r[col] }}</td></tr><tr v-if="rows.length===0"><td :colspan="columns.length" class="text-center text-muted">Sin resultados</td></tr></tbody></table></div></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'INFORMIX'
const OP_LIST = 'RECAUDADORA_REQ' // TODO confirmar
const { loading, execute } = useApi()
const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])
const columns = ref([])
async function reload(){ const params=[{name:'clave_cuenta',type:'C',value:String(filters.value.cuenta||'')},{name:'ejercicio',type:'I',value:Number(filters.value.ejercicio||0)}]; try{const data=await execute(OP_LIST,BASE_DB,params); const arr=Array.isArray(data?.rows)?data.rows:Array.isArray(data)?data:[]; rows.value=arr; columns.value=arr.length?Object.keys(arr[0]):[]}catch(e){rows.value=[];columns.value=[]}}; reload()
</script>

