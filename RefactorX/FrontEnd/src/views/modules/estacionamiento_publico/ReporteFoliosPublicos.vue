<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-lines" /></div>
      <div class="module-view-info">
        <h1>Reporte de Folios — Estacionamientos</h1>
        <p>Folios hechos por inspector en fecha</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="ejecutar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="fecha" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Inspector</th><th>Folios</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="r.vigilante"><td>{{ r.inspector }}</td><td>{{ r.folios }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="2" class="text-center text-muted">Sin datos</td></tr>
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

const fecha = ref('')
const loading = ref(false)
const rows = ref([])

async function ejecutar() {
  loading.value = true
  rows.value = []
  try {
    const params = [ { nombre: 'p_fecha', valor: fecha.value, tipo: 'string' } ]
    const resp = await apiService.execute('sp_get_folios_by_inspector', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } catch (e) {
    rows.value = []
  } finally {
    loading.value = false
  }
}
</script>

