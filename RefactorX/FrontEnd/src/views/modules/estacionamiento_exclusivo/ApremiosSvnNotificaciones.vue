<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bell" /></div>
      <div class="module-view-info"><h1>Notificaciones SVN</h1></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input class="municipal-form-control" v-model="filters.q" @keyup.enter="reload" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Desde</label>
              <input class="municipal-form-control" type="date" v-model="filters.desde" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Hasta</label>
              <input class="municipal-form-control" type="date" v-model="filters.hasta" />
            </div>
          </div>
          <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button></div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Expediente</th><th>Notificador</th><th>Fecha</th><th>Estado</th></tr></thead>
              <tbody>
                <tr v-for="(r, i) in rows" :key="i" class="row-hover">
                  <td>{{ r.expediente }}</td><td>{{ r.notificador }}</td><td>{{ r.fecha }}</td><td>{{ r.estado }}</td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="4" class="text-center text-muted">Sin resultados</td></tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="pagination-container" v-if="!loading && total>0">
          <div class="pagination-info">Mostrando {{ (page-1)*pageSize+1 }} a {{ Math.min(page*pageSize,total) }} de {{ total }}</div>
          <div class="pagination-controls">
            <div class="page-size-selector"><label>Mostrar:</label><select v-model.number="pageSize" @change="reload"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option></select></div>
            <div class="pagination-nav"><button class="pagination-button" :disabled="page===1" @click="go(page-1)"><font-awesome-icon icon="chevron-left" /></button><button class="pagination-button" :disabled="page*pageSize>=total" @click="go(page+1)"><font-awesome-icon icon="chevron-right" /></button></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'INFORMIX'
const OP_LIST = 'APREMIOSSVN_NOTIFICACIONES_LIST'
const { loading, execute } = useApi()

const filters = ref({ q: '', desde: '', hasta: '' })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])

async function reload() {
  const params = [
    { name: 'q', type: 'C', value: String(filters.value.q || '') },
    { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
    { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') },
    { name: 'offset', type: 'I', value: (page.value - 1) * pageSize.value },
    { name: 'limit', type: 'I', value: pageSize.value }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    rows.value = arr
    total.value = Number(data?.total ?? arr.length)
  } catch (e) {
    rows.value = []
    total.value = 0
  }
}

function go(p){ page.value = p; reload() }

reload()
</script>

