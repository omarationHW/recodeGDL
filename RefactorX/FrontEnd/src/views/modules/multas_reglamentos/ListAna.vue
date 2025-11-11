<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Listado Analítico</h1>
        <p>Consulta con paginación server-side</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro</label>
              <input class="municipal-form-control" v-model="filters.q" @keyup.enter="reload" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td v-for="col in columns" :key="col">{{ r[col] }}</td>
                </tr>
                <tr v-if="rows.length===0"><td :colspan="columns.length" class="text-center text-muted">Sin resultados</td></tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="pagination-container" v-if="!loading && total > 0">
          <div class="pagination-info">Mostrando {{ (page-1)*pageSize + 1 }} a {{ Math.min(page*pageSize, total) }} de {{ total }}</div>
          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" @change="reload"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option></select>
            </div>
            <div class="pagination-nav">
              <button class="pagination-button" :disabled="page===1" @click="go(page-1)"><font-awesome-icon icon="chevron-left" /></button>
              <button class="pagination-button" :disabled="page*pageSize>=total" @click="go(page+1)"><font-awesome-icon icon="chevron-right" /></button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_LISTANA' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ q: '' })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])
const columns = ref([])

async function reload() {
  const params = [
    { name: 'q', type: 'C', value: String(filters.value.q || '') },
    { name: 'offset', type: 'I', value: (page.value - 1) * pageSize.value },
    { name: 'limit', type: 'I', value: pageSize.value }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    rows.value = arr
    columns.value = arr.length ? Object.keys(arr[0]) : []
    total.value = Number(data?.total ?? rows.value.length)
  } catch (e) {
    rows.value = []
    columns.value = []
    total.value = 0
  }
}

function go(p) { page.value = p; reload() }

reload()
</script>

