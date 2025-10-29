<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Listado (SPUBREPORTS) — Estacionamientos Públicos</h1>
        <p>Ordenado por opción</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="run"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Orden (opc)</label>
              <select class="municipal-form-control" v-model.number="opc">
                <option :value="1">Categoría</option>
                <option :value="2">Sector</option>
                <option :value="3">Número</option>
                <option :value="4">Nombre</option>
                <option :value="5">Calle</option>
                <option :value="7">Zona/Subzona</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th>Cat</th><th>Sector</th><th>Número</th><th>Nombre</th><th>Cupo</th></tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="r.id">
                  <td>{{ r.categoria }}</td>
                  <td>{{ r.sector }}</td>
                  <td>{{ r.numesta }}</td>
                  <td>{{ r.nombre }}</td>
                  <td>{{ r.cupo }}</td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin datos</td></tr>
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

const loading = ref(false)
const opc = ref(1)
const rows = ref([])

async function run() {
  loading.value = true
  rows.value = []
  try {
    const params = [ { nombre: 'opc', valor: opc.value, tipo: 'integer' } ]
    const resp = await apiService.execute('spubreports_list', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } catch (e) {
    rows.value = []
  } finally {
    loading.value = false
  }
}
</script>

