<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list-check" /></div>
      <div class="module-view-info"><h1>Actuaciones Procesales SVN</h1></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Expediente</label>
              <input class="municipal-form-control" v-model="filters.expediente" @keyup.enter="reload" />
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
        <div class="municipal-card-header"><h5>Actuaciones</h5><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Fecha</th><th>Actuación</th><th>Responsable</th><th>Resultado</th></tr></thead>
              <tbody>
                <tr v-for="(r, i) in rows" :key="i" class="row-hover">
                  <td>{{ r.fecha }}</td><td>{{ r.actuacion }}</td><td>{{ r.responsable }}</td><td>{{ r.resultado }}</td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="4" class="text-center text-muted">Sin resultados</td></tr>
              </tbody>
            </table>
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
const OP_LIST = 'APREMIOSSVN_ACTUACIONES_LIST'
const { loading, execute } = useApi()

const filters = ref({ expediente: '', desde: '', hasta: '' })
const rows = ref([])

async function reload() {
  const params = [
    { name: 'expediente', type: 'C', value: String(filters.value.expediente || '') },
    { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
    { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    rows.value = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  }
}

reload()
</script>

