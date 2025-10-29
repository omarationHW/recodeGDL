<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Estado de Cuenta — Estacionamientos Públicos</h1>
        <p>Búsqueda por número de estacionamiento</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Número de Estacionamiento</label><input class="municipal-form-control" type="number" v-model.number="numesta" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Datos</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <table class="detail-table" v-if="row">
            <tr><td class="label">Nombre</td><td>{{ row.nombre }}</td></tr>
            <tr><td class="label">Licencia</td><td>{{ row.numlicencia }}</td></tr>
            <tr><td class="label">Sector</td><td>{{ row.sector }}</td></tr>
            <tr><td class="label">Zona/Subzona</td><td>{{ row.zona }} / {{ row.subzona }}</td></tr>
            <tr><td class="label">RFC</td><td>{{ row.rfc }}</td></tr>
            <tr><td class="label">Descripción</td><td>{{ row.descripcion }}</td></tr>
          </table>
          <div v-else class="text-muted">Sin información</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const loading = ref(false)
const numesta = ref('')
const row = ref(null)

async function consultar() {
  loading.value = true
  row.value = null
  try {
    const params = [ { nombre: 'numesta', valor: numesta.value, tipo: 'integer' } ]
    const resp = await apiService.execute('spubreports_edocta', 'estacionamiento_publico', params)
    const result = resp?.data?.result || []
    row.value = result[0] || null
  } catch (e) {
    row.value = null
  } finally {
    loading.value = false
  }
}
</script>

