<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-signature" /></div><div class="module-view-info"><h1>Consulta Escrituras 400</h1><p>consescrit400.vue</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search"/> Buscar</button></div>
      </div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5>Registros</h5><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading"><div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="c in cols" :key="c">{{ c }}</th></tr></thead><tbody><tr v-for="(r,i) in rows" :key="i" class="row-hover"><td v-for="c in cols" :key="c">{{ r[c] }}</td></tr><tr v-if="rows.length===0"><td :colspan="cols.length" class="text-center text-muted">Sin resultados</td></tr></tbody></table></div></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_CONSESCRIT400'
const { loading, execute } = useApi()
const filters = ref({ cuenta: '' })
const rows = ref([])
const cols = ref([])

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', valor: String(filters.value.cuenta || ''), tipo: 'string' }
  ]
  try {
    const data = await execute(OP, BASE_DB, params)
    const arr = Array.isArray(data?.result) ? data.result : Array.isArray(data) ? data : []
    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
  } catch (e) {
    rows.value = []
    cols.value = []
  }
}
reload()
</script>
