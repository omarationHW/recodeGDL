<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="table" /></div>
      <div class="module-view-info">
        <h1>Listados — Estacionamientos Públicos</h1>
        <p>Reporte por clasificación y sector</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="run"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Ordenar por</label>
              <select class="municipal-form-control" v-model="orderBy">
                <option value="cve_sector, cve_categ, cve_numero">Sector, Categoría, Número</option>
                <option value="cve_categ, cve_sector, cve_numero">Categoría, Sector, Número</option>
                <option value="nombre">Nombre</option>
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
                <tr><th>Sector</th><th>Cat</th><th>Número</th><th>Nombre</th><th>Cupo</th></tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.cve_sector}-${r.cve_categ}-${r.cve_numero}`">
                  <td>{{ r.cve_sector }}</td>
                  <td>{{ r.cve_categ }}</td>
                  <td>{{ r.cve_numero }}</td>
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
const rows = ref([])
const orderBy = ref('cve_sector, cve_categ, cve_numero')

async function run() {
  loading.value = true
  rows.value = []
  try {
    const params = [ { nombre: 'order_by', valor: orderBy.value, tipo: 'string' } ]
    const resp = await apiService.execute('sqrp_publicos_report', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } catch (e) {
    rows.value = []
  } finally {
    loading.value = false
  }
}
</script>

