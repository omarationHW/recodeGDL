<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="address-card" /></div>
      <div class="module-view-info">
        <h1>Impresión Padrón Vehicular</h1>
        <p>Rango de IDs</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">ID desde</label><input type="number" class="municipal-form-control" v-model.number="id1" /></div>
            <div class="form-group"><label class="municipal-form-label">ID hasta</label><input type="number" class="municipal-form-control" v-model.number="id2" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>ID</th><th>Placa</th><th>Nombre</th><th>Municipio</th><th>Marca</th><th>Modelo</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="r.id"><td>{{ r.id }}</td><td>{{ r.placa }}</td><td>{{ r.nombre }}</td><td>{{ r.municipio }}</td><td>{{ r.marca }}</td><td>{{ r.modelo }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="6" class="text-center text-muted">Sin datos</td></tr>
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
import apiService from '@/services/apiService'

const id1 = ref(1)
const id2 = ref(100)
const loading = ref(false)
const rows = ref([])

async function consultar() {
  loading.value = true
  rows.value = []
  try {
    const params = [ { nombre: 'p_id1', valor: id1.value, tipo: 'integer' }, { nombre: 'p_id2', valor: id2.value, tipo: 'integer' } ]
    const resp = await apiService.execute('sp_get_padron_report', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } finally {
    loading.value = false
  }
}
</script>

